#!/usr/bin/env node
// L4 门 + trace_cmd 同一入口（profiles/harmonyos.toml）：hvigorw 本地测试 → 读测试报告 →
// 对源码 `// fn:` 注释 → 写 .state/trace.json。
//
// 契约（suite 复核，wrapper 源头保证）：
//   - trace.json = { schema: 1, tests: [{ test, fns: string[], inert: boolean }] }
//   - inert=true（skip/blocked/pending）的测试，fns 必须为空 —— 违反即硬错
//   - 源码里的 it(...) 在报告中缺席 = 假绿，硬错（不允许只对得上的一部分）
//
// 锚点形状（go 栈同款，Hypium 无注解面）：it(...) 的**紧邻上一行**行注释：
//
//   // fn: M01.F01.I03 M01.F01.I04
//   it('超出宽限判定为迟到', 0, () => { ... });
//
// 空 `// fn:`（冒号后无 ID）= 该测试是工程设施测试，不挂业务 ID。挂假 ID 会在 L5 悬空。
//
// 【装机首航校准】（2026-10-28 已完成）：HVIGOR_TEST_ARGS 与 REPORT_CANDIDATES 按实测回填——
//   hvigorw test 真实参数=HVIGOR_TEST_ARGS 原样（BUILD SUCCESSFUL + GenerateUnitTestResult 有产出）；
//   报告真实落点=entry/.test/default/intermediates/test/coverage_data/test_result.txt（键值四元组流，
//   解析器 parseKvReport）。换 SDK 大版本时重验两表。

import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const ROOT = process.cwd();
const TEST_DIR = path.join(ROOT, 'entry', 'src', 'test');
const STATE_DIR = path.join(ROOT, '.state');
const TRACE_PATH = path.join(STATE_DIR, 'trace.json');

// ---- 装机首航校准表（两处按 SDK 实际行为修正，改前先跑通一次手动命令） ----

// hvigor 本地单测命令参数（官方：hvigorw --mode module -p module=entry@default test，
// onDevice=false 走本地执行体，coverage 关掉提速）。
const HVIGOR_TEST_ARGS = [
  '--mode', 'module',
  '-p', 'module=entry@default',
  '-p', 'onDevice=false',
  '-p', 'coverage=false',
  'test',
];

// 测试报告候选目录（按优先级；存在多个取最新 mtime 的那个）。
// 2026-10-28 装机首航校准：hvigorw test（onDevice=false）真实落点 =
// entry/.test/default/intermediates/test/coverage_data/test_result.txt。
const REPORT_CANDIDATES = [
  path.join(ROOT, 'entry', '.test', 'default', 'intermediates', 'test', 'coverage_data'),
];

// ---- 工具函数 ----

function die(msg) {
  console.error(`[trace-test] ${msg}`);
  process.exit(1);
}

function walk(dir, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) walk(p, out);
    else out.push(p);
  }
  return out;
}

// ---- 1) 锚点扫描：entry/src/test/**/*.ets 的 it(...) 与紧邻上一行 `// fn:` ----

function scanAnchors() {
  if (!fs.existsSync(TEST_DIR)) die(`测试目录不存在：${TEST_DIR}`);
  const files = walk(TEST_DIR).filter((f) => f.endsWith('.ets'));
  if (files.length === 0) die(`测试目录里没有 .ets 测试文件：${TEST_DIR}`);

  const tests = []; // { test, fns }
  const FN_RE = /^\s*\/\/\s*fn:\s*(.*)$/;
  const IT_RE = /\bit\(\s*['"`]([^'"`]+)['"`]/;

  for (const file of files) {
    const rel = path.relative(ROOT, file).replaceAll('\\', '/');
    const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
    for (let i = 0; i < lines.length; i++) {
      const m = IT_RE.exec(lines[i]);
      if (!m) continue;
      let fns = [];
      if (i > 0) {
        const fm = FN_RE.exec(lines[i - 1]);
        if (fm) {
          fns = fm[1].trim().split(/\s+/).filter(Boolean);
          const bad = fns.find((id) => !/^[A-Za-z0-9._-]+$/.test(id));
          if (bad) die(`${rel}:${i + 1} 锚点 ID 含非法字符「${bad}」（允许 A-Za-z0-9._-）`);
        }
      }
      tests.push({ test: `${rel}::${m[1]}`, fns, rel, line: i + 1 });
    }
  }

  const byName = new Map();
  for (const t of tests) {
    if (byName.has(t.test)) die(`测试名重复：${t.test}（锚点扫描无法区分，改名）`);
    byName.set(t.test, t);
  }
  if (tests.length === 0) die(`扫描到 0 个 it(...)——${TEST_DIR} 里没有可 trace 的测试`);
  return tests;
}

// ---- 2) 跑 hvigorw 本地测试 ----

let hvigorStatus = null;

function runHvigor() {
  const cmd = process.platform === 'win32'
    ? ['hvigorw.bat', ...HVIGOR_TEST_ARGS].join(' ')
    : ['hvigorw', ...HVIGOR_TEST_ARGS].join(' ');
  const r = spawnSync(cmd, {
    cwd: ROOT,
    stdio: 'inherit',
    shell: true,
  });
  hvigorStatus = r.status;
  // 测试失败（非 0）不直接 die：报告仍要读——trace 需要记录哪些测试红了。
  // 完全没产出报告的失败由 findReport 兜住（报错带上 hvigorw 退出码便于分诊）。
}

// ---- 3) 解析测试报告（形状装机首航校准面）----

const STATES_GREEN = new Set(['passed', 'pass', 'ok', 'success']);

function stateOf(raw) {
  const s = String(raw).toLowerCase();
  if (STATES_GREEN.has(s)) return { inert: false, green: true };
  // skip/blocked/pending/failed 全部算 inert（failed 测试不许挂 ID，suite 同款复核）
  return { inert: true, green: false };
}

// JSON 报告：递归找带「名字 + 状态」的测试条目（Hypium 各版本字段名不一，宽松匹配）。
function collectJsonTests(node, out) {
  if (Array.isArray(node)) {
    for (const n of node) collectJsonTests(n, out);
    return;
  }
  if (!node || typeof node !== 'object') return;
  const name = node.name ?? node.testName ?? node.caseName ?? node.id;
  const state = node.state ?? node.status ?? node.result ?? node.conclusion;
  if (typeof name === 'string' && typeof state === 'string') out.push({ name, state });
  for (const v of Object.values(node)) collectJsonTests(v, out);
}

function parseTxtLine(line) {
  // 形如 `describe > it: passed` / `itName: failed` 的摘要行
  const m = /^(.+?):\s*(passed|failed|skipped|blocked|pending|ignored)\s*$/i.exec(line.trim());
  if (!m) return null;
  return { name: m[1].trim(), state: m[2] };
}

// Hypium 本地单测报告真实形状（2026-10-28 装机首航校准）——键值四元组流：
//   class=<describe 名>
//   test=<it 名>
//   result=Success | Failure | Error
// （class 在同名 describe 的后续 it 可省略；末行 `Tests run: ...` 汇总，无 state 词自然跳过）
function parseKvReport(text, out) {
  let cls = '';
  let name = '';
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.trim();
    let m = /^class=(.+)$/.exec(line);
    if (m) {
      cls = m[1].trim();
      continue;
    }
    m = /^test=(.+)$/.exec(line);
    if (m) {
      name = m[1].trim();
      continue;
    }
    m = /^result=(.+)$/.exec(line);
    if (m && name) {
      out.push({ name: cls ? `${cls} > ${name}` : name, state: m[1].trim() });
      name = '';
    }
  }
}

function findReport() {
  const files = [];
  for (const dir of REPORT_CANDIDATES) {
    for (const f of walk(dir)) {
      if (f.endsWith('.json') || f.endsWith('.txt')) files.push(f);
    }
  }
  if (files.length === 0) {
    const hint =
      hvigorStatus === 0
        ? 'hvigorw 退出码 0 但没找到报告——候选表（下方）几乎必然漏了真实目录。'
        : `hvigorw 退出码 ${hvigorStatus}（命令不存在/编译失败都可能）。` +
          '先确认 HarmonyOS SDK command-line tools 在 PATH（与 gate 同一调用 export——android 同坑）；' +
          '命令通了再修候选表。';
    die(
      '找不到测试报告。先看下方 hvigorw 退出码分诊；常见=ohpm install 没跑或编译失败。\n' +
        hint +
        `\n已扫目录：\n${REPORT_CANDIDATES.map((d) => `  - ${d}`).join('\n')}`,
    );
  }
  const entries = [];
  for (const f of files) {
    const text = fs.readFileSync(f, 'utf8');
    if (f.endsWith('.json')) {
      try {
        collectJsonTests(JSON.parse(text), entries);
      } catch {
        /* 非测试报告的 json（配置/清单），跳过 */
      }
    } else {
      parseKvReport(text, entries);
      for (const line of text.split(/\r?\n/)) {
        const t = parseTxtLine(line);
        if (t) entries.push(t);
      }
    }
  }
  if (entries.length === 0) {
    die(
      `报告目录里有文件但没有解析出任何测试条目（${files.length} 个候选文件）。` +
        '报告格式异常：parseKvReport 与真实报告形状失配（SDK 大版本变更？）先核报告再修。',
    );
  }
  return entries;
}

// ---- 4) 对账：报告 × 源码锚点 → trace.json ----

function matchReport(test, reportEntries) {
  // 报告名可能带 describe 前缀或文件前缀；按 it 名子串匹配（装机校准后收紧）。
  const itName = test.test.split('::')[1];
  return reportEntries.filter((e) => e.name === itName || e.name.endsWith(` ${itName}`) || e.name.endsWith(`> ${itName}`));
}

function main() {
  const anchors = scanAnchors();
  runHvigor();
  const report = findReport();

  const used = new Set();
  const tests = [];
  const missing = [];

  for (const a of anchors) {
    const hits = matchReport(a, report);
    for (const h of hits) used.add(h);
    if (hits.length === 0) {
      missing.push(`${a.test}（${a.rel}:${a.line}）`);
      continue;
    }
    // 同名多状态取最坏（一次 skip 即 skip）
    const inert = hits.some((h) => stateOf(h.state).inert);
    if (inert && a.fns.length > 0) {
      die(
        `测试被 skip/未通过却挂了功能 ID（契约硬要求）：${a.test}\n` +
          `  fns: ${a.fns.join(' ')}\n  处置：先让测试变绿，或摘掉锚点 ID。`,
      );
    }
    tests.push({ test: a.test, fns: a.fns, inert });
  }

  if (missing.length > 0) {
    die(
      `源码里 ${missing.length} 个 it(...) 在测试报告中缺席（假绿防御；报告不完整或名字对不上）：\n` +
        missing.map((m) => `  - ${m}`).join('\n'),
    );
  }

  fs.mkdirSync(STATE_DIR, { recursive: true });
  fs.writeFileSync(TRACE_PATH, `${JSON.stringify({ schema: 1, tests }, null, 2)}\n`);
  const green = tests.filter((t) => !t.inert).length;
  console.log(
    `[trace-test] trace.json 已写：${tests.length} 测试（绿 ${green} / inert ${tests.length - green}，锚点 ID ${tests.reduce((n, t) => n + t.fns.length, 0)} 个）`,
  );
}

main();

# CLAUDE.md — saas 统一身份平台（HarmonyOS ArkTS 版）

> 书稿配套仓 + harness 门禁仓双身份。入口，不是手册。L0 门强制上限 60 行。
> 本仓为《（书稿信息待补）》案例（待补）（saas 统一身份平台（HarmonyOS ArkTS 版））的可运行配套工程，是书稿代码块的 **source of truth**。

## 1. 项目定位

saas 统一身份平台（HarmonyOS ArkTS 版）（`saas-identity-platform-harmonyos`，技术栈 `harmonyos`）。一句话定位见 README.md。

## 2. 铁律

- **TDD**：每个模块先写失败测试 → 跑确认失败 → 实现 → 跑确认绿 → commit
- **版本钉死**：依赖与 `version-lock.json` 的 `version_lock` 一致；不引入 lock 外的库
- **tag 即放行**：全量回归绿后打 `v<MAJOR>.<MINOR>.<PATCH>-<YYYYMMDD>`（如 `v0.3.54-20260826`）
- **mock-friendly**：安装 + 测试必须在无 Key、无 Docker、无网下全绿
- **功能清单是锚点**：改 `docs/functions/function-tree.md` 走 `/tree-change` 提案，由人批准；
  改功能与改功能清单必须同一个 commit；废弃只改状态，编号永不复用；禁止给 skip 的测试挂功能 ID

- 禁止 env/API base 键写默认值兜底（fail-fast，suite-hard-rules §1；AppConfig 缺失必须 throw）
- 禁止绕过 shared 契约生成物手写 API 面（suite-hard-rules §4，Phase 1 codegen 起）
- 依赖钉死 version-lock.json（oh-package.json5 是唯一钉版面，禁裸写版本）
- ohpm 依赖一律走华为镜像（oh-package.json5 / ohpm 配置，禁删镜像位）
- 禁 any / @ts-ignore / as Object 强转逃逸 ArkTS 严格约束（除非附 ADR 说明）
- 签名材料（p12/cer/p7b）与本地签名配置禁入库（.gitignore 已挡，漏挡即违例）

## 3. 技术栈与版本（钉死于 version-lock.json）

HarmonyOS NEXT ArkTS（ArkUI 声明式 + Stage 模型 + hvigor 构建 + Hypium 本地单测 + Code Linter）。ohpm 依赖走华为镜像（https://ohpm.openharmony.cn/ohpm/）；门命令首词 hvigorw / codelinter / node（EXEC_ALLOWLIST 2026-10-27 人批扩）；须先装 HarmonyOS SDK command-line tools（落 3-resources/8-ego/software/harmonyos-sdk；PATH 与 OHOS_SDK_HOME 必须与 gate 同一 Bash 调用 export——android 同坑）。X14 槽不分配端口：无 dev server，四门全 CLI，Hypium 本地单测无设备依赖，模拟器不装。骨架期（2026-10-27 进家族，ktor X09 骨架先行同节奏）：门命令形状按官方文档声明、装机首航校准后才许宣称传输层可用。明细见 `version-lock.json` 与 README.md 技术栈表。

门禁命令见 `.harness/stack.json`。**不要改它来让门变松。**

## 4. 验收

- 在 **suite 根目录** 跑 `python scripts/gate.py -p saas-identity-platform-harmonyos`；exit 0 才算完成
- 本地命令见 README.md「快速开始」

## 5. 指向别处

- 功能清单（唯一锚点） → `docs/functions/function-tree.md`
- 需求 → 任务 → 功能影响 → `docs/requirements/`
- 流程/设计 与功能对齐 → `docs/design/`（人评审，机器只查引用）
- 决策背景 → `docs/adr/`；编码细则 → `docs/conventions/`（不进主上下文）
- 待办与迭代方向 → `PLAN.md`；版本变更 → `CHANGELOG.md`

## 6. 工作循环

0. **开工前分诊**：先过 `using-skills`，把激活 skill 的清单落成 todo。
   顺序：规格(brainstorming)→计划(writing-plans)→测试先红(red-first)→实现(executing-plans)
1. 读 `.state/session.json` 恢复上下文
2. 最小改动
3. 跑 `python scripts/gate.py -p saas-identity-platform-harmonyos`；exit 1 回到第 2 步；exit 2 停下问人
4. `/handoff` 更新 `.state/session.json`

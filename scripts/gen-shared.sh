#!/bin/bash
# Generate ArkTS API client locally from shared's OpenAPI.yaml.
#
# 架构（家族同款 + ADR-0054 自研轮子）：shared 仓是纯契约源（TypeSpec → OpenAPI.yaml only），
# 语言产物在各消费仓本地生成（suite 硬规则 §4：API 面只认生成物，禁手写接口层）。
# 本仓生成器 = harmonyos-api-gen 轮子（suite 仓 output/ 平级 sibling，openapi.yaml → IR → ArkTS），
# 产物写 entry/src/main/ets/shared/（禁手改，regen 先删后写，字节级幂等）。
# 产物 committed；门禁机器只需 Node + 轮子仓 dist（不需要 ohpm/hvigor）。
#
# 前置（L3 编译另行需要，本脚本不负责）：
#   - harmonyos-api-gen 轮子已构建（仓内 npm install && npm run build，产物 dist/cli.js）
#   - runtime HAR 已构建（harmonyos-api-gen 仓 runtime/ assembleHar → runtime.har，
#     entry/oh-package.json5 以 file: 挂载——ohpm file: 以声明 oh-package 所在目录为基准）
set -euo pipefail

SHARED_DIR="$(cd "$(dirname "$0")/../../saas-identity-platform-shared" && pwd)"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GEN_DIR="$(cd "$ROOT/../harmonyos-api-gen" && pwd)"
OUT="$ROOT/entry/src/main/ets/shared"
RUNTIME_HAR="$GEN_DIR/runtime/build/default/outputs/default/runtime.har"

echo "[gen-shared] step 1/3 — shared: emit OpenAPI.yaml..."
(cd "$SHARED_DIR" && npm run emit:openapi)

OPENAPI="$SHARED_DIR/generated/openapi/openapi.yaml"
if [ ! -f "$OPENAPI" ]; then
  echo "[gen-shared] ERROR: missing $OPENAPI" >&2
  exit 1
fi

if [ ! -f "$GEN_DIR/dist/cli.js" ]; then
  echo "[gen-shared] fail-loud：轮子未构建（$GEN_DIR/dist/cli.js 缺失）——先在该仓 npm install && npm run build 再跑" >&2
  exit 3
fi

echo "[gen-shared] step 2/3 — harmonyos-api-gen: openapi.yaml → ArkTS（先删后写）..."
rm -rf "$OUT"
node "$GEN_DIR/dist/cli.js" --spec "$OPENAPI" --out "$OUT"

echo "[gen-shared] step 3/3 — 结构守卫 + runtime HAR 检查..."
# fail-loud 结构守卫：关键产物缺任一 = 生成器输出结构漂移，停下查（flutter/swift 仓守卫先例）。
if [ -z "$(find "$OUT/models" -name '*.ets' 2>/dev/null)" ] \
  || [ -z "$(find "$OUT/api" -name '*.ets' 2>/dev/null)" ] \
  || [ ! -f "$OUT/index.ets" ]; then
  echo "[gen-shared] fail-loud：shared/ 缺 models|api|index.ets（生成器输出结构漂移？）" >&2
  exit 3
fi
# runtime HAR 是 L3 编译前置（生成物 import harmonyos-api-runtime）；缺 = 提示先构建，不挡 codegen。
if [ ! -f "$RUNTIME_HAR" ]; then
  echo "[gen-shared] WARN：runtime.har 缺失（$RUNTIME_HAR）——L3 前先在轮子仓构建（README runtime HAR 节）" >&2
fi

# ADR-0026 marker（同 sha 零写入，5.77 同款，家族 gen-shared.sh 全员同构）。
SHARED_SHA=$(cd "$SHARED_DIR" && git rev-parse HEAD)
MARKER="$ROOT/.state/last-gen-shared.json"
mkdir -p "$ROOT/.state"
python3 - "$MARKER" "$SHARED_SHA" <<'PYEOF' || echo "[gen-shared] WARN: marker 写失败（staleness 将报 UNKNOWN）" >&2
import datetime, json, sys

marker_path, shared_sha = sys.argv[1:3]
try:
    with open(marker_path, encoding="utf-8") as f:
        marker = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    marker = {}

if marker.get("api_synced_sha") == shared_sha:
    print("[marker] api_synced_sha unchanged - zero write (5.77)")
    sys.exit(0)

marker["api_synced_sha"] = shared_sha
marker["api_synced_at"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
marker["api_synced_cmd"] = "gen-shared.sh"
marker["shared_sha"] = shared_sha
marker["consumer_repo"] = "saas-identity-platform-harmonyos"

with open(marker_path, "w", encoding="utf-8") as f:
    json.dump(marker, f, ensure_ascii=False, indent=2)
    f.write("\n")
PYEOF

echo "[gen-shared] OK (shared HEAD ${SHARED_SHA:0:7})"

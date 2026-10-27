// 后端 API 基址解析（纯函数面，供 Hypium 本地单测直测——无 context 依赖才有本地可测性）。
// rawfile/config.json 是随包配置：API_BASE_URL 缺失/空即抛错——禁止默认值兜底
// （suite-hard-rules §1，2026-08-28 漂移事故同源纪律；miniprogram app-config.ts 同源）。
// Phase 1 接线时按 multi-repo-family.md §6 dev/prod URL 表与家族档案核对。

export interface RawfileConfig {
  API_BASE_URL?: string;
}

export function parseApiBaseUrl(raw: string): string {
  let parsed: RawfileConfig;
  try {
    parsed = JSON.parse(raw) as RawfileConfig;
  } catch {
    throw new Error('rawfile config.json 不是合法 JSON（fail-fast，禁默认值兜底）');
  }
  const url = parsed.API_BASE_URL;
  if (url === undefined || url === null || url.trim() === '') {
    throw new Error(
      'API_BASE_URL 未配置。禁止默认值兜底（suite-hard-rules §1）；' +
        '随包 rawfile/config.json 填真值，Phase 1 接线时按家族档案核对端点。',
    );
  }
  return url.trim();
}

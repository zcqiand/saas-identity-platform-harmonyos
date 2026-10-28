// 锚点契约（profiles/harmonyos.toml）：`// fn:` 注释写在 it(...) 紧邻上一行，空 = 不挂业务 ID。
// 本文件全是工程设施测试（锚点直测 + AppConfig fail-fast 纯函数直测），一律不挂业务 ID
// ——挂假 ID 会在 L5 悬空（tree 里无此 ID）。业务测试进 Phase 1 再来，先补功能清单后写测试。
import { describe, it, expect } from '@ohos/hypium';
import { parseApiBaseUrl } from '../main/ets/config/AppConfig';

export function fnSuite(): void {
  describe('harness_fn_anchor', () => {
    // fn:
    it('harness fn anchor round-trips into trace', 0, () => {
      expect(2).assertEqual(1 + 1);
    });
  });
  describe('app_config_fail_fast', () => {
    // fn:
    it('parseApiBaseUrl throws when rawfile config is not JSON', 0, () => {
      let threw = false;
      try {
        parseApiBaseUrl('not-json');
      } catch {
        threw = true;
      }
      expect(threw).assertTrue();
    });
    // fn:
    it('parseApiBaseUrl throws when API_BASE_URL missing or empty（fail-fast 禁默认值兜底）', 0, () => {
      let threwMissing = false;
      let threwEmpty = false;
      try {
        parseApiBaseUrl('{}');
      } catch {
        threwMissing = true;
      }
      try {
        parseApiBaseUrl('{"API_BASE_URL": "  "}');
      } catch {
        threwEmpty = true;
      }
      expect(threwMissing).assertTrue();
      expect(threwEmpty).assertTrue();
    });
    // fn:
    it('parseApiBaseUrl returns trimmed url when configured', 0, () => {
      expect(parseApiBaseUrl('{"API_BASE_URL": " http://localhost:5104 "}'))
        .assertEqual('http://localhost:5104');
    });
  });
}

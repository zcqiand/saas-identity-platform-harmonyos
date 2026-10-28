// 锚点契约（profiles/harmonyos.toml）：`// fn:` 注释写在 it(...) 紧邻上一行，空 = 不挂业务 ID。
// 本文件全是工程设施测试（锚点直测 + AppConfig fail-fast 纯函数直测），一律不挂业务 ID
// ——挂假 ID 会在 L5 悬空（tree 里无此 ID）。业务测试进 Phase 1 再来，先补功能清单后写测试。
import { describe, it, expect } from '@ohos/hypium';
import { parseApiBaseUrl } from '../main/ets/config/AppConfig';
// 会话状态机（工程设施测试，锚点留空——SessionState 是会话管道非业务功能；
// 业务测试待功能树扩面后按 ID 挂）。只 import 生成模型（纯类型面），
// 不触 runtime/@ohos——保持本地单测无设备依赖。
import { LoginResponse } from '../main/ets/shared/models/LoginResponse';
import { MemoryTokenStore, SessionState } from '../main/ets/session/SessionState';

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

export function sessionSuite(): void {
  describe('session_state', () => {
    // fn:
    it('initial state loads persisted token and is authenticated', 0, () => {
      let store = new MemoryTokenStore();
      store.save('tok-1');
      let s = new SessionState(store);
      expect(s.authenticated()).assertTrue();
      expect(s.tokenProvider()).assertEqual('tok-1');
    });
    // fn:
    it('applyLogin stores accessToken via TokenStore', 0, () => {
      let store = new MemoryTokenStore();
      let s = new SessionState(store);
      let resp: LoginResponse = {
        user: { id: 'u1', username: 'alice', status: 'active', createdAt: '2026-01-01T00:00:00Z', updatedAt: '2026-01-01T00:00:00Z' },
        availableTenants: [],
        userId: 'u1',
        accessToken: 'tok-2',
        clientId: 'saas-console'
      };
      s.applyLogin(resp);
      expect(s.authenticated()).assertTrue();
      expect(store.load()).assertEqual('tok-2');
    });
    // fn:
    it('applyLogin without accessToken throws（禁空 token 入态）', 0, () => {
      let s = new SessionState(new MemoryTokenStore());
      let resp: LoginResponse = {
        user: { id: 'u1', username: 'alice', status: 'active', createdAt: '2026-01-01T00:00:00Z', updatedAt: '2026-01-01T00:00:00Z' },
        availableTenants: [],
        userId: 'u1',
        clientId: 'saas-console'
      };
      let threw = false;
      try {
        s.applyLogin(resp);
      } catch {
        threw = true;
      }
      expect(threw).assertTrue();
    });
    // fn:
    it('logout clears token store and state', 0, () => {
      let store = new MemoryTokenStore();
      let s = new SessionState(store);
      s.applyLogin({
        user: { id: 'u1', username: 'alice', status: 'active', createdAt: '2026-01-01T00:00:00Z', updatedAt: '2026-01-01T00:00:00Z' },
        availableTenants: [],
        userId: 'u1',
        accessToken: 'tok-3',
        clientId: 'saas-console'
      });
      s.logout();
      expect(s.authenticated()).assertFalse();
      expect(store.load()).assertNull();
    });
    // fn:
    it('tokenProvider without token throws', 0, () => {
      let s = new SessionState(new MemoryTokenStore());
      let threw = false;
      try {
        s.tokenProvider();
      } catch {
        threw = true;
      }
      expect(threw).assertTrue();
    });
  });
}

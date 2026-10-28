// 会话状态机（纯逻辑面，Hypium 本地单测直测——只 import 生成模型，不触 runtime/@ohos）。
// token 存取走注入 TokenStore：本地测试用 MemoryTokenStore，UI 侧后续可换 Preferences 实现。
// 空 accessToken 禁入态（禁兜底纪律同源：缺失就 throw，不静默降级）。
import { LoginResponse } from '../shared/models/LoginResponse';

export interface TokenStore {
  load(): string | null;
  save(token: string): void;
  clear(): void;
}

export class MemoryTokenStore implements TokenStore {
  private token: string | null = null;

  load(): string | null {
    return this.token;
  }

  save(token: string): void {
    this.token = token;
  }

  clear(): void {
    this.token = null;
  }
}

export class SessionState {
  private readonly store: TokenStore;
  private accessToken: string | null;

  constructor(store: TokenStore) {
    this.store = store;
    this.accessToken = store.load();
  }

  authenticated(): boolean {
    return this.accessToken !== null;
  }

  // ApiClient tokenProvider 用：每请求现取，无 token 即抛（生成面 401 语义留给后端，
  // 本地不发无凭据请求）
  tokenProvider(): string {
    if (this.accessToken === null) {
      throw new Error('未登录（无 token）');
    }
    return this.accessToken;
  }

  applyLogin(resp: LoginResponse): void {
    if (resp.accessToken === undefined || resp.accessToken.trim() === '') {
      throw new Error('LoginResponse 缺 accessToken（fail-fast，禁空 token 入态）');
    }
    this.accessToken = resp.accessToken;
    this.store.save(resp.accessToken);
  }

  logout(): void {
    this.accessToken = null;
    this.store.clear();
  }
}

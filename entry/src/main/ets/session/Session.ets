// 会话装配（runtime 接线面，不进本地单测——本文件 import runtime/@ohos）。
//   - base URL 走 AppConfig.parseApiBaseUrl（rawfile config.json，fail-fast 禁兜底）
//   - clientId = saas-console（家族档案 saas 值表：console 应用）
//   - tokenProvider 每请求现取（SessionState），不落缓存不自动续期
import { ApiClient } from 'harmonyos-api-runtime';
import { SessionsApi, MeApi, TenantMembersApi } from '../shared';
import { CurrentUser } from '../shared/models/CurrentUser';
import { TenantMembersListTenantUsersResponse } from '../shared/models/TenantMembersListTenantUsersResponse';
import { parseApiBaseUrl } from '../config/AppConfig';
import { SessionState, MemoryTokenStore } from './SessionState';

// 家族档案 saas.md：console 应用 clientId=saas-console
export const SAAS_CLIENT_ID = 'saas-console';

export class Session {
  private readonly state: SessionState;
  private sessionsApi: SessionsApi | null = null;
  private meApi: MeApi | null = null;
  private tenantMembersApi: TenantMembersApi | null = null;

  constructor() {
    this.state = new SessionState(new MemoryTokenStore());
  }

  // rawfile config.json 原文进，fail-fast 解析（API_BASE_URL 缺失即抛）
  configure(rawConfig: string): void {
    const baseUrl = parseApiBaseUrl(rawConfig);
    const client = new ApiClient(baseUrl, () => this.state.tokenProvider());
    this.sessionsApi = new SessionsApi(client);
    this.meApi = new MeApi(client);
    this.tenantMembersApi = new TenantMembersApi(client);
  }

  private requireSessions(): SessionsApi {
    if (this.sessionsApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.sessionsApi;
  }

  private requireMe(): MeApi {
    if (this.meApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.meApi;
  }

  private requireTenantMembers(): TenantMembersApi {
    if (this.tenantMembersApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.tenantMembersApi;
  }

  authenticated(): boolean {
    return this.state.authenticated();
  }

  async login(username: string, password: string): Promise<void> {
    const resp = await this.requireSessions().login({
      username: username,
      password: password,
      clientId: SAAS_CLIENT_ID
    });
    this.state.applyLogin(resp);
  }

  whoami(): Promise<CurrentUser> {
    return this.requireMe().whoami();
  }

  listMembers(tenantId: string, page: number, pageSize: number): Promise<TenantMembersListTenantUsersResponse> {
    return this.requireTenantMembers().listTenantUsers(tenantId, page, pageSize);
  }

  async logout(): Promise<void> {
    try {
      await this.requireSessions().logout();
    } finally {
      // 后端 logout 失败也清本地态（token 已不可信）；错误语义由调用方另行提示
      this.state.logout();
    }
  }
}

// 页面级单例（EntryAbility/Index 共用同一会话）
export const session = new Session();

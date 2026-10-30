// 会话装配（runtime 接线面，不进本地单测——本文件 import runtime/@ohos）。
//   - base URL 走 AppConfig.parseApiBaseUrl（rawfile config.json，fail-fast 禁兜底）
//   - clientId = saas-console（家族档案 saas 值表：console 应用）
//   - tokenProvider 每请求现取（SessionState），不落缓存不自动续期
import { ApiClient } from 'harmonyos-api-runtime';
import {
  SessionsApi, MeApi, TenantMembersApi, TenantRolesApi, TenantRoleMenusApi,
  AdminTenantsApi, AdminClientsApi, TenantApplicationsApi, ClientsApi, ClientMenusApi,
  OAuthApi
} from '../shared';
import { CurrentUser } from '../shared/models/CurrentUser';
import { TenantMembersListTenantUsersResponse } from '../shared/models/TenantMembersListTenantUsersResponse';
import { TenantRolesListSysRolesResponse } from '../shared/models/TenantRolesListSysRolesResponse';
import { RoleMenuGrant } from '../shared/models/RoleMenuGrant';
import { AdminTenantsListTenantsResponse } from '../shared/models/AdminTenantsListTenantsResponse';
import { AdminClientsListClientsResponse } from '../shared/models/AdminClientsListClientsResponse';
import { TenantApplicationsListTenantApplicationsResponse } from '../shared/models/TenantApplicationsListTenantApplicationsResponse';
import { OAuthClientPublicInfo } from '../shared/models/OAuthClientPublicInfo';
import { SysMenu } from '../shared/models/SysMenu';
import { OAuthAuthorizeResponse } from '../shared/models/OAuthAuthorizeResponse';
import { TokenResponse } from '../shared/models/TokenResponse';
import { parseApiBaseUrl } from '../config/AppConfig';
import { SessionState, MemoryTokenStore } from './SessionState';

// 家族档案 saas.md：console 应用 clientId=saas-console
export const SAAS_CLIENT_ID = 'saas-console';
// OAuth 三步流回调（dev 种子 oauth_client.redirect_uris 实测值；saas-console 专有 scheme）
export const SAAS_OAUTH_REDIRECT_URI = 'saasidentity://oauth/callback';

export class Session {
  private readonly state: SessionState;
  private sessionsApi: SessionsApi | null = null;
  private meApi: MeApi | null = null;
  private tenantMembersApi: TenantMembersApi | null = null;
  private tenantRolesApi: TenantRolesApi | null = null;
  private tenantRoleMenusApi: TenantRoleMenusApi | null = null;
  private adminTenantsApi: AdminTenantsApi | null = null;
  private adminClientsApi: AdminClientsApi | null = null;
  private tenantApplicationsApi: TenantApplicationsApi | null = null;
  private clientsApi: ClientsApi | null = null;
  private clientMenusApi: ClientMenusApi | null = null;
  private oauthApi: OAuthApi | null = null;

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
    this.tenantRolesApi = new TenantRolesApi(client);
    this.tenantRoleMenusApi = new TenantRoleMenusApi(client);
    this.adminTenantsApi = new AdminTenantsApi(client);
    this.adminClientsApi = new AdminClientsApi(client);
    this.tenantApplicationsApi = new TenantApplicationsApi(client);
    this.clientsApi = new ClientsApi(client);
    this.clientMenusApi = new ClientMenusApi(client);
    this.oauthApi = new OAuthApi(client);
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

  private requireTenantRoles(): TenantRolesApi {
    if (this.tenantRolesApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.tenantRolesApi;
  }

  private requireTenantRoleMenus(): TenantRoleMenusApi {
    if (this.tenantRoleMenusApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.tenantRoleMenusApi;
  }

  private requireAdminTenants(): AdminTenantsApi {
    if (this.adminTenantsApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.adminTenantsApi;
  }

  private requireAdminClients(): AdminClientsApi {
    if (this.adminClientsApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.adminClientsApi;
  }

  private requireTenantApplications(): TenantApplicationsApi {
    if (this.tenantApplicationsApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.tenantApplicationsApi;
  }

  private requireClients(): ClientsApi {
    if (this.clientsApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.clientsApi;
  }

  private requireClientMenus(): ClientMenusApi {
    if (this.clientMenusApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.clientMenusApi;
  }

  private requireOAuth(): OAuthApi {
    if (this.oauthApi === null) {
      throw new Error('Session 未配置（configure 未调用/未完成）——禁静默兜底 base URL');
    }
    return this.oauthApi;
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

  // 角色只读列表（片3）：clientId 可选面本片不筛——undefined 显式传，禁兜底成空串
  listRoles(tenantId: string, page: number, pageSize: number): Promise<TenantRolesListSysRolesResponse> {
    return this.requireTenantRoles().listSysRoles(tenantId, undefined, page, pageSize);
  }

  // 角色已授权菜单（片3）：返回 RoleMenuGrant（roleId/tenantId/menuIds/updatedAt）
  listRoleMenus(tenantId: string, roleId: string): Promise<RoleMenuGrant> {
    return this.requireTenantRoleMenus().listSysRoleMenus(tenantId, roleId, undefined);
  }

  // admin 只读双列表（片4）：租户全量面 + OAuth 客户端全量面（0 基分页）
  listTenants(page: number, pageSize: number): Promise<AdminTenantsListTenantsResponse> {
    return this.requireAdminTenants().listTenants(page, pageSize);
  }

  listClients(page: number, pageSize: number): Promise<AdminClientsListClientsResponse> {
    return this.requireAdminClients().listClients(page, pageSize);
  }

  // 租户应用只读列表（片5）：本租户订阅的应用面，0 基分页
  listTenantApplications(tenantId: string, page: number, pageSize: number): Promise<TenantApplicationsListTenantApplicationsResponse> {
    return this.requireTenantApplications().listTenantApplications(tenantId, page, pageSize);
  }

  // 应用公开信息（片5）：点客户端拉详情（无鉴权面，公开形状）
  getClientPublic(clientId: string): Promise<OAuthClientPublicInfo> {
    return this.requireClients().getClient(clientId);
  }

  // 应用菜单扁平节点（片5）：SysMenu[]（轮子 7dc16f2 后别名保数组语义）
  listClientMenus(clientId: string): Promise<Array<SysMenu>> {
    return this.requireClientMenus().listSysMenus(clientId);
  }

  // OAuth 三步流（片6）：authorize（Bearer 会话签出 code）→ token 交换（authorization_code）
  oauthAuthorize(state: string): Promise<OAuthAuthorizeResponse> {
    return this.requireOAuth().authorize({
      clientId: SAAS_CLIENT_ID,
      redirectUri: SAAS_OAUTH_REDIRECT_URI,
      responseType: 'code',
      state: state,
    });
  }

  oauthToken(code: string): Promise<TokenResponse> {
    return this.requireOAuth().token({
      grantType: 'authorization_code',
      code: code,
      clientId: SAAS_CLIENT_ID,
      redirectUri: SAAS_OAUTH_REDIRECT_URI,
    });
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

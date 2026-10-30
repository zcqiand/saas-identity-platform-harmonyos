// 登录页（Phase 1 首业务消费切片）：SessionsApi.login → SessionState → MeApi.whoami。
// base URL 走 rawfile config.json（AppConfig fail-fast，禁默认值兜底）；
// 错误显示 ApiError 的 code+message（后端错误包络，runtime 统一解包）。
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { ApiError } from 'harmonyos-api-runtime';
import { TenantMemberUserView } from '../shared/models/TenantMemberUserView';
import { SysRole } from '../shared/models/SysRole';
import { Tenant } from '../shared/models/Tenant';
import { OAuthClient } from '../shared/models/OAuthClient';
import { TenantApplication } from '../shared/models/TenantApplication';
import { OAuthClientPublicInfo } from '../shared/models/OAuthClientPublicInfo';
import { SysMenu } from '../shared/models/SysMenu';
import { session } from '../session/Session';

@Entry
@Component
struct Index {
  @State username: string = '';
  @State password: string = '';
  @State message: string = 'saas 统一身份平台（HarmonyOS ArkTS 版）';
  @State busy: boolean = false;
  @State loggedIn: boolean = false;
  @State whoamiText: string = '';
  @State members: TenantMemberUserView[] = [];
  @State memberTotal: number = 0;
  @State roles: SysRole[] = [];
  @State roleTotal: number = 0;
  @State grantText: string = '';
  @State tenants: Tenant[] = [];
  @State tenantTotal: number = 0;
  @State clients: OAuthClient[] = [];
  @State clientTotal: number = 0;
  @State apps: TenantApplication[] = [];
  @State appTotal: number = 0;
  @State menus: SysMenu[] = [];
  @State menuClientText: string = '';
  @State oauthText: string = '';

  private async ensureConfigured(): Promise<void> {
    if (this.loggedIn) {
      return;
    }
    const ctx = getContext(this) as common.UIAbilityContext;
    const raw = await ctx.resourceManager.getRawFileContent('config.json');
    const text = util.TextDecoder.create('utf-8').decodeToString(raw);
    session.configure(text);
    if (session.authenticated()) {
      this.loggedIn = true;
    }
  }

  // whoami → currentTenantId（契约可选字段缺失即抛——禁兜底，成员面无租户不可定位）；
  // 返回租户 ID 供后续分区（角色片）复用
  private async loadMembers(): Promise<string> {
    const me = await session.whoami();
    this.whoamiText = `${me.id}（租户 ${me.currentTenantId ?? '无'}）`;
    if (me.currentTenantId === undefined || me.currentTenantId === '') {
      throw new Error('whoami 缺 currentTenantId——无法定位租户成员面（fail-fast 禁兜底）');
    }
    // saas 分页 0 基（Spring Data Pageable；live 实证 page=1 空、page=0 有数据）
    const resp = await session.listMembers(me.currentTenantId, 0, 20);
    this.members = resp.items;
    this.memberTotal = resp.total;
    return me.currentTenantId;
  }

  // 角色列表（片3，只读）：同租户面 0 基分页
  private async loadRoles(tenantId: string): Promise<void> {
    const resp = await session.listRoles(tenantId, 0, 20);
    this.roles = resp.items;
    this.roleTotal = resp.total;
    this.grantText = '';
  }

  // 点角色拉已授权菜单（片3）：RoleMenuGrant.menuIds 计数展示
  private async loadRoleMenus(role: SysRole): Promise<void> {
    const me = await session.whoami();
    if (me.currentTenantId === undefined || me.currentTenantId === '') {
      throw new Error('whoami 缺 currentTenantId——无法定位角色菜单面（fail-fast 禁兜底）');
    }
    const grant = await session.listRoleMenus(me.currentTenantId, role.id);
    this.grantText = `${role.roleName} 已授权菜单 ${grant.menuIds.length} 个（${grant.updatedAt}）`;
  }

  // admin 只读双列表（片4）：租户 + OAuth 客户端，0 基分页；随后拉本租户订阅应用（片5）
  private async loadAdmin(tenantId: string): Promise<void> {
    const tenantsResp = await session.listTenants(0, 20);
    this.tenants = tenantsResp.items;
    this.tenantTotal = tenantsResp.total;
    const clientsResp = await session.listClients(0, 20);
    this.clients = clientsResp.items;
    this.clientTotal = clientsResp.total;
    const appsResp = await session.listTenantApplications(tenantId, 0, 20);
    this.apps = appsResp.items;
    this.appTotal = appsResp.total;
    this.menus = [];
    this.menuClientText = '';
  }

  // 点客户端拉公开信息 + 菜单扁平节点（片5）
  private async loadClientMenus(client: OAuthClient): Promise<void> {
    const info: OAuthClientPublicInfo = await session.getClientPublic(client.clientId);
    const menus = await session.listClientMenus(client.clientId);
    this.menus = menus;
    this.menuClientText = `${info.clientName}（${info.clientId}）菜单 ${menus.length} 个`;
  }

  // OAuth 三步流（片6）：authorize（state 回显校验）→ token 交换
  private async doOAuthFlow(): Promise<void> {
    const state = `hm-${Date.now()}`;
    const az = await session.oauthAuthorize(state);
    if (az.state !== state) {
      throw new Error(`OAuth state 回显不一致（${az.state} ≠ ${state}）——fail-fast 中止`);
    }
    const tk = await session.oauthToken(az.code);
    this.oauthText = `OAuth 三步流过：token ${tk.accessToken.slice(0, 8)}…（${tk.tokenType}，exp ${tk.expiresIn}s，rt ${tk.refreshToken.slice(0, 6)}…）`;
  }

  private async doLogin(): Promise<void> {
    if (this.busy) {
      return;
    }
    this.busy = true;
    this.message = '';
    try {
      await this.ensureConfigured();
      await session.login(this.username, this.password);
      const tenantId = await this.loadMembers();
      await this.loadRoles(tenantId);
      await this.loadAdmin(tenantId);
      this.loggedIn = true;
    } catch (err) {
      const apiErr = err as ApiError;
      if (apiErr.code !== undefined && apiErr.code !== '') {
        this.message = `登录失败：${apiErr.code} ${apiErr.message}`;
      } else {
        this.message = `登录失败：${(err as Error).message}`;
      }
    } finally {
      this.busy = false;
    }
  }

  private async doLogout(): Promise<void> {
    if (this.busy) {
      return;
    }
    this.busy = true;
    try {
      await session.logout();
    } catch (err) {
      this.message = `登出异常：${(err as Error).message}`;
    } finally {
      this.loggedIn = false;
      this.whoamiText = '';
      this.members = [];
      this.memberTotal = 0;
      this.roles = [];
      this.roleTotal = 0;
      this.grantText = '';
      this.tenants = [];
      this.tenantTotal = 0;
      this.clients = [];
      this.clientTotal = 0;
      this.apps = [];
      this.appTotal = 0;
      this.menus = [];
      this.menuClientText = '';
      this.oauthText = '';
      this.password = '';
      this.busy = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
      Text('saas 统一身份平台')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
      Text('HarmonyOS ArkTS（X14 槽）')
        .fontSize(13)
        .opacity(0.6)

      if (!this.loggedIn) {
        TextInput({ placeholder: '用户名', text: this.username })
          .width('80%')
          .onChange((v: string) => {
            this.username = v;
          })
        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .width('80%')
          .onChange((v: string) => {
            this.password = v;
          })
        Button(this.busy ? '登录中…' : '登录')
          .width('80%')
          .enabled(!this.busy)
          .onClick(() => {
            this.doLogin();
          })
      } else {
        Text(`已登录：${this.whoamiText}`)
          .fontSize(15)
        Text(`租户成员（共 ${this.memberTotal} 条）`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        if (this.members.length > 0) {
          List() {
            ForEach(this.members, (item: TenantMemberUserView) => {
              ListItem() {
                Column({ space: 2 }) {
                  Text(`${item.username}（${item.status}）`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                  Text(`角色 ${item.roleIds.length} 个 · ${item.email ?? '—'}`)
                    .fontSize(12)
                    .opacity(0.6)
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }
              .padding(6)
            }, (item: TenantMemberUserView) => item.id)
          }
          .width('88%')
          .height('40%')
        } else {
          Text('（无成员数据）')
            .fontSize(13)
            .opacity(0.6)
        }
        Text(`角色（共 ${this.roleTotal} 条，点选看授权菜单）`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        if (this.roles.length > 0) {
          List() {
            ForEach(this.roles, (item: SysRole) => {
              ListItem() {
                Column({ space: 2 }) {
                  Text(`${item.roleName}（${item.roleCode}）`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                  Text(`状态 ${item.status}${item.isPreset ? ' · 预置' : ''} · ${item.clientId}`)
                    .fontSize(12)
                    .opacity(0.6)
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }
              .padding(6)
              .onClick(() => {
                this.loadRoleMenus(item);
              })
            }, (item: SysRole) => item.id)
          }
          .width('88%')
          .height('22%')
        } else {
          Text('（无角色数据）')
            .fontSize(13)
            .opacity(0.6)
        }
        if (this.grantText !== '') {
          Text(this.grantText)
            .fontSize(13)
            .opacity(0.75)
        }
        Text(`租户（共 ${this.tenantTotal} 条）`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        List() {
          ForEach(this.tenants, (item: Tenant) => {
            ListItem() {
              Text(`${item.name}（${item.tenantKey} · ${item.status}）`)
                .fontSize(14)
                .width('100%')
            }
            .padding(4)
          }, (item: Tenant) => item.id)
        }
        .width('88%')
        .height(this.tenants.length > 4 ? '14%' : undefined)
        Text(`OAuth 客户端（共 ${this.clientTotal} 条）`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        List() {
          ForEach(this.clients, (item: OAuthClient) => {
            ListItem() {
              Column({ space: 2 }) {
                Text(`${item.clientName}（${item.clientId}）`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                Text(`状态 ${item.status} · token ${item.accessTokenValidity}s · 点选看菜单`)
                  .fontSize(12)
                  .opacity(0.6)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
            .padding(4)
            .onClick(() => {
              this.loadClientMenus(item);
            })
          }, (item: OAuthClient) => item.id)
        }
        .width('88%')
        .height(this.clients.length > 4 ? '14%' : undefined)
        if (this.menuClientText !== '') {
          Text(this.menuClientText)
            .fontSize(13)
            .opacity(0.75)
        }
        if (this.menus.length > 0) {
          List() {
            ForEach(this.menus, (item: SysMenu) => {
              ListItem() {
                Text(`${'　'.repeat(item.parentId === '' || item.parentId === '0' ? 0 : 1)}${item.title}（${item.type}）`)
                  .fontSize(13)
                  .width('100%')
              }
              .padding(3)
            }, (item: SysMenu) => item.id)
          }
          .width('88%')
          .height(this.menus.length > 4 ? '14%' : undefined)
        }
        Text(`租户应用（共 ${this.appTotal} 条）`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        List() {
          ForEach(this.apps, (item: TenantApplication) => {
            ListItem() {
              Text(`${item.clientId} · 状态 ${item.status}${item.expireTime !== undefined ? ` · 至 ${item.expireTime}` : ''}`)
                .fontSize(14)
                .width('100%')
            }
            .padding(4)
          }, (item: TenantApplication) => item.id)
        }
        .width('88%')
        .height(this.apps.length > 4 ? '14%' : undefined)
        Button('OAuth 三步流探针（authorize → token）')
          .width('80%')
          .enabled(!this.busy)
          .onClick(() => {
            this.doOAuthFlow();
          })
        if (this.oauthText !== '') {
          Text(this.oauthText)
            .fontSize(13)
            .opacity(0.75)
        }
        Button(this.busy ? '登出中…' : '登出')
          .width('80%')
          .enabled(!this.busy)
          .onClick(() => {
            this.doLogout();
          })
      }

      if (this.message !== '') {
        Text(this.message)
          .fontSize(13)
          .opacity(0.75)
      }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 24, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
  }
}

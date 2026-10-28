// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { RoleMenuGrant } from '../models/RoleMenuGrant';
import { SetSysRoleMenusRequest } from '../models/SetSysRoleMenusRequest';

export class TenantRoleMenusApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  clearSysRoleMenus(tenantId: string, roleId: string, clientId?: string): Promise<void> {
    let query: Map<string, string> = new Map<string, string>();
    if (clientId !== undefined) {
      query.set('clientId', String(clientId));
    }
    let options: RequestOptions = { method: 'DELETE', path: `/api/v1/tenants/${tenantId}/roles/${roleId}/menus`, query: query };
    return this.client.requestVoid(options);
  }

  listSysRoleMenus(tenantId: string, roleId: string, clientId?: string): Promise<RoleMenuGrant> {
    let query: Map<string, string> = new Map<string, string>();
    if (clientId !== undefined) {
      query.set('clientId', String(clientId));
    }
    let options: RequestOptions = { method: 'GET', path: `/api/v1/tenants/${tenantId}/roles/${roleId}/menus`, query: query };
    return this.client.request<RoleMenuGrant>(options);
  }

  setSysRoleMenus(tenantId: string, roleId: string, req: SetSysRoleMenusRequest, clientId?: string): Promise<RoleMenuGrant> {
    let query: Map<string, string> = new Map<string, string>();
    if (clientId !== undefined) {
      query.set('clientId', String(clientId));
    }
    let options: RequestOptions = { method: 'PUT', path: `/api/v1/tenants/${tenantId}/roles/${roleId}/menus`, query: query, body: req };
    return this.client.request<RoleMenuGrant>(options);
  }
}

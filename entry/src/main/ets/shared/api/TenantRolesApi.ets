// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { CreateSysRoleRequest } from '../models/CreateSysRoleRequest';
import { SysRole } from '../models/SysRole';
import { TenantRolesListSysRolesResponse } from '../models/TenantRolesListSysRolesResponse';
import { UpdateSysRoleRequest } from '../models/UpdateSysRoleRequest';

export class TenantRolesApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  createSysRole(tenantId: string, req: CreateSysRoleRequest): Promise<SysRole> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/tenants/${tenantId}/roles`, body: req };
    return this.client.request<SysRole>(options);
  }

  deleteSysRole(tenantId: string, roleId: string): Promise<void> {
    let options: RequestOptions = { method: 'DELETE', path: `/api/v1/tenants/${tenantId}/roles/${roleId}` };
    return this.client.requestVoid(options);
  }

  getSysRole(tenantId: string, roleId: string): Promise<SysRole> {
    let options: RequestOptions = { method: 'GET', path: `/api/v1/tenants/${tenantId}/roles/${roleId}` };
    return this.client.request<SysRole>(options);
  }

  listSysRoles(tenantId: string, clientId?: string, page?: number, pageSize?: number): Promise<TenantRolesListSysRolesResponse> {
    let query: Map<string, string> = new Map<string, string>();
    if (clientId !== undefined) {
      query.set('clientId', String(clientId));
    }
    if (page !== undefined) {
      query.set('page', String(page));
    }
    if (pageSize !== undefined) {
      query.set('pageSize', String(pageSize));
    }
    let options: RequestOptions = { method: 'GET', path: `/api/v1/tenants/${tenantId}/roles`, query: query };
    return this.client.request<TenantRolesListSysRolesResponse>(options);
  }

  updateSysRole(tenantId: string, roleId: string, req: UpdateSysRoleRequest): Promise<SysRole> {
    let options: RequestOptions = { method: 'PATCH', path: `/api/v1/tenants/${tenantId}/roles/${roleId}`, body: req };
    return this.client.request<SysRole>(options);
  }
}

// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { CreateSysUserRequest } from '../models/CreateSysUserRequest';
import { SetTenantMemberRolesRequest } from '../models/SetTenantMemberRolesRequest';
import { TenantMemberStatus } from '../models/TenantMemberStatus';
import { TenantMemberUserView } from '../models/TenantMemberUserView';
import { TenantMemberView } from '../models/TenantMemberView';
import { TenantMembersChangeTenantUserStatusRequest } from '../models/TenantMembersChangeTenantUserStatusRequest';
import { TenantMembersInviteTenantUserRequest } from '../models/TenantMembersInviteTenantUserRequest';
import { TenantMembersListTenantUsersResponse } from '../models/TenantMembersListTenantUsersResponse';
import { UpdateSysUserRequest } from '../models/UpdateSysUserRequest';

export class TenantMembersApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  assignTenantMemberRoles(tenantId: string, userId: string, req: SetTenantMemberRolesRequest): Promise<TenantMemberUserView> {
    let options: RequestOptions = { method: 'PUT', path: `/api/v1/tenants/${tenantId}/members/${userId}/roles`, body: req };
    return this.client.request<TenantMemberUserView>(options);
  }

  changeTenantUserStatus(tenantId: string, userId: string, req: TenantMembersChangeTenantUserStatusRequest): Promise<TenantMemberUserView> {
    let options: RequestOptions = { method: 'PATCH', path: `/api/v1/tenants/${tenantId}/members/${userId}/status`, body: req };
    return this.client.request<TenantMemberUserView>(options);
  }

  createTenantUser(tenantId: string, req: CreateSysUserRequest): Promise<TenantMemberUserView> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/tenants/${tenantId}/members`, body: req };
    return this.client.request<TenantMemberUserView>(options);
  }

  deleteTenantUser(tenantId: string, userId: string): Promise<void> {
    let options: RequestOptions = { method: 'DELETE', path: `/api/v1/tenants/${tenantId}/members/${userId}` };
    return this.client.requestVoid(options);
  }

  getTenantUser(tenantId: string, userId: string): Promise<TenantMemberUserView> {
    let options: RequestOptions = { method: 'GET', path: `/api/v1/tenants/${tenantId}/members/${userId}` };
    return this.client.request<TenantMemberUserView>(options);
  }

  inviteTenantUser(tenantId: string, req: TenantMembersInviteTenantUserRequest): Promise<TenantMemberView> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/tenants/${tenantId}/members/invitations`, body: req };
    return this.client.request<TenantMemberView>(options);
  }

  listTenantUsers(tenantId: string, page?: number, pageSize?: number, status?: TenantMemberStatus): Promise<TenantMembersListTenantUsersResponse> {
    let query: Map<string, string> = new Map<string, string>();
    if (page !== undefined) {
      query.set('page', String(page));
    }
    if (pageSize !== undefined) {
      query.set('pageSize', String(pageSize));
    }
    if (status !== undefined) {
      query.set('status', String(status));
    }
    let options: RequestOptions = { method: 'GET', path: `/api/v1/tenants/${tenantId}/members`, query: query };
    return this.client.request<TenantMembersListTenantUsersResponse>(options);
  }

  updateTenantUser(tenantId: string, userId: string, req: UpdateSysUserRequest): Promise<TenantMemberUserView> {
    let options: RequestOptions = { method: 'PATCH', path: `/api/v1/tenants/${tenantId}/members/${userId}`, body: req };
    return this.client.request<TenantMemberUserView>(options);
  }
}

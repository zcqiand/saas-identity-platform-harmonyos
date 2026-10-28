// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { AdminTenantsListTenantsResponse } from '../models/AdminTenantsListTenantsResponse';
import { CreateTenantRequest } from '../models/CreateTenantRequest';
import { Tenant } from '../models/Tenant';
import { UpdateTenantRequest } from '../models/UpdateTenantRequest';

export class AdminTenantsApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  createTenant(req: CreateTenantRequest): Promise<Tenant> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/admin/tenants`, body: req };
    return this.client.request<Tenant>(options);
  }

  deleteTenant(id: string): Promise<void> {
    let options: RequestOptions = { method: 'DELETE', path: `/api/v1/admin/tenants/${id}` };
    return this.client.requestVoid(options);
  }

  getTenant(id: string): Promise<Tenant> {
    let options: RequestOptions = { method: 'GET', path: `/api/v1/admin/tenants/${id}` };
    return this.client.request<Tenant>(options);
  }

  listTenants(page?: number, pageSize?: number): Promise<AdminTenantsListTenantsResponse> {
    let query: Map<string, string> = new Map<string, string>();
    if (page !== undefined) {
      query.set('page', String(page));
    }
    if (pageSize !== undefined) {
      query.set('pageSize', String(pageSize));
    }
    let options: RequestOptions = { method: 'GET', path: `/api/v1/admin/tenants`, query: query };
    return this.client.request<AdminTenantsListTenantsResponse>(options);
  }

  updateTenant(id: string, req: UpdateTenantRequest): Promise<Tenant> {
    let options: RequestOptions = { method: 'PATCH', path: `/api/v1/admin/tenants/${id}`, body: req };
    return this.client.request<Tenant>(options);
  }
}

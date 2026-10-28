// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { SubscribeTenantApplicationRequest } from '../models/SubscribeTenantApplicationRequest';
import { TenantApplication } from '../models/TenantApplication';
import { TenantApplicationsListTenantApplicationsResponse } from '../models/TenantApplicationsListTenantApplicationsResponse';
import { UpdateTenantApplicationRequest } from '../models/UpdateTenantApplicationRequest';

export class TenantApplicationsApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  listTenantApplications(tenantId: string, page?: number, pageSize?: number): Promise<TenantApplicationsListTenantApplicationsResponse> {
    let query: Map<string, string> = new Map<string, string>();
    if (page !== undefined) {
      query.set('page', String(page));
    }
    if (pageSize !== undefined) {
      query.set('pageSize', String(pageSize));
    }
    let options: RequestOptions = { method: 'GET', path: `/api/v1/tenants/${tenantId}/applications`, query: query };
    return this.client.request<TenantApplicationsListTenantApplicationsResponse>(options);
  }

  removeTenantApplication(tenantId: string, clientId: string): Promise<void> {
    let options: RequestOptions = { method: 'DELETE', path: `/api/v1/tenants/${tenantId}/applications/${clientId}` };
    return this.client.requestVoid(options);
  }

  subscribeTenantApplication(tenantId: string, req: SubscribeTenantApplicationRequest): Promise<TenantApplication> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/tenants/${tenantId}/applications`, body: req };
    return this.client.request<TenantApplication>(options);
  }

  updateTenantApplication(tenantId: string, clientId: string, req: UpdateTenantApplicationRequest): Promise<TenantApplication> {
    let options: RequestOptions = { method: 'PATCH', path: `/api/v1/tenants/${tenantId}/applications/${clientId}`, body: req };
    return this.client.request<TenantApplication>(options);
  }
}

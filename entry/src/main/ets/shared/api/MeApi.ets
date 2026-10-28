// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { CurrentUser } from '../models/CurrentUser';
import { MeGetMyMenusResponse } from '../models/MeGetMyMenusResponse';
import { MeListMyTenantsResponse } from '../models/MeListMyTenantsResponse';
import { SwitchTenantResponse } from '../models/SwitchTenantResponse';

export class MeApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  getMyMenus(clientId?: string): Promise<MeGetMyMenusResponse> {
    let query: Map<string, string> = new Map<string, string>();
    if (clientId !== undefined) {
      query.set('clientId', String(clientId));
    }
    let options: RequestOptions = { method: 'GET', path: `/api/v1/me/menus`, query: query };
    return this.client.request<MeGetMyMenusResponse>(options);
  }

  listMyTenants(clientId?: string): Promise<MeListMyTenantsResponse> {
    let query: Map<string, string> = new Map<string, string>();
    if (clientId !== undefined) {
      query.set('clientId', String(clientId));
    }
    let options: RequestOptions = { method: 'GET', path: `/api/v1/me/tenants`, query: query };
    return this.client.request<MeListMyTenantsResponse>(options);
  }

  switchTenant(tenantId: string, clientId?: string): Promise<SwitchTenantResponse> {
    let query: Map<string, string> = new Map<string, string>();
    if (clientId !== undefined) {
      query.set('clientId', String(clientId));
    }
    let options: RequestOptions = { method: 'POST', path: `/api/v1/me/tenants/${tenantId}/switch`, query: query };
    return this.client.request<SwitchTenantResponse>(options);
  }

  whoami(): Promise<CurrentUser> {
    let options: RequestOptions = { method: 'GET', path: `/api/v1/me` };
    return this.client.request<CurrentUser>(options);
  }
}

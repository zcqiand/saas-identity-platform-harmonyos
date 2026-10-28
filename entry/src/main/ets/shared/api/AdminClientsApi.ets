// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { AdminClientsListClientsResponse } from '../models/AdminClientsListClientsResponse';
import { AdminClientsSetClientStatusRequest } from '../models/AdminClientsSetClientStatusRequest';
import { CreateOAuthClientRequest } from '../models/CreateOAuthClientRequest';
import { OAuthClient } from '../models/OAuthClient';
import { UpdateOAuthClientRequest } from '../models/UpdateOAuthClientRequest';

export class AdminClientsApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  createClient(req: CreateOAuthClientRequest): Promise<OAuthClient> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/admin/clients`, body: req };
    return this.client.request<OAuthClient>(options);
  }

  deleteClient(clientId: string): Promise<void> {
    let options: RequestOptions = { method: 'DELETE', path: `/api/v1/admin/clients/${clientId}` };
    return this.client.requestVoid(options);
  }

  getClient(clientId: string): Promise<OAuthClient> {
    let options: RequestOptions = { method: 'GET', path: `/api/v1/admin/clients/${clientId}` };
    return this.client.request<OAuthClient>(options);
  }

  listClients(page?: number, pageSize?: number): Promise<AdminClientsListClientsResponse> {
    let query: Map<string, string> = new Map<string, string>();
    if (page !== undefined) {
      query.set('page', String(page));
    }
    if (pageSize !== undefined) {
      query.set('pageSize', String(pageSize));
    }
    let options: RequestOptions = { method: 'GET', path: `/api/v1/admin/clients`, query: query };
    return this.client.request<AdminClientsListClientsResponse>(options);
  }

  setClientStatus(clientId: string, req: AdminClientsSetClientStatusRequest): Promise<OAuthClient> {
    let options: RequestOptions = { method: 'PATCH', path: `/api/v1/admin/clients/${clientId}/status`, body: req };
    return this.client.request<OAuthClient>(options);
  }

  updateClient(clientId: string, req: UpdateOAuthClientRequest): Promise<OAuthClient> {
    let options: RequestOptions = { method: 'PATCH', path: `/api/v1/admin/clients/${clientId}`, body: req };
    return this.client.request<OAuthClient>(options);
  }
}

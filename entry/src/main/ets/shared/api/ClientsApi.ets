// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { OAuthClientPublicInfo } from '../models/OAuthClientPublicInfo';

export class ClientsApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  getClient(clientId: string): Promise<OAuthClientPublicInfo> {
    let options: RequestOptions = { method: 'GET', path: `/api/v1/clients/${clientId}` };
    return this.client.request<OAuthClientPublicInfo>(options);
  }
}

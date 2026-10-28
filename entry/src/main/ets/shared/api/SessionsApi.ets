// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { LoginRequest } from '../models/LoginRequest';
import { LoginResponse } from '../models/LoginResponse';

export class SessionsApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  login(req: LoginRequest): Promise<LoginResponse> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/auth/login`, body: req };
    return this.client.request<LoginResponse>(options);
  }

  logout(): Promise<void> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/auth/logout` };
    return this.client.requestVoid(options);
  }
}

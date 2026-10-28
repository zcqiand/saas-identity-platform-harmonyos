// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { AuthorizeCodeRequest } from '../models/AuthorizeCodeRequest';
import { OAuthAuthorizeResponse } from '../models/OAuthAuthorizeResponse';
import { TokenRequest } from '../models/TokenRequest';
import { TokenResponse } from '../models/TokenResponse';

export class OAuthApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  authorize(req: AuthorizeCodeRequest): Promise<OAuthAuthorizeResponse> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/oauth/authorize`, body: req };
    return this.client.request<OAuthAuthorizeResponse>(options);
  }

  token(req: TokenRequest): Promise<TokenResponse> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/oauth/token`, body: req };
    return this.client.request<TokenResponse>(options);
  }
}

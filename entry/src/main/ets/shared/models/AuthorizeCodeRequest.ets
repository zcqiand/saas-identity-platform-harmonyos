// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { AuthorizeCodeRequestResponseType } from './AuthorizeCodeRequestResponseType';

export interface AuthorizeCodeRequest {
  clientId: string;
  redirectUri: string;
  responseType: AuthorizeCodeRequestResponseType;
  scope?: string;
  state: string;
}

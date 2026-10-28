// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

export interface OAuthClient {
  id: string;
  clientId: string;
  clientName: string;
  grantTypes: string;
  redirectUris: string;
  scopes?: string;
  accessTokenValidity: number;
  refreshTokenValidity: number;
  autoApprove: boolean;
  status: number;
  createdAt: string;
  updatedAt: string;
}

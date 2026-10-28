// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

export interface CreateOAuthClientRequest {
  clientId: string;
  clientName: string;
  clientSecret: string;
  grantTypes: string;
  redirectUris: string;
  scopes?: string;
  accessTokenValidity?: number;
  refreshTokenValidity?: number;
  autoApprove?: boolean;
}

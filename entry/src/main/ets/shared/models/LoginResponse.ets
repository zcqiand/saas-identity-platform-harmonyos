// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { SysUser } from './SysUser';
import { TenantMembership } from './TenantMembership';

export interface LoginResponse {
  user: SysUser;
  availableTenants: Array<TenantMembership>;
  userId: string;
  currentTenantId?: string;
  accessToken?: string;
  refreshToken?: string;
  tokenType?: string;
  expiresIn?: number;
  clientId: string;
}

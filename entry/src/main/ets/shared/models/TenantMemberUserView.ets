// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { TenantMemberStatus } from './TenantMemberStatus';

export interface TenantMemberUserView {
  id: string;
  tenantId: string;
  username: string;
  email?: string;
  status: TenantMemberStatus;
  roleIds: Array<string>;
  createdAt: string;
  updatedAt: string;
}

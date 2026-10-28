// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { TenantMemberStatus } from './TenantMemberStatus';

export interface TenantMember {
  id: string;
  tenantId: string;
  userId: string;
  memberName?: string;
  isOwner: boolean;
  status: TenantMemberStatus;
  createdAt: string;
  updatedAt: string;
}

// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { TenantStatus } from './TenantStatus';

export interface Tenant {
  id: string;
  tenantKey: string;
  name: string;
  status: TenantStatus;
  createdAt: string;
  updatedAt: string;
}

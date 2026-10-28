// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { SysUserStatus } from './SysUserStatus';

export interface SysUser {
  id: string;
  username: string;
  email?: string;
  mobile?: string;
  status: SysUserStatus;
  failedAttempts?: number;
  lockedUntil?: string;
  createdAt: string;
  updatedAt: string;
}

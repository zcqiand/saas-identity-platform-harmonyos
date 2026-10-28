// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { SysUser } from './SysUser';
import { TenantMember } from './TenantMember';

export interface TenantMemberView {
  member: TenantMember;
  user: SysUser;
  roles: Array<string>;
}

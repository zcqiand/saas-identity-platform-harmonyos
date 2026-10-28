// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { SysMenuType } from './SysMenuType';

export interface CreateSysMenuRequest {
  parentId?: string;
  title: string;
  type: SysMenuType;
  path?: string;
  component?: string;
  perms?: string;
  icon?: string;
  sortOrder?: number;
}

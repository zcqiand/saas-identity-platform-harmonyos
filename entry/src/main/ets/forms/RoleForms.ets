// 角色写流纯表单装配（M00.F03.I02 创建 / I05 删除，2026-10-31 人批业务 ID 锚）。
// 只做字符串进 → 请求模型出的纯变换（trim + 必填 fail-fast），不触 runtime/@ohos
// ——Session 持有它，本地单测直测本文件。I04 更新走 PATCH（runtime @ohos 无 PATCH，
// X-HTTP-Method-Override 届时立项）故本模块只盖 create/delete。
import { CreateSysRoleRequest } from '../shared/models/CreateSysRoleRequest';

// 表单面 = UI TextInput 原文（全 string）；description '' = 不带
export interface RoleForm {
  clientId: string;
  roleCode: string;
  roleName: string;
  description: string;
}

function required(value: string, label: string): string {
  const t = value.trim();
  if (t.length === 0) {
    throw new Error(`角色 ${label} 必填（fail-fast，禁空串入请求）`);
  }
  return t;
}

export function assembleCreateRole(form: RoleForm): CreateSysRoleRequest {
  const req: CreateSysRoleRequest = {
    clientId: required(form.clientId, '应用 clientId'),
    roleCode: required(form.roleCode, '角色编码'),
    roleName: required(form.roleName, '角色名称')
  };
  const desc = form.description.trim();
  if (desc.length > 0) {
    req.description = desc;
  }
  return req;
}

// 删除守卫：roleId trim 后非空（M00.F03.I05）
export function ensureRoleId(roleId: string): string {
  const t = roleId.trim();
  if (t.length === 0) {
    throw new Error('角色 id 必填（fail-fast，禁空 id 入请求）');
  }
  return t;
}

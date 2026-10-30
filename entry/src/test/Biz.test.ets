// 业务测试（首个带业务 ID 锚的测试面，人批 2026-10-31）：角色创建/删除写流
// （M00.F03.I02 创建 / I05 删除；I04 更新走 PATCH，runtime @ohos 无 PATCH 挂账不接）。
// 只 import 纯表单装配模块 + 生成模型（不触 runtime/@ohos），本地单测无设备依赖。
import { describe, it, expect } from '@ohos/hypium';
import { RoleForm, assembleCreateRole, ensureRoleId } from '../main/ets/forms/RoleForms';

export function roleCreateSuite(): void {
  describe('role_create_form', () => {
    // fn: M00.F03.I02
    it('create role assembles required fields trimmed', 0, () => {
      let f: RoleForm = {
        clientId: 'saas-console',
        roleCode: ' op-manager ',
        roleName: ' 运维管理员 ',
        description: ''
      };
      let req = assembleCreateRole(f);
      expect(req.clientId).assertEqual('saas-console');
      expect(req.roleCode).assertEqual('op-manager');
      expect(req.roleName).assertEqual('运维管理员');
    });
    // fn: M00.F03.I02
    it('create role carries description only when filled', 0, () => {
      let f: RoleForm = {
        clientId: 'saas-console', roleCode: 'r1', roleName: '角色一', description: ''
      };
      let reqWithout = assembleCreateRole(f);
      expect(reqWithout.description).assertUndefined();
      f.description = ' 说明文本 ';
      let reqWith = assembleCreateRole(f);
      expect(reqWith.description).assertEqual('说明文本');
    });
    // fn: M00.F03.I02
    it('create role throws when any required field is blank（fail-fast 禁空串入请求）', 0, () => {
      let full: RoleForm = {
        clientId: 'saas-console', roleCode: 'r1', roleName: '角色一', description: ''
      };
      let codes: string[] = ['clientId', 'roleCode', 'roleName'];
      for (let i = 0; i < codes.length; i++) {
        let f: RoleForm = {
          clientId: full.clientId, roleCode: full.roleCode,
          roleName: full.roleName, description: full.description
        };
        blankRoleField(f, codes[i]);
        let threw = false;
        try {
          assembleCreateRole(f);
        } catch {
          threw = true;
        }
        expect(threw).assertTrue();
      }
    });
  });
}

export function roleDeleteSuite(): void {
  describe('role_delete_guard', () => {
    // fn: M00.F03.I05
    it('delete role accepts non-empty id trimmed', 0, () => {
      expect(ensureRoleId('  role-9  ')).assertEqual('role-9');
    });
    // fn: M00.F03.I05
    it('delete role throws on blank id（fail-fast）', 0, () => {
      let threwBlank = false;
      let threwWs = false;
      try {
        ensureRoleId('');
      } catch {
        threwBlank = true;
      }
      try {
        ensureRoleId('   ');
      } catch {
        threwWs = true;
      }
      expect(threwBlank).assertTrue();
      expect(threwWs).assertTrue();
    });
  });
}

// 按字段名置空（测试专用：ArkTS 无 dynamic pick，逐字段 if 链）
function blankRoleField(f: RoleForm, field: string): void {
  if (field === 'clientId') {
    f.clientId = '';
  } else if (field === 'roleCode') {
    f.roleCode = '';
  } else if (field === 'roleName') {
    f.roleName = '';
  }
}

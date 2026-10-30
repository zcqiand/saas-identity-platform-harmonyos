// 入口 Ability：只挂 Index 页（六片全接线：登录/成员/角色/admin/应用菜单/OAuth）。
// [shared 触碰] 已清空——11 个生成 Api 类全部由页面/会话消费（ArkTS 编译图 = import 闭包，
// import 面即编译面）：SessionsApi/MeApi 由 session/Session.ets+登录片，TenantMembersApi
// 成员片，TenantRolesApi+TenantRoleMenusApi 角色片，AdminTenantsApi+AdminClientsApi
// admin 片，TenantApplicationsApi+ClientsApi+ClientMenusApi 应用菜单片，OAuthApi OAuth 片。
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

// [shared 触碰] 全量消费后清空（留位：后续新 Api 类接线前的编译覆盖占位）。
const __SHARED_TOUCH__: Array<Object> = [];
void __SHARED_TOUCH__;

const DOMAIN: number = 0x0000;
const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, '%{public}s', 'loadContent ok');
    });
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}

// 登录页（Phase 1 首业务消费切片）：SessionsApi.login → SessionState → MeApi.whoami。
// base URL 走 rawfile config.json（AppConfig fail-fast，禁默认值兜底）；
// 错误显示 ApiError 的 code+message（后端错误包络，runtime 统一解包）。
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { ApiError } from 'harmonyos-api-runtime';
import { session } from '../session/Session';

@Entry
@Component
struct Index {
  @State username: string = '';
  @State password: string = '';
  @State message: string = 'saas 统一身份平台（HarmonyOS ArkTS 版）';
  @State busy: boolean = false;
  @State loggedIn: boolean = false;
  @State whoamiText: string = '';

  private async ensureConfigured(): Promise<void> {
    if (this.loggedIn) {
      return;
    }
    const ctx = getContext(this) as common.UIAbilityContext;
    const raw = await ctx.resourceManager.getRawFileContent('config.json');
    const text = util.TextDecoder.create('utf-8').decodeToString(raw);
    session.configure(text);
    if (session.authenticated()) {
      this.loggedIn = true;
    }
  }

  private async doLogin(): Promise<void> {
    if (this.busy) {
      return;
    }
    this.busy = true;
    this.message = '';
    try {
      await this.ensureConfigured();
      await session.login(this.username, this.password);
      const me = await session.whoami();
      this.whoamiText = `${me.id}（租户 ${me.currentTenantId ?? '无'}）`;
      this.loggedIn = true;
    } catch (err) {
      const apiErr = err as ApiError;
      if (apiErr.code !== undefined && apiErr.code !== '') {
        this.message = `登录失败：${apiErr.code} ${apiErr.message}`;
      } else {
        this.message = `登录失败：${(err as Error).message}`;
      }
    } finally {
      this.busy = false;
    }
  }

  private async doLogout(): Promise<void> {
    if (this.busy) {
      return;
    }
    this.busy = true;
    try {
      await session.logout();
    } catch (err) {
      this.message = `登出异常：${(err as Error).message}`;
    } finally {
      this.loggedIn = false;
      this.whoamiText = '';
      this.password = '';
      this.busy = false;
    }
  }

  build() {
    Column({ space: 12 }) {
      Text('saas 统一身份平台')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
      Text('HarmonyOS ArkTS（X14 槽）')
        .fontSize(13)
        .opacity(0.6)

      if (!this.loggedIn) {
        TextInput({ placeholder: '用户名', text: this.username })
          .width('80%')
          .onChange((v: string) => {
            this.username = v;
          })
        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .width('80%')
          .onChange((v: string) => {
            this.password = v;
          })
        Button(this.busy ? '登录中…' : '登录')
          .width('80%')
          .enabled(!this.busy)
          .onClick(() => {
            this.doLogin();
          })
      } else {
        Text(`已登录：${this.whoamiText}`)
          .fontSize(15)
        Button(this.busy ? '登出中…' : '登出')
          .width('80%')
          .enabled(!this.busy)
          .onClick(() => {
            this.doLogout();
          })
      }

      if (this.message !== '') {
        Text(this.message)
          .fontSize(13)
          .opacity(0.75)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

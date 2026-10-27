// 骨架期首页：只证 HAP 形状与构建链，不消费任何业务面。
@Entry
@Component
struct Index {
  @State message: string = 'saas 统一身份平台（HarmonyOS ArkTS 版）';

  build() {
    Column() {
      Text(this.message)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
      Text('HarmonyOS ArkTS 骨架（X14 槽）——Phase 1 接线前无业务面')
        .fontSize(14)
        .opacity(0.6)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

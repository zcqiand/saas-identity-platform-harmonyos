// Hypium 本地单测入口：suite 聚合。锚点适配器（scripts/trace-test.mjs）扫
// entry/src/test 全部 it(...)，本文件只做装配。
import { fnSuite } from './Fn.test';

export default function testsuite(): void {
  fnSuite();
}

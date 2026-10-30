// 过程件（_work/）：saas harmonyos 成员列表片 live 探针。
// 链路：POST /api/v1/auth/login（clientId=saas-console）→ GET /api/v1/me（取 currentTenantId）
//       → GET /api/v1/tenants/{tenantId}/members?page=1&pageSize=20（Bearer，生成面
//         TenantMembersApi.listTenantUsers 同形状）。
// 单次正确凭据尝试（lockout 429 雪崩纪律，REQ-2026-023）。
const BASE = process.argv[2] ?? 'http://127.0.0.1:51051';

const post = async (path, body) => {
  const r = await fetch(BASE + path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const text = await r.text();
  let json = null;
  try { json = text === '' ? null : JSON.parse(text); } catch { json = text; }
  return { status: r.status, json };
};
const get = async (path, headers = {}) => {
  const r = await fetch(BASE + path, { headers });
  return { status: r.status, json: await r.json().catch(() => null) };
};

// 1. login
const login = await post('/api/v1/auth/login', {
  username: 'alice', password: 'dev123456', clientId: 'saas-console'
});
console.log('login:', login.status, 'accessToken?',
  typeof login.json?.accessToken === 'string' && login.json.accessToken.length > 0);
if (login.status !== 200 || !login.json?.accessToken) {
  console.log('login body:', JSON.stringify(login.json)?.slice(0, 400));
  process.exit(1);
}
const auth = { Authorization: `Bearer ${login.json.accessToken}` };

// 2. whoami → currentTenantId（页面同款 fail-fast：缺失即失败）
const me = await get('/api/v1/me', auth);
console.log('me:', me.status, 'id:', me.json?.id, 'currentTenantId:', me.json?.currentTenantId);
if (me.status !== 200 || !me.json?.currentTenantId) {
  console.log('me body:', JSON.stringify(me.json)?.slice(0, 400));
  process.exit(1);
}

// 3. members 列表（path 参数 + 分页 query，生成面同形状；saas 分页 0 基——Spring Data）
const members = await get(
  `/api/v1/tenants/${me.json.currentTenantId}/members?page=0&pageSize=20`, auth);
console.log('members:', members.status, 'total:', members.json?.total,
  'items:', Array.isArray(members.json?.items) ? members.json.items.length : 'N/A');
const first = members.json?.items?.[0];
console.log('first item fields:', first ? Object.keys(first).join(',') : '(empty)');

const ok = members.status === 200 && Array.isArray(members.json?.items);
console.log(ok ? 'PROBE PASS' : 'PROBE FAIL');
process.exit(ok ? 0 : 1);

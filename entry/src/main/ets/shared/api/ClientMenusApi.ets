// 本文件由 harmonyos-api-gen 生成，禁手改；regen 先删后写（幂等字节级，无时间戳）。

import { ApiClient, RequestOptions } from 'harmonyos-api-runtime';
import { ClientMenusListSysMenusResponse } from '../models/ClientMenusListSysMenusResponse';
import { ClientMenusMoveSysMenuRequest } from '../models/ClientMenusMoveSysMenuRequest';
import { ClientMenusReorderSysMenusResponse } from '../models/ClientMenusReorderSysMenusResponse';
import { CreateSysMenuRequest } from '../models/CreateSysMenuRequest';
import { ReorderSysMenuRequest } from '../models/ReorderSysMenuRequest';
import { SysMenu } from '../models/SysMenu';
import { UpdateSysMenuRequest } from '../models/UpdateSysMenuRequest';

export class ClientMenusApi {
  private client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  createSysMenu(clientId: string, req: CreateSysMenuRequest): Promise<SysMenu> {
    let options: RequestOptions = { method: 'POST', path: `/api/v1/clients/${clientId}/menus`, body: req };
    return this.client.request<SysMenu>(options);
  }

  deleteSysMenu(clientId: string, menuId: string): Promise<void> {
    let options: RequestOptions = { method: 'DELETE', path: `/api/v1/clients/${clientId}/menus/${menuId}` };
    return this.client.requestVoid(options);
  }

  getSysMenu(clientId: string, menuId: string): Promise<SysMenu> {
    let options: RequestOptions = { method: 'GET', path: `/api/v1/clients/${clientId}/menus/${menuId}` };
    return this.client.request<SysMenu>(options);
  }

  listSysMenus(clientId: string): Promise<ClientMenusListSysMenusResponse> {
    let options: RequestOptions = { method: 'GET', path: `/api/v1/clients/${clientId}/menus` };
    return this.client.request<ClientMenusListSysMenusResponse>(options);
  }

  moveSysMenu(clientId: string, menuId: string, req: ClientMenusMoveSysMenuRequest): Promise<SysMenu> {
    let options: RequestOptions = { method: 'PATCH', path: `/api/v1/clients/${clientId}/menus/${menuId}/parent`, body: req };
    return this.client.request<SysMenu>(options);
  }

  reorderSysMenus(clientId: string, menuId: string, req: ReorderSysMenuRequest): Promise<ClientMenusReorderSysMenusResponse> {
    let options: RequestOptions = { method: 'PUT', path: `/api/v1/clients/${clientId}/menus/${menuId}/reorder`, body: req };
    return this.client.request<ClientMenusReorderSysMenusResponse>(options);
  }

  updateSysMenu(clientId: string, menuId: string, req: UpdateSysMenuRequest): Promise<SysMenu> {
    let options: RequestOptions = { method: 'PATCH', path: `/api/v1/clients/${clientId}/menus/${menuId}`, body: req };
    return this.client.request<SysMenu>(options);
  }
}

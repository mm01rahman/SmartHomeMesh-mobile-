export type DeviceType = 'light' | 'fan' | 'socket' | 'generic';

export interface Device {
  id: string;
  type: DeviceType;
  label: string;
  st: number;
}

export interface NodeInfo {
  nodeId: string;
  devices: Device[];
}

export interface JoinPayload {
  t: 'join';
  node_id: string;
  devs: Array<{ id: string; type: DeviceType; label: string; st: number }>;
}

export interface StatusPayload {
  node_id?: string;
  devs: Array<{ id: string; st: number }>;
}

export interface CommandPayload {
  dev: string;
  st: number;
}

export type ConnectivityMode = 'CLOUD_MQTT' | 'LAN_HTTP' | 'AP_MESH_HTTP' | 'OFFLINE';

export interface SceneAction {
  dev: string;
  st: number;
}

export interface Scene {
  id: string;
  name: string;
  actions: SceneAction[];
}

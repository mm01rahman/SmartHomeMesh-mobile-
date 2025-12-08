export interface Device {
  id: number;
  nodeId: string;
  localId: string;
  type: string;
  label: string;
  firmwareLabel?: string;
  roomId?: number | null;
  homeId?: number | null;
  currentState?: number | null;
}

export interface Node {
  id: number;
  nodeId: string;
  name: string;
  onlineStatus: 'ONLINE' | 'OFFLINE' | 'UNKNOWN';
  lastSeenAt?: string | null;
  homeId?: number | null;
  devices: Device[];
}

export interface Room {
  id: number;
  homeId: number;
  name: string;
}

export interface SceneActionDto {
  deviceId: number;
  desiredState: number;
}

export interface Scene {
  id: number;
  homeId: number;
  name: string;
  actions: SceneActionDto[];
}

export interface Home {
  id: number;
  name: string;
  timezone: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
}

import { create } from 'zustand';
import { ConnectivityMode } from '../types';

type ConnectivityState = {
  mqttConnected: boolean;
  httpReachable: boolean;
  apMode: boolean;
  everCloudSeen: boolean;
  connectivityMode: ConnectivityMode;
  setMqttConnected: (connected: boolean) => void;
  setHttpReachable: (reachable: boolean) => void;
  setApMode: (apMode: boolean) => void;
  setConnectivityMode: (mode: ConnectivityMode) => void;
};

const deriveMode = (state: Pick<ConnectivityState, 'mqttConnected' | 'httpReachable' | 'apMode'>): ConnectivityMode => {
  if (state.mqttConnected) return 'CLOUD_MQTT';
  if (state.httpReachable && state.apMode) return 'AP_MESH_HTTP';
  if (state.httpReachable) return 'LAN_HTTP';
  return 'OFFLINE';
};

export const useConnectivityStore = create<ConnectivityState>((set) => ({
  mqttConnected: false,
  httpReachable: false,
  apMode: false,
  everCloudSeen: false,
  connectivityMode: 'OFFLINE',
  setMqttConnected: (connected) =>
    set((state) => ({
      mqttConnected: connected,
      everCloudSeen: state.everCloudSeen || connected,
      connectivityMode: deriveMode({ ...state, mqttConnected: connected })
    })),
  setHttpReachable: (reachable) =>
    set((state) => ({
      httpReachable: reachable,
      connectivityMode: deriveMode({ ...state, httpReachable: reachable })
    })),
  setApMode: (apMode) =>
    set((state) => ({
      apMode,
      connectivityMode: deriveMode({ ...state, apMode })
    })),
  setConnectivityMode: (mode) => set(() => ({ connectivityMode: mode }))
}));

import { create } from 'zustand';
import { httpClient } from '../api/httpClient';
import { mqttClient } from '../api/mqttClient';
import { CommandPayload, Device, JoinPayload, NodeInfo, Scene, StatusPayload } from '../types';
import { useConnectivityStore } from './connectivityStore';

type DevicesState = {
  nodes: Record<string, NodeInfo>;
  scenes: Scene[];
  ingestJoin: (payload: JoinPayload) => void;
  ingestStatus: (payload: StatusPayload) => void;
  sendCommand: (cmd: CommandPayload) => Promise<void>;
  executeScene: (sceneId: string) => Promise<void>;
};

const seedScenes: Scene[] = [
  {
    id: 'all-on',
    name: 'All On',
    actions: []
  },
  {
    id: 'all-off',
    name: 'All Off',
    actions: []
  }
];

export const useDevicesStore = create<DevicesState>((set, get) => ({
  nodes: {},
  scenes: seedScenes,
  ingestJoin: (payload) => {
    set((state) => {
      const devices: Device[] = payload.devs.map((dev) => ({
        id: `${payload.node_id}:${dev.id}`,
        label: dev.label,
        type: dev.type,
        st: dev.st
      }));
      const nodes = {
        ...state.nodes,
        [payload.node_id]: {
          nodeId: payload.node_id,
          devices
        }
      };
      const allDevices = Object.values(nodes).flatMap((n) => n.devices);
      return {
        nodes,
        scenes: state.scenes.map((scene) => ({
          ...scene,
          actions:
            scene.id === 'all-on'
              ? allDevices.map((d) => ({ dev: d.id, st: 1 }))
              : scene.id === 'all-off'
              ? allDevices.map((d) => ({ dev: d.id, st: 0 }))
              : scene.actions
        }))
      };
    });
  },
  ingestStatus: (payload) => {
    const nodeId = payload.node_id;
    if (!nodeId) return;
    set((state) => {
      const node = state.nodes[nodeId];
      if (!node) return state;
      const updatedDevices = node.devices.map((dev) => {
        const match = payload.devs.find((d) => d.id === dev.id.split(':')[1]);
        return match ? { ...dev, st: match.st } : dev;
      });
      return {
        nodes: {
          ...state.nodes,
          [nodeId]: { ...node, devices: updatedDevices }
        }
      };
    });
  },
  sendCommand: async (cmd) => {
    const mode = useConnectivityStore.getState().connectivityMode;
    if (mode === 'CLOUD_MQTT') {
      mqttClient.publishCommand(cmd);
    } else {
      await httpClient.postCommand(cmd);
    }
  },
  executeScene: async (sceneId) => {
    const scene = get().scenes.find((s) => s.id === sceneId);
    if (!scene) return;
    await Promise.all(scene.actions.map((action) => get().sendCommand(action)));
  }
}));

export const selectAllDevices = (state: DevicesState) =>
  Object.values(state.nodes).flatMap((node) => node.devices);

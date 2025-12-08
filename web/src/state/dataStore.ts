import { create } from 'zustand';
import { backendApi } from '../api/backend';
import { Device, Home, Node, Room, Scene, SceneActionDto } from '../types';

interface DataState {
  homes: Home[];
  selectedHome?: Home;
  nodes: Node[];
  rooms: Room[];
  devices: Device[];
  scenes: Scene[];
  loading: boolean;
  selectHome: (home: Home) => Promise<void>;
  refreshHome: (homeId: number) => Promise<void>;
  toggleDevice: (deviceId: number, state: boolean) => Promise<void>;
  activateScene: (sceneId: number) => Promise<void>;
  createScene: (homeId: number, name: string, actions: SceneActionDto[]) => Promise<void>;
}

export const useDataStore = create<DataState>((set, get) => ({
  homes: [],
  nodes: [],
  rooms: [],
  devices: [],
  scenes: [],
  loading: false,
  selectedHome: undefined,
  selectHome: async (home) => {
    set({ selectedHome: home });
    await get().refreshHome(home.id);
  },
  refreshHome: async (homeId) => {
    set({ loading: true });
    const [nodes, rooms, devices, scenes] = await Promise.all([
      backendApi.listNodes(homeId),
      backendApi.listRooms(homeId),
      backendApi.listDevices(homeId),
      backendApi.listScenes(homeId),
    ]);
    set({ nodes, rooms, devices, scenes, loading: false });
  },
  toggleDevice: async (deviceId, state) => {
    await backendApi.toggleDevice(deviceId, state);
    const devices = get().devices.map((d) => (d.id === deviceId ? { ...d, currentState: state ? 1 : 0 } : d));
    set({ devices });
  },
  activateScene: async (sceneId) => {
    await backendApi.activateScene(sceneId);
  },
  createScene: async (homeId, name, actions) => {
    await backendApi.createScene(homeId, name, actions);
    await get().refreshHome(homeId);
  },
}));

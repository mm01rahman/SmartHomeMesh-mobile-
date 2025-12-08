import axios from 'axios';
import { AuthResponse, Device, Home, Node, Room, Scene, SceneActionDto } from '../types';

const client = axios.create({ baseURL: '/api', withCredentials: false });

client.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export const backendApi = {
  async login(email: string, password: string): Promise<AuthResponse> {
    const res = await client.post<AuthResponse>('/auth/login', { email, password });
    localStorage.setItem('accessToken', res.data.accessToken);
    return res.data;
  },
  async register(name: string, email: string, password: string): Promise<AuthResponse> {
    const res = await client.post<AuthResponse>('/auth/register', { name, email, password });
    localStorage.setItem('accessToken', res.data.accessToken);
    return res.data;
  },
  async listHomes(): Promise<Home[]> {
    const res = await client.get<Home[]>('/homes');
    return res.data;
  },
  async listRooms(homeId: number): Promise<Room[]> {
    const res = await client.get<Room[]>(`/homes/${homeId}/rooms`);
    return res.data;
  },
  async listNodes(homeId: number): Promise<Node[]> {
    const res = await client.get<Node[]>(`/homes/${homeId}/nodes`);
    return res.data;
  },
  async listDevices(homeId: number): Promise<Device[]> {
    const res = await client.get<Device[]>(`/homes/${homeId}/devices`);
    return res.data;
  },
  async toggleDevice(deviceId: number, state: boolean) {
    await client.post(`/devices/${deviceId}/toggle`, { state });
  },
  async listScenes(homeId: number): Promise<Scene[]> {
    const res = await client.get<Scene[]>(`/homes/${homeId}/scenes`);
    return res.data;
  },
  async createScene(homeId: number, name: string, actions: SceneActionDto[]) {
    await client.post(`/homes/${homeId}/scenes`, { name, actions });
  },
  async activateScene(sceneId: number) {
    await client.post(`/scenes/${sceneId}/activate`, {});
  },
};

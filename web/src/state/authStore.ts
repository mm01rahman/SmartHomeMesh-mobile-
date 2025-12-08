import { create } from 'zustand';
import { backendApi } from '../api/backend';
import { AuthResponse } from '../types';

interface AuthState {
  token?: string;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<AuthResponse>;
  register: (name: string, email: string, password: string) => Promise<AuthResponse>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  token: localStorage.getItem('accessToken') || undefined,
  isAuthenticated: !!localStorage.getItem('accessToken'),
  login: async (email, password) => {
    const res = await backendApi.login(email, password);
    set({ token: res.accessToken, isAuthenticated: true });
    return res;
  },
  register: async (name, email, password) => {
    const res = await backendApi.register(name, email, password);
    set({ token: res.accessToken, isAuthenticated: true });
    return res;
  },
  logout: () => {
    localStorage.removeItem('accessToken');
    set({ isAuthenticated: false, token: undefined });
  },
}));

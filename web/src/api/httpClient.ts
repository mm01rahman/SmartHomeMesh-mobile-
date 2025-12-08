import axios, { AxiosInstance } from 'axios';
import { CommandPayload, StatusPayload } from '../types';

export interface HttpConfig {
  baseURL: string;
  timeout?: number;
}

const defaultConfig: HttpConfig = {
  baseURL: 'http://192.168.4.1',
  timeout: 5000
};

class HttpClient {
  private client: AxiosInstance;

  constructor(config?: HttpConfig) {
    const merged = { ...defaultConfig, ...config };
    this.client = axios.create({
      baseURL: merged.baseURL,
      timeout: merged.timeout
    });
  }

  async postCommand(payload: CommandPayload) {
    await this.client.post('/cmd', payload);
  }

  async fetchStatus(): Promise<StatusPayload> {
    const res = await this.client.get<StatusPayload>('/status');
    return res.data;
  }

  async provision(data: { ssid: string; password: string; nodeName?: string }) {
    await this.client.post('/provision', data);
  }
}

export const httpClient = new HttpClient();

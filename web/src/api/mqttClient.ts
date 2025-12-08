import mqtt, { IClientOptions, MqttClient as MQTTClient } from 'mqtt';
import { Node, Device } from '../types';

type JoinHandler = (payload: { node: string; devs: Device[] }) => void;
type StatusHandler = (payload: { node: string; devs: { id: string; st: number }[] }) => void;
type LwtHandler = (payload: { node: string; state: string }) => void;

type ConnectivityHandler = (connected: boolean) => void;

interface Config {
  host: string;
  port: number;
  protocol: 'wss' | 'ws' | 'mqtts' | 'mqtt';
  username?: string;
  password?: string;
  baseTopic?: string;
}

const defaultConfig: Config = {
  host: 'broker.example.com',
  port: 8884,
  protocol: 'wss',
  baseTopic: 'smarthome',
};

class MeshMqttClient {
  private client?: MQTTClient;
  private joinHandlers = new Set<JoinHandler>();
  private statusHandlers = new Set<StatusHandler>();
  private lwtHandlers = new Set<LwtHandler>();
  private connectionHandlers = new Set<ConnectivityHandler>();
  private readonly config: Config;

  constructor(config?: Partial<Config>) {
    this.config = { ...defaultConfig, ...config } as Config;
  }

  connect() {
    if (this.client) return;
    const opts: IClientOptions = {
      host: this.config.host,
      port: this.config.port,
      protocol: this.config.protocol,
      username: this.config.username,
      password: this.config.password,
      reconnectPeriod: 5000,
      clean: true,
    };
    const base = this.config.baseTopic || 'smarthome';
    this.client = mqtt.connect(opts);
    this.client.on('connect', () => {
      this.connectionHandlers.forEach((cb) => cb(true));
      this.client?.subscribe(`${base}/+/join`);
      this.client?.subscribe(`${base}/+/status`);
      this.client?.subscribe(`${base}/+/lwt`);
    });
    this.client.on('close', () => this.connectionHandlers.forEach((cb) => cb(false)));
    this.client.on('reconnect', () => this.connectionHandlers.forEach((cb) => cb(false)));
    this.client.on('message', (topic, payload) => {
      const [, node, suffix] = topic.split('/');
      if (suffix === 'lwt') {
        this.lwtHandlers.forEach((cb) => cb({ node, state: payload.toString() }));
        return;
      }
      try {
        const data = JSON.parse(payload.toString());
        if (suffix === 'join' && data.t === 'join') this.joinHandlers.forEach((cb) => cb(data));
        if (suffix === 'status' && data.t === 'status') this.statusHandlers.forEach((cb) => cb(data));
      } catch (err) {
        console.error('MQTT parse error', err);
      }
    });
  }

  disconnect() {
    this.client?.end(true);
    this.client = undefined;
  }

  onJoin(handler: JoinHandler) {
    this.joinHandlers.add(handler);
    return () => this.joinHandlers.delete(handler);
  }

  onStatus(handler: StatusHandler) {
    this.statusHandlers.add(handler);
    return () => this.statusHandlers.delete(handler);
  }

  onLwt(handler: LwtHandler) {
    this.lwtHandlers.add(handler);
    return () => this.lwtHandlers.delete(handler);
  }

  onConnectionChange(handler: ConnectivityHandler) {
    this.connectionHandlers.add(handler);
    return () => this.connectionHandlers.delete(handler);
  }
}

export const mqttClient = new MeshMqttClient();

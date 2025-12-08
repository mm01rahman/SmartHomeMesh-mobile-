import { connect, IClientOptions, MqttClient as MQTTClient } from 'mqtt';
import { CommandPayload, JoinPayload, StatusPayload } from '../types';

type MessageHandler<T> = (payload: T) => void;

type ConnectivityHandler = (connected: boolean) => void;

export interface MqttConfig {
  url: string;
  username?: string;
  password?: string;
  baseTopic?: string;
  joinTopic?: string;
  statusTopic?: string;
  ackTopic?: string;
  cmdTopic?: string;
}

const defaultConfig: Required<Omit<MqttConfig, 'username' | 'password'>> = {
  url: 'wss://broker.example.com:8884/mqtt',
  baseTopic: 'smarthome',
  joinTopic: 'smarthome/join',
  statusTopic: 'smarthome/status',
  ackTopic: 'smarthome/ack',
  cmdTopic: 'smarthome/cmd'
};

class SmartHomeMqttClient {
  private client?: MQTTClient;
  private joinHandlers = new Set<MessageHandler<JoinPayload>>();
  private statusHandlers = new Set<MessageHandler<StatusPayload>>();
  private ackHandlers = new Set<MessageHandler<Record<string, unknown>>>();
  private connectionHandlers = new Set<ConnectivityHandler>();
  private config: Required<MqttConfig>;

  constructor(config?: MqttConfig) {
    this.config = { ...defaultConfig, ...config } as Required<MqttConfig>;
  }

  async connect(): Promise<void> {
    if (this.client) return;
    const options: IClientOptions = {
      username: this.config.username,
      password: this.config.password,
      reconnectPeriod: 3000
    };

    const client = connect(this.config.url, options);
    this.client = client;

    client.on('connect', () => {
      this.connectionHandlers.forEach((cb) => cb(true));
      client.subscribe([
        this.config.joinTopic,
        `${this.config.statusTopic}/#`,
        this.config.ackTopic
      ]);
    });

    client.on('reconnect', () => this.connectionHandlers.forEach((cb) => cb(false)));
    client.on('close', () => this.connectionHandlers.forEach((cb) => cb(false)));

    client.on('message', (topic, payload) => {
      try {
        const data = JSON.parse(payload.toString());
        if (topic.startsWith(this.config.joinTopic)) {
          this.joinHandlers.forEach((cb) => cb(data as JoinPayload));
        } else if (topic.startsWith(this.config.statusTopic)) {
          this.statusHandlers.forEach((cb) => cb(data as StatusPayload));
        } else if (topic.startsWith(this.config.ackTopic)) {
          this.ackHandlers.forEach((cb) => cb(data));
        }
      } catch (err) {
        console.error('Failed to parse MQTT payload', err);
      }
    });
  }

  disconnect() {
    this.client?.end(true);
    this.client = undefined;
  }

  publishCommand(cmd: CommandPayload) {
    if (!this.client) throw new Error('MQTT client not connected');
    this.client.publish(this.config.cmdTopic, JSON.stringify(cmd));
  }

  onJoin(handler: MessageHandler<JoinPayload>) {
    this.joinHandlers.add(handler);
    return () => this.joinHandlers.delete(handler);
  }

  onStatus(handler: MessageHandler<StatusPayload>) {
    this.statusHandlers.add(handler);
    return () => this.statusHandlers.delete(handler);
  }

  onAck(handler: MessageHandler<Record<string, unknown>>) {
    this.ackHandlers.add(handler);
    return () => this.ackHandlers.delete(handler);
  }

  onConnectionChange(handler: ConnectivityHandler) {
    this.connectionHandlers.add(handler);
    return () => this.connectionHandlers.delete(handler);
  }
}

export const mqttClient = new SmartHomeMqttClient();

import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { connect, IClientOptions, MqttClient } from 'mqtt';
import { NodesService } from '../nodes/nodes.service';

@Injectable()
export class MqttService implements OnModuleInit {
  private readonly logger = new Logger(MqttService.name);
  private client: MqttClient;

  constructor(private nodesService: NodesService) {}

  onModuleInit() {
    const options: IClientOptions = {
      host: process.env.MQTT_HOST,
      port: Number(process.env.MQTT_PORT || 8883),
      protocol: 'mqtts',
      username: process.env.MQTT_USERNAME,
      password: process.env.MQTT_PASSWORD,
      reconnectPeriod: 5000,
    };
    this.client = connect(options);
    this.client.on('connect', () => {
      this.logger.log('Connected to HiveMQ');
      const base = process.env.MQTT_BASE_TOPIC || 'smarthome';
      this.client.subscribe(`${base}/+/join`);
      this.client.subscribe(`${base}/+/status`);
      this.client.subscribe(`${base}/+/lwt`);
    });

    this.client.on('message', async (topic, payload) => {
      try {
        const data = JSON.parse(payload.toString());
        const [, nodeId, suffix] = topic.split('/');
        if (suffix === 'join' && data.t === 'join') {
          // JOIN packet from esp v2.0
          await this.nodesService.upsertJoinPayload(data);
        }
        if (suffix === 'status' && data.t === 'status') {
          await this.nodesService.updateStatus(data);
        }
        if (suffix === 'lwt') {
          await this.nodesService.updateLwt(nodeId, payload.toString() as any);
        }
      } catch (err) {
        this.logger.error('MQTT message handling failed', err as any);
      }
    });

    this.client.on('error', (err) => this.logger.error(err));
  }

  async publish(topic: string, message: string) {
    if (!this.client || !this.client.connected) {
      this.logger.warn('MQTT client not ready');
      return;
    }
    this.client.publish(topic, message);
  }
}

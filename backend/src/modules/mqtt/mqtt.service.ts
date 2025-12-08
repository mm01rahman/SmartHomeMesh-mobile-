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
      protocol: process.env.MQTT_PROTOCOL as any || 'mqtts',
      username: process.env.MQTT_USERNAME,
      password: process.env.MQTT_PASSWORD,
      reconnectPeriod: 5000,
    };
    const base = process.env.MQTT_BASE_TOPIC || 'smarthome';
    this.client = connect(options);
    this.client.on('connect', () => {
      this.logger.log('Connected to MQTT broker');
      this.client.subscribe(`${base}/+/join`);
      this.client.subscribe(`${base}/+/status`);
      this.client.subscribe(`${base}/+/lwt`);
    });

    this.client.on('message', async (topic, payload) => {
      const [, nodeId, suffix] = topic.split('/');
      try {
        if (suffix === 'lwt') {
          await this.nodesService.updateLwt(nodeId, payload.toString() as any);
          return;
        }
        const data = JSON.parse(payload.toString());
        if (suffix === 'join' && data.t === 'join') {
          await this.nodesService.upsertJoinPayload(data);
        }
        if (suffix === 'status' && data.t === 'status') {
          await this.nodesService.updateStatus(data);
        }
      } catch (err) {
        this.logger.error(`MQTT handling failed for topic ${topic}: ${err}`);
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

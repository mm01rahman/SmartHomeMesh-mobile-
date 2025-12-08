import { ConnectivityMode } from '../types';

const descriptions: Record<ConnectivityMode, string> = {
  CLOUD_MQTT: 'Cloud MQTT connected. Real-time updates via broker.',
  LAN_HTTP: 'LAN HTTP mode. Commands routed through STA IP.',
  AP_MESH_HTTP: 'AP mesh HTTP mode. Controlling devices via ESP AP.',
  OFFLINE: 'Offline. Commands will queue once connectivity returns.'
};

interface Props {
  mode: ConnectivityMode;
}

const ConnectivityBanner = ({ mode }: Props) => {
  return (
    <div className="banner">
      <div>
        <strong>{mode.replace('_', ' ')}</strong>
        <div className="small">{descriptions[mode]}</div>
      </div>
      <div className="small">ESP v2.0 mesh</div>
    </div>
  );
};

export default ConnectivityBanner;

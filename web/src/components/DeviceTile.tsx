import { Device } from '../types';
import { useDevicesStore } from '../state/devicesStore';

interface Props {
  device: Device;
}

const icons: Record<string, string> = {
  light: '💡',
  fan: '🌀',
  socket: '🔌',
  generic: '🔘'
};

const DeviceTile = ({ device }: Props) => {
  const sendCommand = useDevicesStore((s) => s.sendCommand);
  const toggle = () => {
    const newState = device.st === 1 ? 0 : 1;
    sendCommand({ dev: device.id, st: newState }).catch((err) =>
      console.error('Failed to send command', err)
    );
  };

  return (
    <div className="device-tile">
      <div className="device-header">
        <div>
          <div>{icons[device.type] ?? icons.generic}</div>
          <strong>{device.label}</strong>
        </div>
        <div className="small">{device.id}</div>
      </div>
      <div className="row" style={{ alignItems: 'center', justifyContent: 'space-between' }}>
        <span>Status: {device.st === 1 ? 'On' : 'Off'}</span>
        <button className="button primary" onClick={toggle}>
          Toggle
        </button>
      </div>
    </div>
  );
};

export default DeviceTile;

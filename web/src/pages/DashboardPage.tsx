import DeviceTile from '../components/DeviceTile';
import SceneButton from '../components/SceneButton';
import { useDevicesStore, selectAllDevices } from '../state/devicesStore';

const DashboardPage = () => {
  const devices = useDevicesStore(selectAllDevices);
  const scenes = useDevicesStore((s) => s.scenes);

  return (
    <div className="card">
      <h2>Dashboard</h2>
      <p className="small">
        Live device state from ESP v2.0 mesh. JOIN messages populate the list; STATUS messages keep it fresh.
      </p>

      <div className="device-grid">
        {devices.length === 0 && <div className="small">No devices yet. Waiting for JOIN payloads.</div>}
        {devices.map((device) => (
          <DeviceTile key={device.id} device={device} />
        ))}
      </div>

      <h3>Scenes</h3>
      <div className="scene-row">
        {scenes.map((scene) => (
          <SceneButton key={scene.id} scene={scene} />
        ))}
      </div>
    </div>
  );
};

export default DashboardPage;

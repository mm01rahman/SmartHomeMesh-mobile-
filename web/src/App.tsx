import { useEffect } from 'react';
import ConnectivityBanner from './components/ConnectivityBanner';
import DashboardPage from './pages/DashboardPage';
import { useConnectivityStore } from './state/connectivityStore';
import { useDevicesStore } from './state/devicesStore';
import { mqttClient } from './api/mqttClient';

function App() {
  const { connectivityMode, setMqttConnected } = useConnectivityStore();
  const { ingestJoin, ingestStatus } = useDevicesStore();

  useEffect(() => {
    mqttClient.onJoin(ingestJoin);
    mqttClient.onStatus(ingestStatus);
    mqttClient.onConnectionChange((connected) => setMqttConnected(connected));

    mqttClient.connect().catch((err) => console.error('MQTT connect failed', err));
    return () => {
      mqttClient.disconnect();
    };
  }, [ingestJoin, ingestStatus, setMqttConnected]);

  return (
    <div className="app-shell">
      <ConnectivityBanner mode={connectivityMode} />
      <main>
        <DashboardPage />
      </main>
    </div>
  );
}

export default App;

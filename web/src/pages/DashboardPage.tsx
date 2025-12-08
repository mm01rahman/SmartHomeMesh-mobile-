import React, { useEffect, useMemo } from 'react';
import { useDataStore } from '../state/dataStore';
import { useAuthStore } from '../state/authStore';
import { backendApi } from '../api/backend';
import ConnectivityBanner from '../components/ConnectivityBanner';
import { DeviceTable } from '../components/DeviceTable';
import { ScenePanel } from '../components/ScenePanel';
import { mqttClient } from '../api/mqttClient';

const DashboardPage: React.FC = () => {
  const { homes, selectedHome, nodes, devices, scenes, selectHome, refreshHome, toggleDevice, activateScene, createScene } =
    useDataStore();
  const { logout } = useAuthStore();
  const onlineCount = useMemo(() => nodes.filter((n) => n.onlineStatus === 'ONLINE').length, [nodes]);

  useEffect(() => {
    backendApi.listHomes().then((list) => {
      useDataStore.setState({ homes: list });
      if (!selectedHome && list.length) selectHome(list[0]);
    });
  }, [selectHome, selectedHome]);

  useEffect(() => {
    mqttClient.connect();
    const offJoin = mqttClient.onJoin(() => selectedHome && refreshHome(selectedHome.id));
    const offStatus = mqttClient.onStatus(() => selectedHome && refreshHome(selectedHome.id));
    return () => {
      offJoin();
      offStatus();
      mqttClient.disconnect();
    };
  }, [refreshHome, selectedHome]);

  return (
    <div className="page">
      <header className="top-bar">
        <h1>SmartHomeMesh Admin</h1>
        <div className="actions">
          <select
            value={selectedHome?.id || ''}
            onChange={(e) => {
              const home = homes.find((h) => h.id === Number(e.target.value));
              if (home) selectHome(home);
            }}
          >
            <option value="">Select home</option>
            {homes.map((h) => (
              <option key={h.id} value={h.id}>
                {h.name}
              </option>
            ))}
          </select>
          <button className="btn" onClick={logout}>
            Logout
          </button>
        </div>
      </header>

      <ConnectivityBanner connected={onlineCount > 0} text={`${onlineCount}/${nodes.length} nodes online`} />

      <section className="grid">
        <div className="card">
          <h3>Nodes</h3>
          <ul>
            {nodes.map((node) => {
              const onCount = devices.filter((d) => d.nodeId === node.nodeId && d.currentState === 1).length;
              return (
                <li key={node.nodeId} className={node.onlineStatus === 'ONLINE' ? 'online' : 'offline'}>
                  <strong>{node.name}</strong> ({node.nodeId}) – {node.devices.length} devices / {onCount} on
                </li>
              );
            })}
          </ul>
        </div>

        <div className="card">
          <h3>Devices</h3>
          <DeviceTable devices={devices} onToggle={toggleDevice} />
        </div>

        <div className="card">
          <ScenePanel scenes={scenes} devices={devices} onActivate={activateScene} onCreate={(name, acts) => selectedHome && createScene(selectedHome.id, name, acts)} />
        </div>
      </section>
    </div>
  );
};

export default DashboardPage;

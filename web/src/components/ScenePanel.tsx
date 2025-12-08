import React, { useState } from 'react';
import { Device, Scene } from '../types';

interface Props {
  scenes: Scene[];
  devices: Device[];
  onActivate: (sceneId: number) => void;
  onCreate: (name: string, selections: { deviceId: number; desiredState: number }[]) => void;
}

export const ScenePanel: React.FC<Props> = ({ scenes, devices, onActivate, onCreate }) => {
  const [name, setName] = useState('');
  const [selected, setSelected] = useState<Record<number, number>>({});

  const toggleSelection = (deviceId: number) => {
    setSelected((prev) => ({ ...prev, [deviceId]: prev[deviceId] === 1 ? 0 : 1 }));
  };

  return (
    <div className="panel">
      <h3>Scenes</h3>
      <div className="scene-list">
        {scenes.map((scene) => (
          <div key={scene.id} className="scene-card">
            <div>
              <strong>{scene.name}</strong>
              <p>{scene.actions.length} devices</p>
            </div>
            <button className="btn" onClick={() => onActivate(scene.id)}>
              Activate
            </button>
          </div>
        ))}
      </div>
      <div className="scene-create">
        <h4>Create scene</h4>
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Scene name" />
        <div className="device-grid">
          {devices.map((d) => (
            <label key={d.id} className={selected[d.id] ? 'selected' : ''}>
              <input type="checkbox" checked={selected[d.id] === 1} onChange={() => toggleSelection(d.id)} />
              {d.label} ({d.nodeId}:{d.localId})
            </label>
          ))}
        </div>
        <button
          className="btn"
          onClick={() => {
            const selections = Object.entries(selected).map(([id, st]) => ({ deviceId: Number(id), desiredState: st }));
            onCreate(name, selections);
            setSelected({});
            setName('');
          }}
        >
          Save Scene
        </button>
      </div>
    </div>
  );
};

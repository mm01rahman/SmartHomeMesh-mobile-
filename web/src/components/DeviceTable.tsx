import React from 'react';
import { Device } from '../types';

interface Props {
  devices: Device[];
  onToggle: (deviceId: number, state: boolean) => void;
}

export const DeviceTable: React.FC<Props> = ({ devices, onToggle }) => {
  return (
    <table className="table">
      <thead>
        <tr>
          <th>Label</th>
          <th>Type</th>
          <th>Node</th>
          <th>Local</th>
          <th>State</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        {devices.map((d) => (
          <tr key={d.id}>
            <td>{d.label}</td>
            <td>{d.type}</td>
            <td>{d.nodeId}</td>
            <td>{d.localId}</td>
            <td>{d.currentState === 1 ? 'ON' : 'OFF'}</td>
            <td>
              <button onClick={() => onToggle(d.id, d.currentState !== 1)} className="btn">
                Toggle
              </button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

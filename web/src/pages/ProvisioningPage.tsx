import { FormEvent, useState } from 'react';
import { httpClient } from '../api/httpClient';

const ProvisioningPage = () => {
  const [ssid, setSsid] = useState('');
  const [password, setPassword] = useState('');
  const [nodeName, setNodeName] = useState('');
  const [status, setStatus] = useState<string | null>(null);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    try {
      setStatus('Sending credentials to AP...');
      await httpClient.provision({ ssid, password, nodeName });
      setStatus('Provisioning payload sent. Waiting for device to join.');
    } catch (err) {
      console.error(err);
      setStatus('Provisioning failed.');
    }
  };

  return (
    <div className="card">
      <h2>Provision a new node</h2>
      <p className="small">Connect to the ESP AP and push WiFi credentials.</p>
      <form onSubmit={onSubmit} className="row" style={{ flexDirection: 'column', gap: '0.75rem' }}>
        <input
          placeholder="WiFi SSID"
          value={ssid}
          onChange={(e) => setSsid(e.target.value)}
          required
        />
        <input
          placeholder="WiFi Password"
          value={password}
          type="password"
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        <input
          placeholder="Node name (optional)"
          value={nodeName}
          onChange={(e) => setNodeName(e.target.value)}
        />
        <button className="button primary" type="submit">
          Send to device
        </button>
      </form>
      {status && <div className="small">{status}</div>}
    </div>
  );
};

export default ProvisioningPage;

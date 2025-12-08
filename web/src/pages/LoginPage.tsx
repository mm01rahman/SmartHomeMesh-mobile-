import React, { useState } from 'react';
import { useAuthStore } from '../state/authStore';

interface Props {
  onSuccess: () => void;
}

const LoginPage: React.FC<Props> = ({ onSuccess }) => {
  const { login, register } = useAuthStore();
  const [email, setEmail] = useState('admin@example.com');
  const [password, setPassword] = useState('changeme');
  const [name, setName] = useState('Admin');
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [error, setError] = useState<string | null>(null);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (mode === 'login') await login(email, password);
      else await register(name, email, password);
      onSuccess();
    } catch (err: any) {
      setError(err?.message || 'Authentication failed');
    }
  };

  return (
    <div className="card auth-card">
      <h2>{mode === 'login' ? 'Sign in' : 'Register'}</h2>
      <form onSubmit={submit}>
        {mode === 'register' && (
          <input placeholder="Name" value={name} onChange={(e) => setName(e.target.value)} required />
        )}
        <input placeholder="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        <input
          placeholder="Password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        {error && <p className="error">{error}</p>}
        <button type="submit" className="btn primary">
          {mode === 'login' ? 'Login' : 'Create account'}
        </button>
      </form>
      <button className="link" onClick={() => setMode(mode === 'login' ? 'register' : 'login')}>
        {mode === 'login' ? 'Need an account?' : 'Have an account? Login'}
      </button>
    </div>
  );
};

export default LoginPage;

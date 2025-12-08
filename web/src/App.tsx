import { useEffect, useState } from 'react';
import DashboardPage from './pages/DashboardPage';
import LoginPage from './pages/LoginPage';
import { useAuthStore } from './state/authStore';
import './styles.css';

function App() {
  const { isAuthenticated } = useAuthStore();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    setReady(true);
  }, []);

  if (!ready) return null;
  if (!isAuthenticated) return <LoginPage onSuccess={() => setReady(true)} />;
  return <DashboardPage />;
}

export default App;

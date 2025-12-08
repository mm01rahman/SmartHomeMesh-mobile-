import React from 'react';

interface Props {
  connected: boolean;
  text: string;
}

const ConnectivityBanner: React.FC<Props> = ({ connected, text }) => {
  return (
    <div className={`banner ${connected ? 'online' : 'offline'}`}>
      <span className="dot" />
      <span>{text}</span>
    </div>
  );
};

export default ConnectivityBanner;

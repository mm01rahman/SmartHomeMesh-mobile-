import { Scene } from '../types';
import { useDevicesStore } from '../state/devicesStore';

interface Props {
  scene: Scene;
}

const SceneButton = ({ scene }: Props) => {
  const executeScene = useDevicesStore((s) => s.executeScene);

  const handleClick = () => {
    executeScene(scene.id).catch((err) => console.error('Scene failed', err));
  };

  return (
    <button className="scene-button" onClick={handleClick}>
      {scene.name}
    </button>
  );
};

export default SceneButton;

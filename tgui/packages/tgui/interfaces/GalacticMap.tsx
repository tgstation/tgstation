import '../styles/themes/galactic-map.scss';
import { Window } from '../layouts';

export function GalacticMap() {
  return (
    <Window
      title="Политическая карта галактики"
      width={1280}
      height={800}
      theme="galactic-map"
    >
      <Window.Content>
        <iframe src="https://spacestation220.github.io/SS220-Political-Map/" />
      </Window.Content>
    </Window>
  );
}

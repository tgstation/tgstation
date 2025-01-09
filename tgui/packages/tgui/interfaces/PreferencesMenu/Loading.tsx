import { Window } from '../../layouts';
import { LoadingScreen } from '../common/LoadingToolbox';

export function LoadingPage(props) {
  return (
    <Window title="Loading..." width={420} height={770}>
      <Window.Content />
      <LoadingScreen />
      <Window.Content />
    </Window>
  );
}

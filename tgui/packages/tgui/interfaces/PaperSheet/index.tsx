import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { TEXTAREA_INPUT_HEIGHT } from './constants';
import { PrimaryView } from './PrimaryView';
import type { PaperContext } from './types';

export function PaperSheet(props) {
  const { data } = useBackend<PaperContext>();
  const { paper_color, paper_name } = data;

  return (
    <Window
      title={paper_name}
      theme="paper220"
      width={600}
      height={500 + TEXTAREA_INPUT_HEIGHT}
    >
      <Window.Content backgroundColor={paper_color}>
        <PrimaryView />
      </Window.Content>
    </Window>
  );
}

import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { TEXTAREA_INPUT_HEIGHT } from './constants';
import { canEdit } from './helpers';
import { PrimaryView } from './PrimaryView';
import type { PaperContext } from './types';

export function PaperSheet(props) {
  const { data } = useBackend<PaperContext>();
  const { paper_color, paper_name, held_item_details } = data;

  const writeMode = canEdit(held_item_details);

  if (!writeMode) {
    const [inputFieldData, setInputFieldData] = useLocalState(
      'inputFieldData',
      {},
    );
    if (Object.keys(inputFieldData).length) {
      setInputFieldData({});
    }
  }

  return (
    <Window
      title={paper_name}
      theme="paper"
      width={420}
      height={500 + (writeMode ? TEXTAREA_INPUT_HEIGHT : 0)}
    >
      <Window.Content backgroundColor={paper_color}>
        <PrimaryView />
      </Window.Content>
    </Window>
  );
}

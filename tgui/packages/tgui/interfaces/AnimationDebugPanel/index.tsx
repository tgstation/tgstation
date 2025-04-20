import { NoticeBox } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

export function AnimationDebugPanel() {
  const { data, act } = useBackend<AnimationDebugPanelData>();

  return (
    <Window title="Animation Debug Panel">
      <NoticeBox danger>TODO</NoticeBox>
    </Window>
  );
}

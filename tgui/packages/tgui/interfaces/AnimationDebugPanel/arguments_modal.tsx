import { JSX } from 'react';
import { Button } from 'tgui-core/components';

import { Window } from '../../layouts';

export function AnimateArgumentsModal(
  setActiveModal: (activeModal: JSX.Element | undefined) => undefined,
) {
  return (
    <Window>
      <Button icon="cross" onClick={() => setActiveModal(undefined)} />
    </Window>
  );
}

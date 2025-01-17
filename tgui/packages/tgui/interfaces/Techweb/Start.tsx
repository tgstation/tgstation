import { Button, Modal } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TechwebContent } from './Content';

export function TechwebStart(props) {
  const { act, data } = useBackend();
  const { locked, stored_research } = data;

  if (locked) {
    return (
      <Modal width="15em" align="center" className="Techweb__LockedModal">
        <div>
          <b>Console Locked</b>
        </div>
        <Button icon="unlock" onClick={() => act('toggleLock')}>
          Unlock
        </Button>
      </Modal>
    );
  }

  if (!stored_research) {
    return (
      <Modal width="25em" align="center" className="Techweb__LockedModal">
        <div>
          <b>No research techweb found, please synchronize the console.</b>
        </div>
      </Modal>
    );
  }

  return <TechwebContent />;
}

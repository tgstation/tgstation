import { Button } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { SWIPE_NEEDED } from './constants';
import type { CommsConsoleData } from './types';

type Props = {
  alertLevel: string;
  onClick: () => void;
};

export function AlertButton(props: Props) {
  const { alertLevel, onClick } = props;

  const { act, data } = useBackend<CommsConsoleData>();
  const { canSetAlertLevel } = data;

  const thisIsCurrent = data.alertLevel === alertLevel;

  return (
    <Button
      icon="exclamation-triangle"
      color={thisIsCurrent && 'good'}
      onClick={() => {
        if (thisIsCurrent) {
          return;
        }

        if (canSetAlertLevel === SWIPE_NEEDED) {
          onClick();
        } else {
          act('changeSecurityLevel', {
            newSecurityLevel: alertLevel,
          });
        }
      }}
    >
      {capitalize(alertLevel)}
    </Button>
  );
}

import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { SCREENS } from './types';

type FakeDesktopButtonProps = {
  children: React.ReactNode;
  name: string;
  setScreenmode: (mode: SCREENS) => void;
  ownerScreenMode: SCREENS;
};

export const FakeDesktopButton = (props: FakeDesktopButtonProps) => {
  const { act } = useBackend();
  const { children, name, setScreenmode, ownerScreenMode } = props;

  return (
    <>
      <Stack.Item>
        <Button
          color="transparent"
          onClick={() => {
            setScreenmode(ownerScreenMode);
            act('typesound');
          }}
        >
          {children}
        </Button>
      </Stack.Item>
      <Stack.Item color="white" textAlign="center">
        {name}
      </Stack.Item>
    </>
  );
};

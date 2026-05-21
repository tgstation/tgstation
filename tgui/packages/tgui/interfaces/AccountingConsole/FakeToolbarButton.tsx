import { Button } from 'tgui-core/components';
import { useBackend } from '../../backend';
import type { SCREENS } from './types';

type FakeToolbarButtonProps = {
  name: string;
  currentScreenMode: SCREENS;
  setScreenmode: (mode: SCREENS) => void;
  ownerScreenMode: SCREENS;
};

export const FakeToolbarButton = (props: FakeToolbarButtonProps) => {
  const { act } = useBackend();
  const { name, currentScreenMode, setScreenmode, ownerScreenMode } = props;

  return (
    <Button
      height="100%"
      width="120px"
      ellipsis
      lineHeight="28px"
      textColor={currentScreenMode === ownerScreenMode ? 'black' : undefined}
      backgroundColor={
        currentScreenMode === ownerScreenMode ? 'white' : undefined
      }
      onClick={() => {
        setScreenmode(ownerScreenMode);
        act('typesound');
      }}
    >
      {name}
    </Button>
  );
};

import { Box, Button, DmIcon, Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { type Data, SCREENS } from './types';

type FakeWindowProps = {
  name: string;
  setScreenmode: (mode: SCREENS) => void;
};
export const FakeWindowIan = (props: FakeWindowProps) => {
  const { data } = useBackend<Data>();
  const { young_ian } = data;

  return (
    <FakeWindow {...props}>
      <DmIcon
        width="300px"
        height="300px"
        mt={1}
        icon="icons/mob/simple/pets.dmi"
        icon_state={young_ian ? 'puppy' : 'corgi'}
      />
    </FakeWindow>
  );
};
export const FakeWindow = (
  props: FakeWindowProps & {
    children: React.ReactNode;
  },
) => {
  const { act } = useBackend();
  const { name, children, setScreenmode } = props;

  return (
    <Stack vertical className="Accounting__Window">
      <Stack.Item>
        <Stack height="30px" backgroundColor="hsl(240, 100%, 25.1%)">
          <Stack.Item grow p={1}>
            <Box color="white">{name}</Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="times"
              mr={0.75}
              mt={0.75}
              onClick={() => {
                setScreenmode(SCREENS.none);
                act('typesound');
              }}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow mt={-1} p={1}>
        <Box
          height="100%"
          className="Accounting__WindowContent"
          backgroundColor="white"
        >
          {children}
        </Box>
      </Stack.Item>
    </Stack>
  );
};

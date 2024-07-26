import { BooleanLike, classes } from 'common/react';

import { useBackend } from '../backend';
import { Box, Button, Icon, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  disk_present: BooleanLike;
  status1: string;
  status2: string;
  anchored: BooleanLike;
};

const KEYPAD = [
  ['1', '4', '7', 'C'],
  ['2', '5', '8', '0'],
  ['3', '6', '9', 'E'],
] as const;

// This ui is so many manual overrides and !important tags
// and hand made width sets that changing pretty much anything
// is going to require a lot of tweaking it get it looking correct again
// I'm sorry, but it looks bangin
export function NukeKeypad(props) {
  const { act } = useBackend();

  return (
    <Box width="185px">
      <Stack>
        {KEYPAD.map((keyColumn) => (
          <Stack.Item key={keyColumn[0]}>
            {keyColumn.map((key) => (
              <Button
                fluid
                bold
                key={key}
                mb={1}
                textAlign="center"
                fontSize="40px"
                lineHeight={1.25}
                width="55px"
                className={classes([
                  'NuclearBomb__Button',
                  'NuclearBomb__Button--keypad',
                  'NuclearBomb__Button--' + key,
                ])}
                onClick={() => act('keypad', { digit: key })}
              >
                {key}
              </Button>
            ))}
          </Stack.Item>
        ))}
      </Stack>
    </Box>
  );
}

export function NuclearBomb(props) {
  const { act, data } = useBackend<Data>();
  const { status1, status2 } = data;

  return (
    <Window width={350} height={442} theme="retro">
      <Window.Content>
        <Box m={1}>
          <Box mb={1} className="NuclearBomb__displayBox">
            {status1}
          </Box>
          <Stack mb={1.5}>
            <Stack.Item grow>
              <Box className="NuclearBomb__displayBox">{status2}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="eject"
                fontSize="24px"
                lineHeight={1}
                textAlign="center"
                width="43px"
                ml={1}
                mr={0.5}
                mt={0.5}
                className="NuclearBomb__Button NuclearBomb__Button--keypad"
                onClick={() => act('eject_disk')}
              />
            </Stack.Item>
          </Stack>
          <Stack ml={0.5}>
            <Stack.Item>
              <NukeKeypad />
            </Stack.Item>
            <Stack.Item ml={1} width="129px">
              <Box>
                <Button
                  fluid
                  bold
                  textAlign="center"
                  fontSize="28px"
                  lineHeight={1.1}
                  mb={1}
                  className="NuclearBomb__Button NuclearBomb__Button--C"
                  onClick={() => act('arm')}
                >
                  ARM
                </Button>
                <Button
                  fluid
                  bold
                  textAlign="center"
                  fontSize="28px"
                  lineHeight={1.1}
                  className="NuclearBomb__Button NuclearBomb__Button--E"
                  onClick={() => act('anchor')}
                >
                  ANCHOR
                </Button>
                <Box textAlign="center" color="#9C9987" fontSize="80px">
                  <Icon name="radiation" />
                </Box>
                <Box height="80px" className="NuclearBomb__NTIcon" />
              </Box>
            </Stack.Item>
          </Stack>
        </Box>
      </Window.Content>
    </Window>
  );
}

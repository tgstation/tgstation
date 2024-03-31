import { classes } from 'common/react';

import { useBackend } from '../backend';
import { Box, Button, Flex, Icon } from '../components';
import { Window } from '../layouts';

// This ui is so many manual overrides and !important tags
// and hand made width sets that changing pretty much anything
// is going to require a lot of tweaking it get it looking correct again
// I'm sorry, but it looks bangin
export const NukeKeypad = (props) => {
  const { act } = useBackend();
  const keypadKeys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['C', '0', 'E'],
  ];
  return (
    <Box className="NuclearBomb__Button--keypad" width="185px">
      <Flex direction="column" justify="center">
        {keypadKeys.map((keyRow) => (
          <Flex direction="inline" key={keyRow[0]}>
            {keyRow.map((key, index) => (
              <Button
                fluid
                bold
                key={index + '_' + key}
                mb="6px"
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
          </Flex>
        ))}
      </Flex>
    </Box>
  );
};

export const NuclearBomb = (props) => {
  const { act, data } = useBackend();
  const { anchored, disk_present, status1, status2 } = data;
  // Side note, why the width in the flex?  Otherwise the text
  // box can scroll willy nilly
  return (
    <Window width={350} height={442} theme="retro">
      <Window.Content>
        <Flex direction="column" width={'340px'}>
          <Flex direction="column" mb={1.5}>
            <Flex.Item mb="6px" className="NuclearBomb__displayBox">
              {status1}
            </Flex.Item>
            <Flex>
              <Flex.Item grow={1}>
                <Box className="NuclearBomb__displayBox">{status2}</Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  icon="eject"
                  fontSize="24px"
                  lineHeight={1}
                  textAlign="center"
                  width="43px"
                  ml="6px"
                  mr="3px"
                  mt="3px"
                  className="NuclearBomb__Button NuclearBomb__Button--keypad"
                  onClick={() => act('eject_disk')}
                />
              </Flex.Item>
            </Flex>
          </Flex>

          <Flex ml="3px">
            <Flex.Item>
              <NukeKeypad />
            </Flex.Item>
            <Flex.Item ml="6px" width="129px">
              <Box>
                <Button
                  fluid
                  bold
                  content="ARM"
                  textAlign="center"
                  fontSize="28px"
                  lineHeight={1.1}
                  mb="6px"
                  className="NuclearBomb__Button NuclearBomb__Button--C"
                  onClick={() => act('arm')}
                />
                <Button
                  fluid
                  bold
                  content="ANCHOR"
                  textAlign="center"
                  fontSize="28px"
                  lineHeight={1.1}
                  className="NuclearBomb__Button NuclearBomb__Button--E"
                  onClick={() => act('anchor')}
                />
                <Box textAlign="center" color="#9C9987" fontSize="80px">
                  <Icon name="radiation" />
                </Box>
                <Box height="80px" className="NuclearBomb__NTIcon" />
              </Box>
            </Flex.Item>
          </Flex>
        </Flex>
      </Window.Content>
    </Window>
  );
};

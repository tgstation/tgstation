import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Flex, Grid, Icon } from '../components';
import { Window } from '../layouts';

// This ui is so many manual overrides and !important tags
// and hand made width sets that changing pretty much anything
// is going to require a lot of tweaking it get it looking correct again
// I'm sorry, but it looks bangin
const NukeKeypad = (props, context) => {
  const { act } = useBackend(context);
  const keypadKeys = [
    ['1', '4', '7', 'C'],
    ['2', '5', '8', '0'],
    ['3', '6', '9', 'E'],
  ];
  return (
    <Box width="185px">
      <Grid width="1px">
        {keypadKeys.map((keyColumn) => (
          <Grid.Column key={keyColumn[0]}>
            {keyColumn.map((key) => (
              <Button
                fluid
                bold
                key={key}
                mb="6px"
                content={key}
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
              />
            ))}
          </Grid.Column>
        ))}
      </Grid>
    </Box>
  );
};

export const NuclearBomb = (props, context) => {
  const { act, data } = useBackend(context);
  const { anchored, disk_present, status1, status2 } = data;
  return (
    <Window width={350} height={442} theme="retro">
      <Window.Content>
        <Box m="6px">
          <Box mb="6px" className="NuclearBomb__displayBox">
            {status1}
          </Box>
          <Flex mb={1.5}>
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
        </Box>
      </Window.Content>
    </Window>
  );
};

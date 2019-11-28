import { act } from '../byond';
import { Box, Button, Grid, Flex, Icon } from '../components';
import { classes } from 'common/react';

// This ui is so many manual overrides and !important tags
// and hand made width sets that changing pretty much anything
// is going to require a lot of tweaking it get it looking correct again
// I'm sorry, but it looks bangin
const NukeKeypad = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const keypadKeys = [
    ["1", "4", "7", "C"],
    ["2", "5", "8", "0"],
    ["3", "6", "9", "E"],
  ];
  return (
    <Box
      width="185px"
    >
      <Grid width="1px">
        {keypadKeys.map(keyColumn => (
          <Grid.Column key={keyColumn[0]}>
            {keyColumn.map(key => (
              <Button
                fluid
                bold
                key={key}
                mb={1}
                content={key}
                textAlign="center"
                fontSize="40px"
                lineHeight="50px"
                width="55px"
                className={classes([
                  "NuclearBomb__Button",
                  "NuclearBomb__Button--keypad",
                  "NuclearBomb__Button--" + key,
                ])}
                onClick={() => act(ref, "keypad", {digit: key})}
              />
            ))}
          </Grid.Column>
        ))}
      </Grid>
    </Box>
  );
};

export const NuclearStatusPanel = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
};

export const NuclearBomb = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    anchored,
    disk_present,
    status1,
    status2,
  } = data;
  return (
    <Box
      m={1}
    >
      <Box
        mb={1}
        className="NuclearBomb__displayBox"
      >
        {status1}
      </Box>
      <Flex mb={1.5}>
        <Flex.Item grow={1}>
          <Box
            className="NuclearBomb__displayBox"
          >
            {status2}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="eject"
            fontSize="24px"
            lineHeight="23px"
            textAlign="center"
            width="43px"
            ml={1}
            mr="3px"
            mt="3px"
            className="NuclearBomb__Button NuclearBomb__Button--keypad"
            onClick={() => act(ref, "eject_disk")}
          />
        </Flex.Item>
      </Flex>
      <Flex ml="3px">
        <Flex.Item>
          <NukeKeypad state={state} />
        </Flex.Item>
        <Flex.Item ml={1} width="129px">
          <Box>
            <Button
              fluid
              bold
              content="ARM"
              textAlign="center"
              fontSize="28px"
              lineHeight="32px"
              mb={1}
              className="NuclearBomb__Button NuclearBomb__Button--C"
              onClick={() => act(ref, "arm")}
            />
            <Button
              fluid
              bold
              content="ANCHOR"
              textAlign="center"
              fontSize="28px"
              lineHeight="32px"
              className="NuclearBomb__Button NuclearBomb__Button--E"
              onClick={() => act(ref, "anchor")}
            />
            <Box
              width="100%"
              textAlign="center"
              color="#9C9987"
              fontSize="80px"
            >
              <Icon
                name="radiation"
              />
            </Box>
            <Box
              width="100%"
              height="80px"
              className="NuclearBomb__NTIcon"
            />
          </Box>
        </Flex.Item>
      </Flex>
    </Box>
  );
};

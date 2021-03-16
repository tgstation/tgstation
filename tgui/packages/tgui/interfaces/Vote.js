import { useBackend } from "../backend";
import {
  Box,
  Icon,
  Flex,
  Button,
  Section,
  Collapsible,
} from "../components";
import { Window } from "../layouts";
import { logger } from "../logging";

export const Vote = (props, context) => {
  const { data } = useBackend(context);
  const { mode, question, lower_admin } = data;
  
  return (
    <Window
      resizable
      title={`Vote${
        mode
          ? `: ${
            question
              ? question.replace(/^\w/, c => c.toUpperCase())
              : mode.replace(/^\w/, c => c.toUpperCase())
          }`
          : ""
      }`}
      width={400}
      height={500} >
      <Window.Content overflowY="scroll">
        <Flex direction="column" height="100%">
          {!!lower_admin && <AdminPanel />}
          <ChoicesPanel />
          <TimePanel />
        </Flex>
      </Window.Content>
    </Window>
  );
};

// Collapsible panel for admin actions.
const AdminPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { avm, avr, avmap, voting, upper_admin } = data;
  return (
    <Flex.Item>
      <Section mb={1} title="Admin Options">
        <Collapsible title="Start a Vote">
          <Flex mt={2} justify="space-between">
            <Flex.Item>
              <Box mb={1}>
                <Button
                  disabled={!upper_admin || !avmap}
                  onClick={() => act("map")} >
                  Map
                </Button>
                {!!upper_admin && (
                  <Button.Checkbox
                    ml={1}
                    color="red"
                    checked={!avmap}
                    onClick={() => act("toggle_map")} >
                    Disable{!avmap ? "d" : ""}
                  </Button.Checkbox>
                )}
              </Box>
              <Box mb={1}>
                <Button
                  disabled={!upper_admin || !avr}
                  onClick={() => act("restart")} >
                  Restart
                </Button>
                {!!upper_admin && (
                  <Button.Checkbox
                    ml={1}
                    color="red"
                    checked={!avr}
                    onClick={() => act("toggle_restart")} >
                    Disable{!avr ? "d" : ""}
                  </Button.Checkbox>
                )}
              </Box>
              <Box mb={1}>
                <Button
                  disabled={!upper_admin || !avm}
                  onClick={() => act("gamemode")} >
                  Gamemode
                </Button>
                {!!upper_admin && (
                  <Button.Checkbox
                    ml={1}
                    color="red"
                    checked={!avm}
                    onClick={() => act("toggle_gamemode")} >
                    Disable{!avm ? "d" : ""}
                  </Button.Checkbox>
                )}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button disabled={!upper_admin} onClick={() => act("custom")}>
                Create Custom Vote
              </Button>
            </Flex.Item>
          </Flex>
        </Collapsible>
        <Collapsible title="View Voters">
          <Box mt={2} width="100%" height={6} overflowY="scroll">
            {voting.map(voter => {
              return <Box key={voter}>{voter}</Box>;
            })}
          </Box>
        </Collapsible>
      </Section>
    </Flex.Item>
  );
};

// Display choices as buttons
const ChoicesPanel = (props, context) => {
  const { data } = useBackend(context);
  const { mode, choices } = data;

  let content;
  if (choices.length === 0) {
    content = "No choices available!";
  }
  // Single box for most normal vote types
  else if ((choices.length < 10) | (mode === "custom")) {
    content = (
      <DisplayChoices
        choices={choices}
        tally="Votes:"
        startIndex={0}
        margin={1} />
    );
  } else {
    // If there's both too much content, most likely gamemode
    content = (
      <Flex justify="space-between" direction="row">
        <Flex direction="column">
          <DisplayChoices
            choices={choices.filter(
              (choice, index) => index < choices.length / 2
            )}
            tally="|"
            startIndex={0}
            margin={0} />
        </Flex>
        <Flex direction="column" ml={1}>
          <DisplayChoices
            choices={choices.filter(
              (choice, index) => index > choices.length / 2
            )}
            tally="|"
            startIndex={Math.ceil(choices.length / 2)}
            margin={0} />
        </Flex>
      </Flex>
    );
  }

  return (
    <Flex.Item mb={1} grow={1}>
      <Section fill title="Choices">
        {content}
      </Section>
    </Flex.Item>
  );
};

const DisplayChoices = (props, context) => {
  const { act, data } = useBackend(context);
  const { selectedChoice } = data;

  return props.choices?.map((choice, i) => (
    <Flex justify="space-between" direction="row" key={i} mb={props.margin}>
      <Flex>
        <Button
          onClick={() => {
            act("vote", {
              index: i + props.startIndex + 1,
            });
          }}
          disabled={
            choice === props.choices[selectedChoice - props.startIndex - 1]
          } >
          {choice.name?.replace(/^\w/, c => c.toUpperCase())}
        </Button>
        <Box mt={0.4} ml={1}>
          {choice === props.choices[selectedChoice - props.startIndex - 1] && (
            <Icon color="green" name="vote-yea" />
          )}
        </Box>
      </Flex>
      <Box ml={1}>
        {props.tally} {choice.votes}
      </Box>
    </Flex>
  ));
};

// Countdown timer at the bottom. Includes a cancel vote option for admins
const TimePanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { upper_admin, time_remaining } = data;

  return (
    <Flex.Item>
      <Section>
        <Flex justify="space-between">
          {!!upper_admin && (
            <Button
              onClick={() => {
                act("cancel");
              }}
              color="red" >
              Cancel Vote
            </Button>
          )}
          <Box fontSize={1.5} textAlign="right">
            Time Remaining: {time_remaining}s
          </Box>
        </Flex>
      </Section>
    </Flex.Item>
  );
};

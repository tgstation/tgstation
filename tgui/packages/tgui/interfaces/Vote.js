import { useBackend } from "../backend";
import {
  Box,
  Icon,
  Stack,
  Button,
  Section,
  NoticeBox,
  LabeledList,
  Collapsible,
} from "../components";
import { Window } from "../layouts";

export const Vote = (props, context) => {
  const { data } = useBackend(context);
  const { mode, question, lower_admin } = data;

  // Adds the voting type to title if there is an ongoing vote
  let windowTitle = "Vote";
  if (mode) {
    windowTitle
      += ": " + (question || mode).replace(/^\w/, c => c.toUpperCase());
  }

  return (
    <Window resizable title={windowTitle} width={400} height={500}>
      <Window.Content>
        <Stack fill direction="column">
          {!!lower_admin && (
            <Section title="Admin Options">
              <VoteOptions />
              <VotersList />
            </Section>
          )}
          <ChoicesPanel />
          <TimePanel />
        </Stack>
      </Window.Content>
    </Window>
  );
};

// Gives access to starting votes
const VoteOptions = (props, context) => {
  const { act, data } = useBackend(context);
  const { avm, avr, avmap, upper_admin } = data;
  return (
    <Stack.Item>
      <Collapsible title="Start a Vote">
        <Stack justify="space-between">
          <Stack.Item>
            <Stack direction="column">
              <Stack.Item mb={1}>
                {!!upper_admin && (
                  <Button.Checkbox
                    ml={1}
                    color="red"
                    checked={avmap}
                    onClick={() => act("toggle_map")}
                  >
                    {avmap ? "Enabled" : "Disabled"}
                  </Button.Checkbox>
                )}
                <Button
                  disabled={!upper_admin || !avmap}
                  onClick={() => act("map")}
                >
                  Map
                </Button>
              </Stack.Item>
              <Stack.Item mb={1}>
                {!!upper_admin && (
                  <Button.Checkbox
                    ml={1}
                    color="red"
                    checked={avr}
                    onClick={() => act("toggle_restart")}
                  >
                    {avr ? "Enabled" : "Disabled"}
                  </Button.Checkbox>
                )}
                <Button
                  disabled={!upper_admin || !avr}
                  onClick={() => act("restart")}
                >
                  Restart
                </Button>
              </Stack.Item>
              <Stack.Item>
                {!!upper_admin && (
                  <Button.Checkbox
                    ml={1}
                    color="red"
                    checked={avm}
                    onClick={() => act("toggle_gamemode")}
                  >
                    {avm ? "Enabled" : "Disabled"}
                  </Button.Checkbox>
                )}
                <Button
                  disabled={!upper_admin || !avm}
                  onClick={() => act("gamemode")}
                >
                  Gamemode
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button disabled={!upper_admin} onClick={() => act("custom")}>
              Create Custom Vote
            </Button>
          </Stack.Item>
        </Stack>
      </Collapsible>
    </Stack.Item>
  );
};

// Table to view voters by ckey
const VotersList = (props, context) => {
  const { data } = useBackend(context);
  const { voting } = data;

  return (
    <Stack.Item>
      <Collapsible title={`View Voters: ${voting.length}`}>
        <Box mt={2} width="100%" height={6} overflowY="scroll">
          {voting.map(voter => {
            return <Box key={voter}>{voter}</Box>;
          })}
        </Box>
      </Collapsible>
    </Stack.Item>
  );
};

// Display choices
const ChoicesPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { choices, selectedChoice } = data;

  return (
    <Stack.Item grow basis={0}>
      <Section fill scrollable title="Choices">
        {choices.length !== 0 ? (
          <LabeledList>
            {choices.map((choice, i) => (
              <Box key={choice.id}>
                <LabeledList.Item
                  label={choice.name.replace(/^\w/, c => c.toUpperCase())}
                  textAlign="right"
                  buttons={
                    <Button
                      disabled={i === selectedChoice - 1}
                      onClick={() => {
                        act("vote", { index: i + 1 });
                      }}
                    >
                      Vote
                    </Button>
                  }
                >
                  {i === selectedChoice - 1 && (
                    <Icon
                      alignSelf="right"
                      mr={2}
                      color="green"
                      name="vote-yea"
                    />
                  )}
                  {choice.votes} Votes
                </LabeledList.Item>
                <LabeledList.Divider />
              </Box>
            ))}
          </LabeledList>
        ) : (
          <NoticeBox>No choices available!</NoticeBox>
        )}
      </Section>
    </Stack.Item>
  );
};

// Countdown timer at the bottom. Includes a cancel vote option for admins
const TimePanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { upper_admin, time_remaining } = data;

  return (
    <Stack.Item mt={1}>
      <Section>
        <Stack justify="space-between">
          {!!upper_admin && (
            <Button
              onClick={() => {
                act("cancel");
              }}
              color="red"
            >
              Cancel Vote
            </Button>
          )}
          <Box fontSize={1.5} textAlign="right">
            Time Remaining: {time_remaining}s
          </Box>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

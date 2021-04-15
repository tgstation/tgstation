import { useBackend } from "../backend";
import { Box, Icon, Stack, Button, Section, NoticeBox, LabeledList, Collapsible } from "../components";
import { Window } from "../layouts";

export const Vote = (props, context) => {
  const { data } = useBackend(context);
  const { mode, question, lower_admin } = data;

  // Adds the voting type to title if there is an ongoing vote
  let windowTitle = "Vote";
  if (mode) {
    windowTitle += ": " + (question || mode).replace(/^\w/, c => c.toUpperCase());
  }

  return (
    <Window resizable title={windowTitle} width={400} height={500}>
      <Window.Content>
        <Stack fill vertical>
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
  const {
    allow_vote_mode,
    allow_vote_restart,
    allow_vote_map,
    upper_admin,
  } = data;

  return (
    <Stack.Item>
      <Collapsible title="Start a Vote">
        <Stack justify="space-between">
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                {!!upper_admin && (
                  <Button.Checkbox
                    mr={!allow_vote_map ? 1 : 1.6}
                    color="red"
                    checked={!!allow_vote_map}
                    onClick={() => act("toggle_map")}>
                    {allow_vote_map ? "Enabled" : "Disabled"}
                  </Button.Checkbox>
                )}
                <Button
                  disabled={!upper_admin || !allow_vote_map}
                  onClick={() => act("map")}>
                  Map
                </Button>
              </Stack.Item>
              <Stack.Item>
                {!!upper_admin && (
                  <Button.Checkbox
                    mr={!allow_vote_restart ? 1 : 1.6}
                    color="red"
                    checked={!!allow_vote_restart}
                    onClick={() => act("toggle_restart")}>
                    {allow_vote_restart ? "Enabled" : "Disabled"}
                  </Button.Checkbox>
                )}
                <Button
                  disabled={!upper_admin || !allow_vote_restart}
                  onClick={() => act("restart")}>
                  Restart
                </Button>
              </Stack.Item>
              <Stack.Item>
                {!!upper_admin && (
                  <Button.Checkbox
                    mr={!allow_vote_mode ? 1 : 1.6}
                    color="red"
                    checked={!!allow_vote_mode}
                    onClick={() => act("toggle_gamemode")}>
                    {allow_vote_mode ? "Enabled" : "Disabled"}
                  </Button.Checkbox>
                )}
                <Button
                  disabled={!upper_admin || !allow_vote_mode}
                  onClick={() => act("gamemode")}>
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
        <Section height={8} fill scrollable>
          {voting.map(voter => {
            return <Box key={voter}>{voter}</Box>;
          })}
        </Section>
      </Collapsible>
    </Stack.Item>
  );
};

// Display choices
const ChoicesPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { choices, selected_choice } = data;

  return (
    <Stack.Item grow>
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
                      disabled={i === selected_choice - 1}
                      onClick={() => {
                        act("vote", { index: i + 1 });
                      }}>
                      Vote
                    </Button>
                  }>
                  {i === selected_choice - 1 && (
                    <Icon
                      alignSelf="right"
                      mr={2}
                      color="green"
                      name="vote-yea" />
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
          <Box fontSize={1.5}>
            Time Remaining: {time_remaining || 0}s
          </Box>
          {!!upper_admin && (
            <Button color="red" onClick={() => act('cancel')}>
              Cancel Vote
            </Button>
          )}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

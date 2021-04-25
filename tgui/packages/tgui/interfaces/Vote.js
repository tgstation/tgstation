import { useBackend } from '../backend';
import { Box, Icon, Stack, Button, Section, NoticeBox, LabeledList, Collapsible } from '../components';
import { Window } from '../layouts';

export const Vote = (props, context) => {
  const { data } = useBackend(context);
  const { mode, question, lower_admin } = data;

  /**
   * Adds the voting type to title if there is an ongoing vote.
   */
  let windowTitle = 'Vote';
  if (mode) {
    windowTitle += ': ' + (question || mode).replace(/^\w/, (c) => c.toUpperCase());
  }

  return (
    <Window resizable title={windowTitle} width={400} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Section title="Create Vote">
            <VoteOptions />
            {!!lower_admin && <VotersList />}
          </Section>
          <ChoicesPanel />
          <TimePanel />
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * The create vote options menu. Only upper admins can disable voting.
 * @returns A section visible to everyone with vote options.
 */
const VoteOptions = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    allow_vote_restart,
    allow_vote_map,
    lower_admin,
    upper_admin,
  } = data;

  return (
    <Stack.Item>
      <Collapsible title="Start a Vote">
        <Stack justify="space-between">
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                {!!lower_admin && (
                  <Button.Checkbox
                    mr={!allow_vote_map ? 1 : 1.6}
                    color="red"
                    checked={!!allow_vote_map}
                    disabled={!upper_admin}
                    onClick={() => act('toggle_map')}>
                    {allow_vote_map ? 'Enabled' : 'Disabled'}
                  </Button.Checkbox>
                )}
                <Button disabled={!allow_vote_map} onClick={() => act('map')}>
                  Map
                </Button>
              </Stack.Item>
              <Stack.Item>
                {!!lower_admin && (
                  <Button.Checkbox
                    mr={!allow_vote_restart ? 1 : 1.6}
                    color="red"
                    checked={!!allow_vote_restart}
                    disabled={!upper_admin}
                    onClick={() => act('toggle_restart')}>
                    {allow_vote_restart ? 'Enabled' : 'Disabled'}
                  </Button.Checkbox>
                )}
                <Button
                  disabled={!allow_vote_restart}
                  onClick={() => act('restart')}>
                  Restart
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            {!!lower_admin && (
              <Button disabled={!lower_admin} onClick={() => act('custom')}>
                Create Custom Vote
              </Button>
            )}
          </Stack.Item>
        </Stack>
      </Collapsible>
    </Stack.Item>
  );
};

/**
 * View Voters by ckey. Admin only.
 * @returns A collapsible list of voters
 */
const VotersList = (props, context) => {
  const { data } = useBackend(context);
  const { voting } = data;

  return (
    <Stack.Item>
      <Collapsible title={`View Voters${voting.length ? `: ${voting.length}` : ""}`}>
        <Section height={8} fill scrollable>
          {voting.map((voter) => {
            return <Box key={voter}>{voter}</Box>;
          })}
        </Section>
      </Collapsible>
    </Stack.Item>
  );
};

/**
 * The choices panel which displays all options in the list.
 * @returns A section visible to all users.
 */
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
                  label={choice.name.replace(/^\w/, (c) => c.toUpperCase())}
                  textAlign="right"
                  buttons={
                    <Button
                      disabled={i === selected_choice - 1}
                      onClick={() => {
                        act('vote', { index: i + 1 });
                      }}>
                      Vote
                    </Button>
                  }>
                  {i === selected_choice - 1 && (
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

/**
 * Countdown timer at the bottom. Includes a cancel vote option for admins.
 * @returns A section visible to everyone.
 */
const TimePanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { lower_admin, time_remaining } = data;

  return (
    <Stack.Item mt={1}>
      <Section>
        <Stack justify="space-between">
          <Box fontSize={1.5}>Time Remaining: {time_remaining || 0}s</Box>
          {!!lower_admin && (
            <Button
              color="red"
              disabled={!lower_admin}
              onClick={() => act('cancel')}>
              Cancel Vote
            </Button>
          )}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

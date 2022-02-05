import { useBackend } from '../backend';
import { Box, Button, Collapsible, Icon, LabeledList, NoticeBox, Stack, Section } from '../components';
import { Window } from '../layouts';

type VoteData = {
  allow_vote_map: boolean;
  allow_vote_restart: boolean;
  choices: VoteChoice[];
  lower_admin: boolean;
  mode?: string;
  upper_admin: boolean;
  selected_choice?: number;
  time_remaining: number;
  question?: string;
  voting: string[];
};

type VoteChoice = {
  id: number;
  name: string;
  votes: number;
};

export const Vote = (_, context) => {
  const { data } = useBackend<VoteData>(context);
  const { mode, question } = data;
  /**
   * Adds the voting type to title if there is an ongoing vote.
   */
  let windowTitle = 'Vote';
  if (mode) {
    windowTitle
      += ': ' + (question || mode).replace(/^\w/, (c) => c.toUpperCase());
  }

  return (
    <Window resizable title={windowTitle} width={400} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <CreateVote />
          </Stack.Item>
          <Stack.Item grow>
            <ChoicesPanel />
          </Stack.Item>
          <Stack.Item>
            <TimePanel />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * Section for creating new votes.
 */
const CreateVote = (_, context) => {
  const { data } = useBackend<VoteData>(context);
  const { lower_admin } = data;

  return (
    <Section fill title="Create Vote">
      <VoteOptions />
      {!!lower_admin && <VotersList />}
    </Section>
  );
};

/**
 * The options for starting a vote. Only upper admins can disable voting.
 */
const VoteOptions = (_, context) => {
  const { act, data } = useBackend<VoteData>(context);
  const { allow_vote_restart, allow_vote_map, lower_admin, upper_admin } = data;

  return (
    <Collapsible title="Start a Vote">
      <Stack>
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
  );
};

/**
 * View Voters by ckey. Admin only.
 */
const VotersList = (_, context) => {
  const { data } = useBackend<VoteData>(context);
  const { voting = [] } = data;

  return (
    <Collapsible
      title={`View Voters${voting.length ? `: ${voting.length}` : ''}`}>
      <Section height={8} fill scrollable>
        {voting.map((voter) => {
          return <Box key={voter}>{voter}</Box>;
        })}
      </Section>
    </Collapsible>
  );
};

/**
 * The choices panel which displays all options in the list.
 */
const ChoicesPanel = (_, context) => {
  const { act, data } = useBackend<VoteData>(context);
  const { choices = [], selected_choice } = data;

  return (
    <Section fill scrollable title="Choices">
      {choices.length === 0 ? (
        <NoticeBox>No choices available!</NoticeBox>
      ) : (
        <LabeledList>
          {choices.map((choice, i) => (
            <Box key={choice.id}>
              <LabeledList.Item
                label={choice.name.replace(/^\w/, (c) => c.toUpperCase())}
                textAlign="right"
                buttons={
                  <Button
                    disabled={selected_choice && i === selected_choice - 1}
                    onClick={() => {
                      act('vote', { index: i + 1 });
                    }}>
                    Vote
                  </Button>
                }>
                {selected_choice && i === selected_choice - 1 && (
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
      )}
    </Section>
  );
};

/**
 * Countdown timer at the bottom. Includes a cancel vote option for admins.
 */
const TimePanel = (_, context) => {
  const { act, data } = useBackend<VoteData>(context);
  const { lower_admin, time_remaining } = data;

  return (
    <Section fill>
      <Stack>
        <Stack.Item grow>
          {!!time_remaining && (
            <Box fontSize={1.5}>Time Remaining: {time_remaining}s</Box>
          )}
        </Stack.Item>
        {!!lower_admin && (
          <Stack.Item>
            <Button
              color="red"
              disabled={!lower_admin || !time_remaining}
              onClick={() => act('cancel')}>
              Cancel Vote
            </Button>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

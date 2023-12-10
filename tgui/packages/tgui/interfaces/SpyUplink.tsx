import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';
import { BlockQuote, Box, Dimmer, Icon, Section, Stack } from '../components';

type Bounty = {
  name: string;
  help: string;
  difficulty: string;
  reward: string;
  claimed: BooleanLike;
};

type Data = {
  time_left: number;
  bounties: Bounty[];
};

const difficulty_to_color = {
  easy: 'good',
  medium: 'average',
  hard: 'bad',
};

const BountyDisplay = (props: { bounty: Bounty }) => {
  const { bounty } = props;

  return (
    <Section>
      {!!bounty.claimed && (
        <Dimmer>
          <Stack>
            <Stack.Item>
              <Icon name="user-secret" size={2} color="bad" />
            </Stack.Item>
            <Stack.Item align={'center'}>
              <i>Claimed!</i>
            </Stack.Item>
          </Stack>
        </Dimmer>
      )}
      <Stack vertical ml={1}>
        <Stack.Item>
          <Box color={difficulty_to_color[bounty.difficulty.toLowerCase()]}>
            {bounty.name}.
          </Box>
        </Stack.Item>
        <Stack.Item>
          <BlockQuote>
            <i>{bounty.help}</i>
          </BlockQuote>
        </Stack.Item>
        <Stack.Item>
          <i>Reward: {bounty.reward}</i>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

// Formats a number of deciseconds into a string minutes:seconds
const format_deciseconds = (deciseconds: number) => {
  const seconds = Math.floor(deciseconds / 10);
  const minutes = Math.floor(seconds / 60);

  const seconds_left = seconds % 60;
  const minutes_left = minutes % 60;

  const seconds_string = seconds_left.toString().padStart(2, '0');
  const minutes_string = minutes_left.toString().padStart(2, '0');

  return `${minutes_string}:${seconds_string}`;
};

export const SpyUplink = () => {
  const { data } = useBackend<Data>();
  const { bounties, time_left } = data;

  return (
    <Window width={450} height={615} theme="ntos_darkmode">
      <Window.Content
        style={{
          'background-image': 'none',
        }}
      >
        <Section
          fill
          title="Spy Bounties"
          scrollable
          buttons={
            <Box mt={0.4}>
              Time until refresh: {format_deciseconds(time_left)}
            </Box>
          }
        >
          <Stack vertical fill>
            <Stack.Item>
              {bounties.map((bounty) => (
                <Stack.Item key={bounty.name} className="candystripe">
                  <BountyDisplay bounty={bounty} />
                </Stack.Item>
              ))}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

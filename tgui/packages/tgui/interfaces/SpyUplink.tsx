import {
  BlockQuote,
  Box,
  Dimmer,
  Icon,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Bounty = {
  name: string;
  help: string;
  difficulty: string;
  reward: string;
  claimed: BooleanLike;
  can_claim: BooleanLike;
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

const BountyDimmer = (props: { text: string; color: string }) => {
  return (
    <Dimmer>
      <Stack>
        <Stack.Item>
          <Icon name="user-secret" size={2} color={props.color} />
        </Stack.Item>
        <Stack.Item align={'center'} italic>
          {props.text}
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const BountyDisplay = (props: { bounty: Bounty }) => {
  const { bounty } = props;

  return (
    <Section>
      {!!bounty.claimed && <BountyDimmer color="bad" text="Claimed!" />}
      {!bounty.can_claim && !bounty.claimed && (
        <BountyDimmer
          color="average"
          text="Your benefactors see you unfit to complete this."
        />
      )}
      <Stack vertical ml={1}>
        <Stack.Item>
          <Box
            style={{
              textTransform: 'capitalize',
            }}
            color={difficulty_to_color[bounty.difficulty.toLowerCase()]}
          >
            {bounty.name}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <BlockQuote italic>{bounty.help}</BlockQuote>
        </Stack.Item>
        <Stack.Item italic>Reward: {bounty.reward}</Stack.Item>
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
          backgroundImage: 'none',
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

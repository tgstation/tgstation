import { useBackend } from '../backend';
import { Section, Stack, Box } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';

const hereticstyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

type Objective = {
  count: number;
  name: string;
  explanation: string;
}

type Info = {
  total_sacrifices: number;
  ascended: BooleanLike;
  objectives: Objective[];
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    objectives,
  } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>
        The old ones gave you these tasks to fulfill:
      </Stack.Item>
      <Stack.Item>
        {!objectives && "None!"
        || objectives.map(objective => (
          <Stack.Item key={objective.count}>
            {objective.count}: {objective.explanation}
          </Stack.Item>
        )) }
      </Stack.Item>
    </Stack>
  );
};

const InformationSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    total_sacrifices,
    ascended,
  } = data;
  return (
    <Stack vertical fill>
      {!!ascended && (
        <Stack.Item>
          <Stack width="100%" justify="space-evenly" align="center" inline>
            <Stack.Item>
              You have
            </Stack.Item>
            <Stack.Item>
              <Box inline fontSize="24px" color="red">ASCENDED</Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      )}
      <Stack.Item grow>
        You have made a total of {total_sacrifices || 0} sacrifices.
      </Stack.Item>
    </Stack>
  );
};

const IntroductionSection = (props, context) => {
  return (
    <Stack
      align="center"
      justify="space-evenly"
      height="100%"
      width="100%"
    >
      <Stack.Item width="100%">
        <Section title="You are the Heretic!" fill>
          <Stack vertical fill>
            <Stack.Item>
              Another day at a meaningless job.
              You feel a <Box inline color="red">shimmer</Box> around you,
              as a realization of something <Box inline color="blue">strange</Box> in your backpack unfolds.
              You look at it, unknowingly opening a new chapter in your life.
              The <Box inline color="red">Gates of Mansus</Box> open up to your mind.
              Their hand is at your throat, yet you see Them not.
            </Stack.Item>
            <Stack.Item>
              <InformationSection />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item grow>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoHeretic = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    ascended,
  } = data;
  return (
    <Window
      width={620}
      height={320}
    >
      <Window.Content
        style={{
          "background-image": "none",
          "background": ascended
            ? "radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%);"
            : "radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%);",
        }}
      >
        <IntroductionSection />
      </Window.Content>
    </Window>
  );
};

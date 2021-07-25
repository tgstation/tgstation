import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Button, Dimmer, Section, Stack } from '../components';
import { Window } from '../layouts';

const hivestyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const goalstyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

type Objective = {
  count: number;
  name: string;
  explanation: string;
}

type Info = {
  hive_name: string;
  stolen_antag_info: string;
  memories: string[];
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
        Your current objectives:
      </Stack.Item>
      <Stack.Item>
        {!objectives && "None!"
        || objectives.map(objective => (
          <Stack.Item key={objective.count}>
            #{objective.count}: {objective.explanation}
          </Stack.Item>
        )) }
      </Stack.Item>
    </Stack>
  );
};

const IntroductionSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    hive_name,
  } = data;
  return (
    <Section fill title="Intro" scrollable>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          You are the Changeling from the
          <span style={hivestyle}>
            &ensp;{hive_name}
          </span>.
        </Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MemoriesSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    memories,
  } = data;
  return (
    <Section fill scrollable title="Stolen Memories">
      <Stack vertical fill>
        <Stack.Item>
          <BlockQuote>
            As a Changeling, absorbing targets allows
            you to collect their memories. They should
            help you impersonate your target!
          </BlockQuote>
        </Stack.Item>
        <Stack.Divider mr={1} />
        <Stack.Item grow>
          <Stack vertical>
            {!memories && "None!"
            || memories.map(memory => (
              <Stack.Item key={memory}>
                <Button
                  onClick={() => act('read_memory', {
                    name: memory,
                  })}>
                  {memory}
                </Button>
              </Stack.Item>
            )) }
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const VictimPatternsSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    stolen_antag_info,
  } = data;
  return (
    <Section fill scrollable title="Additional Stolen Information">
      {stolen_antag_info}
    </Section>
  );
};

export const AntagInfoChangeling = (props, context) => {
  const { data } = useBackend<Info>(context);
  return (
    <Window
      width={620}
      height={580}
      theme="neutral">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <MemoriesSection />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <VictimPatternsSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

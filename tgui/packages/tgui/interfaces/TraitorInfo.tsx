import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Section, Stack } from '../components';
import { Window } from '../layouts';

const boldstyle = {
  fontWeight: 'bold',
  color: 'lightgreen',
};

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const goalstyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

type Objective = {
  explanation: string;
}

type Info = {
  phrases: string;
  responses: string;
  theme: string;
  allies: string;
  goal: string;
  intro: string;
  uplink: string;
  uplink_unlock_info: string;
  objectives: Array<Objective>;
};

const IntroductionSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    intro,
    allies,
    objectives,
  } = data;
  return (
    <Section title="Intro">
      <Stack vertical>
        <Stack.Item fontSize="25px">
          {intro}
        </Stack.Item>
        <Stack.Item>
          Your current objectives:
        </Stack.Item>
        <Stack.Item>
          {!objectives && "None!" || "Found!" }
        </Stack.Item>
        <Stack.Item>
          <span style={boldstyle}>
            Your allegiances:&ensp;
          </span>
          &quot;{allies}&quot;
        </Stack.Item>
        <Stack.Item>
          <span style={goalstyle}>
            Your goals:&ensp;
          </span>
          &quot;WIP&quot;
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const UplinkSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    uplink,
    uplink_unlock_info,
  } = data;
  return (
    <Section title="Uplink" fill>
      <Stack vertical textAlign="center" fill>
        <Stack.Item bold grow>
          {uplink}
        </Stack.Item>
        <Stack.Item grow>
          How to unlock your uplink:
        </Stack.Item>
        <Stack.Item>
          {uplink_unlock_info}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const CodewordsSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    phrases,
    responses,
  } = data;
  return (
    <Section title="Codewords">
      <Stack fill>
        <Stack.Item grow>
          <BlockQuote>
            The Syndicate have provided you with the following
            codewords to identify fellow agents. Use the codewords
            during regular conversation to identify other agents.
            Proceed with caution, however, as everyone is a
            potential foe.
            <span style={badstyle}>
              &ensp;You have memorized the codewords, allowing you
              to recognise them when heard.
            </span>
          </BlockQuote>
        </Stack.Item>
        <Stack.Divider mr={1} />
        <Stack.Item>
          <Stack vertical fill>
            <Stack.Item grow>
              Code Phrases:
            </Stack.Item>
            <Stack.Item grow bold textColor="blue">
              {phrases}
            </Stack.Item>
            <Stack.Item grow>
              Code Responses:
            </Stack.Item>
            <Stack.Item grow bold textColor="red">
              {responses}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const TraitorInfo = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    theme,
    allies,
    intro,
  } = data;
  return (
    <Window
      width={620}
      height={580}
      theme={theme}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow>
            <UplinkSection />
          </Stack.Item>
          <Stack.Item>
            <CodewordsSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

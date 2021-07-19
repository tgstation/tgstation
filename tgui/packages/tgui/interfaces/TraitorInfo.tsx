import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Dimmer, Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
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
  phrases: string;
  responses: string;
  theme: string;
  allies: string;
  goal: string;
  intro: string;
  code: string;
  has_uplink: BooleanLike;
  uplink_intro: string;
  uplink_unlock_info: string;
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
    intro,
  } = data;
  return (
    <Section fill title="Intro" scrollable>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          {intro}
        </Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const UplinkSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    has_uplink,
    uplink_intro,
    uplink_unlock_info,
    code,
  } = data;
  return (
    <Section
      title="Uplink"
      mb={!has_uplink && -1}>
      <Stack fill>
        {!has_uplink && (
          <Dimmer>
            <Stack.Item fontSize="18px">
              You were not supplied with an uplink.
            </Stack.Item>
          </Dimmer>
        ) || (
          <>
            <Stack.Item bold>
              {uplink_intro}
              <br />
              <span style={goalstyle}>Code: {code}</span>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <BlockQuote grow>
                {uplink_unlock_info}
              </BlockQuote>
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

const CodewordsSection = (props, context) => {
  const { data } = useBackend<Info>(context);
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
  } = data;
  return (
    <Window
      width={620}
      height={580}
      theme={theme}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item>
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

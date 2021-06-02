import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

const allystyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const goalstyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

const employerstyle = {
  fontWeight: 'bold',
};

type Objective = {
  count: number,
  name: string,
  explanation: string,
  complete: BooleanLike,
  uncompleted: BooleanLike,
  reward: number,
}

type Info = {
  phrases: string;
  responses: string;
  theme: string;
  allies: string;
  goal: string;
  intro: string;
  has_uplink: BooleanLike;
  uplink_intro: string;
  uplink_unlock_info: string;
  objectives: Objective[];
};

const ObjectivePrintout = (props, context) => {
  const { act, data } = useBackend<Info>(context);
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
          <>
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
            {!objective.complete && (
              <>
                <Stack.Item textColor="red">
                  Incomplete.
                </Stack.Item>
                {!!objective.reward && !objective.uncompleted && (
                  <Stack.Item textColor="lightgrey">
                    Reward of {objective.reward} black TC upon completion.
                  </Stack.Item>
                ) || (
                  <Stack.Item textColor="lightgrey">
                    No reward.
                  </Stack.Item>
                )}
              </>
            ) || (
              <Stack.Item textColor="green">
                Complete!
              </Stack.Item>
            )}
          </>
        )) }
      </Stack.Item>
    </Stack>
  );
};

const IntroductionSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    intro,
    allies,
    goal,
  } = data;
  return (
    <Section fill title="Intro">
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

const EmployerSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    intro,
    allies,
    goal,
  } = data;
  return (
    <Section fill title="Employer">
      <Stack vertical fill>
        <Stack.Item grow>
          <Stack vertical>
            <Stack.Item>
              <span style={allystyle}>
                Your allegiances:<br />
              </span>
              <BlockQuote>
                {allies}
              </BlockQuote>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <span style={goalstyle}>
                Employer thoughts:<br />
              </span>
              <BlockQuote>
                {goal}
              </BlockQuote>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const UplinkSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    uplink_intro,
    uplink_unlock_info,
  } = data;
  return (
    <Section title="Uplink">
      <Stack fill>
        <Stack.Item bold>
          {uplink_intro}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <BlockQuote grow>
            {uplink_unlock_info}
          </BlockQuote>
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
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="70%">
                <IntroductionSection />
              </Stack.Item>
              <Stack.Item width="30%">
                <EmployerSection />
              </Stack.Item>
            </Stack>
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

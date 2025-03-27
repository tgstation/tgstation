import { BlockQuote, Button, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Objective, ObjectivePrintout } from './common/Objectives';

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

type Info = {
  has_codewords: BooleanLike;
  phrases: string;
  responses: string;
  theme: string;
  allies: string;
  goal: string;
  intro: string;
  code: string;
  failsafe_code: string;
  has_uplink: BooleanLike;
  uplink_intro: string;
  uplink_unlock_info: string;
  given_uplink: BooleanLike;
  objectives: Objective[];
};

const IntroductionSection = (props) => {
  const { act, data } = useBackend<Info>();
  const { intro, objectives } = data;
  return (
    <Section fill title="Intro" scrollable>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">{intro}</Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout objectives={objectives} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EmployerSection = (props) => {
  const { data } = useBackend<Info>();
  const { allies, goal } = data;
  return (
    <Section
      fill
      title="Employer"
      scrollable
      buttons={
        <Button
          icon="hammer"
          tooltip={`
            This is a gameplay suggestion for bored traitors.
            You don't have to follow it, unless you want some
            ideas for how to spend the round.`}
          tooltipPosition="bottom-start"
        >
          Policy
        </Button>
      }
    >
      <Stack vertical fill>
        <Stack.Item grow>
          <Stack vertical>
            <Stack.Item>
              <span style={allystyle}>
                Your allegiances:
                <br />
              </span>
              <BlockQuote>{allies}</BlockQuote>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <span style={goalstyle}>
                Employer thoughts:
                <br />
              </span>
              <BlockQuote>{goal}</BlockQuote>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const UplinkSection = (props) => {
  const { data } = useBackend<Info>();
  const { has_uplink, uplink_intro, uplink_unlock_info, code, failsafe_code } =
    data;
  return (
    <Section title="Uplink" mb={!has_uplink && -1}>
      <Stack fill>
        {
          <>
            <Stack.Item bold>
              {uplink_intro}
              <br />
              {code && <span style={goalstyle}>Code: {code}</span>}
              <br />
              {failsafe_code && (
                <span style={badstyle}>Failsafe: {failsafe_code}</span>
              )}
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item mt="1%">
              <BlockQuote>{uplink_unlock_info}</BlockQuote>
            </Stack.Item>
          </>
        }
      </Stack>
      <br />
      {
        <Section>
          {' '}
          <br />
          <br />
        </Section>
      }
    </Section>
  );
};

const CodewordsSection = (props) => {
  const { data } = useBackend<Info>();
  const { has_codewords, phrases, responses } = data;
  return (
    <Section title="Codewords" mb={!has_codewords && -1}>
      <Stack fill>
        {(!has_codewords && (
          <BlockQuote>
            You have not been supplied with codewords. You will have to use
            alternative methods to find potential allies. Proceed with caution,
            however, as everyone is a potential foe.
          </BlockQuote>
        )) || (
          <>
            <Stack.Item grow basis={0}>
              <BlockQuote>
                Your employer provided you with the following codewords to
                identify fellow agents. Use the codewords during regular
                conversation to identify other agents. Proceed with caution,
                however, as everyone is a potential foe.
                <span style={badstyle}>
                  &ensp;You have memorized the codewords, allowing you to
                  recognise them when heard.
                </span>
              </BlockQuote>
            </Stack.Item>
            <Stack.Divider mr={1} />
            <Stack.Item grow basis={0}>
              <Stack vertical>
                <Stack.Item>Code Phrases:</Stack.Item>
                <Stack.Item bold textColor="blue">
                  {phrases}
                </Stack.Item>
                <Stack.Item>Code Responses:</Stack.Item>
                <Stack.Item bold textColor="red">
                  {responses}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

export const AntagInfoTraitor = (props) => {
  const { data } = useBackend<Info>();
  const { theme, given_uplink } = data;
  return (
    <Window width={620} height={580} theme={theme}>
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
          {!!given_uplink && (
            <Stack.Item>
              <UplinkSection />
            </Stack.Item>
          )}
          <Stack.Item>
            <CodewordsSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

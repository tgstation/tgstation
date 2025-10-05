import { Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const greenText = {
  fontWeight: 'italics',
  color: '#20b142',
};

const redText = {
  fontWeight: 'italics',
  color: '#e03c3c',
};

type Data = {
  antag_name: string;
  uplink_location: string | null;
  objectives: Objective[];
  can_change_objective: BooleanLike;
};

export const AntagInfoSpy = () => {
  const { data } = useBackend<Data>();
  const { antag_name, uplink_location, objectives, can_change_objective } =
    data;
  return (
    <Window width={380} height={450} theme="ntos_darkmode">
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Section title={`You are the ${antag_name || 'Spy'}.`}>
          <Stack vertical fill ml={1} mr={1}>
            <Stack.Item fontSize={1.2}>
              You have been equipped with a special uplink device disguised as{' '}
              {uplink_location || 'something'} that will allow you to steal from
              the station.
            </Stack.Item>
            <Stack.Item>
              <span style={greenText}>
                <b>Use it in hand</b> to access your uplink, and{' '}
                <b>right click</b> on bounty targets to steal them.
              </span>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              You may not be alone: There may be other spies on the station.
            </Stack.Item>
            <Stack.Item>
              Work together or work against them: The choice is yours, but{' '}
              <span style={redText}>you cannot share the rewards.</span>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <ObjectivePrintout
                titleMessage={'Your mission, should you choose to accept it'}
                objectives={objectives}
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textAlign="center">
              {
                <ReplaceObjectivesButton
                  can_change_objective={can_change_objective}
                  button_title={'Make Your Own Plan'}
                  button_colour={'green'}
                />
              }
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

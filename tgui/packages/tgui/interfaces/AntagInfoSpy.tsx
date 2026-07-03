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
        <Section title={`Вы ${antag_name || 'Шпион'}.`}>
          <Stack vertical fill ml={1} mr={1}>
            <Stack.Item fontSize={1.2}>
              Вы были оснащены специальным аплинком, замаскированным под{' '}
              {uplink_location || 'что-то'}, который поможет вам красть вещи со
              станции.
            </Stack.Item>
            <Stack.Item>
              <span style={greenText}>
                <b>Используйте в руке</b> чтобы включить аплинк, и <b>ПКМ</b> по
                вещам-целям, чтобы их украсть.
              </span>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              Вы можете быть не одни: на станции могут находиться другие шпионы.
            </Stack.Item>
            <Stack.Item>
              Работайте вместе, или против них: Выбор за вами, но{' '}
              <span style={redText}>
                но вы не сможете получить награду дважды.
              </span>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <ObjectivePrintout
                titleMessage={'Ваша миссия, если вы решите ее принять'}
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

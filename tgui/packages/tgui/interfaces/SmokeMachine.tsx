import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

type Data = {
  active: BooleanLike;
  maxSetting: number;
  setting: number;
  tankContents: Reagent[];
  tankCurrentVolume: number;
  tankMaxVolume: number;
};

type Reagent = {
  name: string;
  volume: number;
};

export const SmokeMachine = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    tankContents,
    tankCurrentVolume,
    tankMaxVolume,
    active,
    setting,
    maxSetting,
  } = data;

  return (
    <Window width={350} height={350}>
      <Window.Content>
        <Section
          title="Dispersal Tank"
          buttons={
            <Button
              icon={active ? 'power-off' : 'times'}
              selected={active}
              onClick={() => act('power')}
            >
              {active ? 'On' : 'Off'}
            </Button>
          }
        >
          <ProgressBar
            value={tankCurrentVolume / tankMaxVolume}
            ranges={{
              bad: [-Infinity, 0.3],
            }}
          >
            <AnimatedNumber initial={0} value={tankCurrentVolume || 0} />
            {' / ' + tankMaxVolume}
          </ProgressBar>
          <Box mt={1}>
            <LabeledList>
              <LabeledList.Item label="Range">
                {[1, 2, 3, 4, 5].map((amount) => (
                  <Button
                    disabled={maxSetting < amount}
                    icon="plus"
                    key={amount}
                    onClick={() => act('setting', { amount })}
                    selected={setting === amount}
                  >
                    {amount * 3}
                  </Button>
                ))}
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Section>
        <Section
          title="Contents"
          buttons={
            <Button icon="trash" onClick={() => act('purge')}>
              Purge
            </Button>
          }
        >
          {tankContents.map((chemical) => (
            <Box key={chemical.name} color="label">
              <AnimatedNumber initial={0} value={chemical.volume} /> units of{' '}
              {chemical.name}
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

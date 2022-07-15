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

export const SmokeMachine = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    TankContents,
    isTankLoaded,
    TankCurrentVolume,
    TankMaxVolume,
    active,
    setting,
    screen,
    maxSetting = [],
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
              content={active ? 'On' : 'Off'}
              onClick={() => act('power')}
            />
          }
        >
          <ProgressBar
            value={TankCurrentVolume / TankMaxVolume}
            ranges={{
              bad: [-Infinity, 0.3],
            }}
          >
            <AnimatedNumber initial={0} value={TankCurrentVolume || 0} />
            {' / ' + TankMaxVolume}
          </ProgressBar>
          <Box mt={1}>
            <LabeledList>
              <LabeledList.Item label="Range">
                {[1, 2, 3, 4, 5].map((amount) => (
                  <Button
                    key={amount}
                    selected={setting === amount}
                    icon="plus"
                    content={amount * 3}
                    disabled={maxSetting < amount}
                    onClick={() => act('setting', { amount })}
                  />
                ))}
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Section>
        <Section
          title="Contents"
          buttons={
            <Button icon="trash" content="Purge" onClick={() => act('purge')} />
          }
        >
          {TankContents.map((chemical) => (
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

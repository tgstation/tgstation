import { useBackend } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const MassDriverControl = (props) => {
  const { act, data } = useBackend();
  const { connected, minutes, seconds, timing, power, poddoor } = data;
  return (
    <Window width={300} height={connected ? 215 : 107}>
      <Window.Content>
        {!!connected && (
          <Section
            title="Auto Launch"
            buttons={
              <Button
                icon={'clock-o'}
                content={timing ? 'Stop' : 'Start'}
                selected={timing}
                onClick={() => act('time')}
              />
            }
          >
            <Button
              icon="fast-backward"
              disabled={timing}
              onClick={() => act('input', { adjust: -30 })}
            />
            <Button
              icon="backward"
              disabled={timing}
              onClick={() => act('input', { adjust: -1 })}
            />{' '}
            {String(minutes).padStart(2, '0')}:
            {String(seconds).padStart(2, '0')}{' '}
            <Button
              icon="forward"
              disabled={timing}
              onClick={() => act('input', { adjust: 1 })}
            />
            <Button
              icon="fast-forward"
              disabled={timing}
              onClick={() => act('input', { adjust: 30 })}
            />
          </Section>
        )}
        <Section
          title="Controls"
          buttons={
            <Button
              icon={'toggle-on'}
              content="Toggle Outer Door"
              disabled={timing || !poddoor}
              onClick={() => act('door')}
            />
          }
        >
          {(!!connected && (
            <>
              <LabeledList>
                <LabeledList.Item
                  label="Power Level"
                  buttons={
                    <Button
                      icon={'bomb'}
                      content="Test Fire"
                      disabled={timing}
                      onClick={() => act('driver_test')}
                    />
                  }
                >
                  <NumberInput
                    value={power}
                    width="40px"
                    step={1}
                    minValue={0.25}
                    maxValue={16}
                    onChange={(value) => {
                      return act('set_power', {
                        power: value,
                      });
                    }}
                  />
                </LabeledList.Item>
              </LabeledList>
              <Button
                fluid
                content="Launch"
                disabled={timing}
                mt={1.5}
                icon="arrow-up"
                textAlign="center"
                onClick={() => act('launch')}
              />
            </>
          )) || <Box color="bad">No connected mass driver</Box>}
        </Section>
      </Window.Content>
    </Window>
  );
};

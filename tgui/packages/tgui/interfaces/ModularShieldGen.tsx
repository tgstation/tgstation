import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Stack, Section, ProgressBar, Button, NumberInput, LabeledList } from '../components';
import { BooleanLike } from 'common/react';

type ModularShieldGenData = {
  max_strength: number;
  current_strength: number;
  max_regeneration: number;
  current_regeneration: number;
  max_radius: number;
  current_radius: number;
  active: BooleanLike;
  recovering: BooleanLike;
  exterior_only: BooleanLike;
  initiating_field: BooleanLike;
};

export const ModularShieldGen = (props, context) => {
  const { topLevel } = props;
  const { act, data } = useBackend<ModularShieldGenData>(context);
  const {
    max_strength,
    max_regeneration,
    current_regeneration,
    max_radius,
    current_radius,
    current_strength,
    active,
    exterior_only,
    recovering,
    initiating_field,
  } = data;

  return (
    <Window title="Modular Shield Generator" width={600} height={400}>
      <Window.Content scrollable>
        <Section title={'Shield Strength'} color={recovering ? 'red' : 'white'}>
          <ProgressBar
            title="Shield Strength"
            value={current_strength}
            minValue={0}
            maxValue={max_strength}
            height={'30px'}
            ranges={{
              'good': [max_strength * 0.75, max_strength],
              'average': [max_strength * 0.25, max_strength * 0.75],
              'bad': [0, max_strength * 0.25],
            }}>
            {current_strength}/{max_strength}
          </ProgressBar>
        </Section>
        <Section title={'Regeneration and Radius'}>
          <ProgressBar
            height={'20px'}
            title="Regeneration rate"
            value={current_regeneration}
            minValue={0}
            maxValue={max_regeneration}
            ranges={{
              'good': [max_regeneration * 0.75, max_regeneration],
              'average': [max_regeneration * 0.25, max_regeneration * 0.75],
              'bad': [0, max_regeneration * 0.25],
            }}>
            Regeneration {current_regeneration}/{max_regeneration}
          </ProgressBar>
          <Section>
            <ProgressBar
              height={'20px'}
              title="Shield radius"
              value={current_radius}
              minValue={0}
              maxValue={max_radius}
              ranges={{
                'good': [max_radius * 0.75, max_radius],
                'average': [max_radius * 0.25, max_radius * 0.75],
                'bad': [0, max_radius * 0.25],
              }}>
              Radius {current_radius}/{max_radius}
            </ProgressBar>
          </Section>
        </Section>
        <Section title={'Settings'}>
          <Stack>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Set Radius">
                  <Section right={0.75}>
                    <NumberInput
                      disabled={active}
                      value={current_radius}
                      minValue={3}
                      maxValue={max_radius}
                      lineHeight="30px"
                      fontSize="15px"
                      width="60px"
                      height="20px"
                      onChange={(e, value) =>
                        act('set_radius', {
                          new_radius: value,
                        })
                      }
                    />
                  </Section>
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Placement Limitations">
                  <Section right={0.75}>
                    <Button
                      disabled={active}
                      onClick={() => act('toggle_exterior')}>
                      {exterior_only ? 'External only' : 'Internal & External'}
                    </Button>
                  </Section>
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Toggle Power">
                  <Section right={0.75}>
                    <Button
                      bold={1}
                      disabled={recovering || initiating_field}
                      selected={active}
                      content={active ? 'On' : 'Off'}
                      icon="power-off"
                      onClick={() => act('toggle_shields')}
                    />
                  </Section>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

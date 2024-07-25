import { useBackend } from '../backend';
import {
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

export const DiseaseIncubator = (props) => {
  const { act, data } = useBackend();
  const { dishes = [], on = 0, focus_stage } = data;

  return (
    <Window width={475} height={575}>
      <Stack fill vertical>
        <Stack.Item>
          <Section
            title="Incubator"
            buttons={
              <Button
                icon="power-off"
                content={on ? 'On' : 'Off'}
                color={on ? 'green' : 'red'}
                onClick={() => act('power')}
              />
            }
          />
        </Stack.Item>

        <Stack.Item grow overflowY="auto">
          <Section context="Dishes">
            {dishes.map((dish, dishIndex) => (
              <Section
                key={dishIndex}
                title={dish.name || 'Unnamed Dish'}
                buttons={
                  <>
                    <Button
                      content="Eject Disk"
                      tooltip="Eject the dish into your active hand"
                      disabled={!dish.dish_slot}
                      onClick={() => act('ejectdish', { slot: dish.dish_slot })}
                    />
                    <Button
                      content="Examine"
                      tooltip="Examine the dish, not very useful unless analyzed first"
                      disabled={!dish.dish_slot}
                      onClick={() =>
                        act('examinedish', { slot: dish.dish_slot })
                      }
                    />
                    <Button
                      content="Flush"
                      tooltip="Flush the reagents of this dish"
                      disabled={!dish.dish_slot}
                      onClick={() => act('flushdish', { slot: dish.dish_slot })}
                    />
                    <Button
                      content="Focus"
                      tooltip="Change the Stage Focus for this dish"
                      disabled={!dish.dish_slot}
                      onClick={() =>
                        act('changefocus', { slot: dish.dish_slot })
                      }
                    />
                  </>
                }
              >
                <ProgressBar
                  value={dish.growth}
                  minValue={0}
                  maxValue={100}
                  ranges={{
                    good: [70, 100],
                    average: [40, 70],
                    bad: [0, 40],
                  }}
                >
                  Growth Percentage: {dish.growth}%
                </ProgressBar>
                <ProgressBar
                  value={dish.reagents_volume}
                  minValue={0}
                  maxValue={10}
                  ranges={{
                    good: [7, 10],
                    average: [4, 7],
                    bad: [0, 4],
                  }}
                >
                  Reagent Volume Percentage:{' '}
                  {Math.round(dish.reagents_volume * 10)}%
                </ProgressBar>
                <LabeledList>
                  <LabeledList.Item label="Minor Mutate Strength">
                    {dish.minor_mutations_strength}
                  </LabeledList.Item>
                  <LabeledList.Item label="Minor Mutate Robustness">
                    {dish.minor_mutations_robustness}
                  </LabeledList.Item>
                  <LabeledList.Item label="Minor Mutate Effect Chance">
                    {dish.minor_mutations_effects}
                  </LabeledList.Item>
                </LabeledList>
                {Array.isArray(dish.symptom_data) &&
                dish.symptom_data.length > 0 ? (
                  <Collapsible fill title="Symptoms">
                    <LabeledList>
                      {dish.symptom_data.map((symptom, symptomIndex) => (
                        <LabeledList.Item key={symptomIndex}>
                          <Collapsible
                            color={
                              focus_stage === symptom.stage ? 'good' : 'average'
                            }
                            key={symptomIndex}
                            title={symptom.name || 'Unnamed Symptom'}
                          >
                            <LabeledList>
                              <LabeledList.Item label="Description">
                                {symptom.desc || 'No description available'}
                              </LabeledList.Item>
                              <LabeledList.Item label="Strength">
                                {symptom.strength}
                              </LabeledList.Item>
                              <LabeledList.Item label="Max Strength">
                                {symptom.max_strength}
                              </LabeledList.Item>
                              <LabeledList.Item label="Chance">
                                {symptom.chance}%
                              </LabeledList.Item>
                              <LabeledList.Item label="Max Chance">
                                {symptom.max_chance}%
                              </LabeledList.Item>
                              <LabeledList.Item label="Stage">
                                {symptom.stage}
                              </LabeledList.Item>
                            </LabeledList>
                          </Collapsible>
                        </LabeledList.Item>
                      ))}
                    </LabeledList>
                  </Collapsible>
                ) : (
                  <NoticeBox warn>No symptom data available.</NoticeBox>
                )}
              </Section>
            ))}
          </Section>
        </Stack.Item>
      </Stack>
    </Window>
  );
};

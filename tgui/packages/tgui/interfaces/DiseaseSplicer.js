import { useBackend } from '../backend';
import { Button, Dimmer, Knob, LabeledList, Icon, Section } from '../components';
import { Window } from '../layouts';

export const DiseaseSplicer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    splicing,
    scanning,
    burning,
    dish_name,
    memorybank,
    dish_error,
    target_stage,
  } = data;
  return (
    <Window width={350} height={400}>
      <Window.Content>
        {!!splicing && (
          <Dimmer fontSize="32px">
            <Icon name="cog" spin={1} />
            {' Splicing...'}
          </Dimmer>
        )}
        {!!burning && (
          <Dimmer fontSize="32px">
            <Icon name="cog" spin={1} />
            {' Burning...'}
          </Dimmer>
        )}
        {!!scanning && (
          <Dimmer fontSize="32px">
            <Icon name="cog" spin={1} />
            {' Scanning...'}
          </Dimmer>
        )}
        <Section title="Disease Splicer">
          Error: {dish_error}
          <LabeledList>
            {memorybank && (
              <LabeledList.Item label={memorybank}>
                <Button
                  content="Clear Memory Bank"
                  onClick={() => act('erase_buffer')}
                />
                <Button
                  content="Burn Effect to Disk"
                  onClick={() => act('burn_buffer_to_disk')}
                />
              </LabeledList.Item>
            )}
            {dish_name && (
              <LabeledList.Item label={dish_name}>
                <Button
                  content="Eject Dish"
                  onClick={() => act('eject_dish')}
                />
                <Button
                  content="Extract Effect"
                  onClick={() => act('dish_effect_to_buffer')}
                />
                <Knob
                  mr="0.5em"
                  animated
                  size={1.25}
                  inline
                  step={5}
                  stepPixelSize={2}
                  minValue={1}
                  maxValue={4}
                  value={target_stage}
                  onDrag={(e, stage) => act('target_stage', { stage })}
                />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

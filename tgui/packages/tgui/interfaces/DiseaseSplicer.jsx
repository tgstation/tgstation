import { useBackend } from '../backend';
import { Button, Dimmer, LabeledList, Icon, Slider, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const DiseaseSplicer = (props) => {
  const { act, data } = useBackend();
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
    <Window width={475} height={300}>
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
        <Section
          title="Disease Splicer"
          buttons={
            <>
              <Button
                content="Eject Dish"
                disabled={!dish_name}
                onClick={() => act('eject_dish')}
              />
              <Button
                content="Clear Memory Bank"
                disabled={!memorybank}
                onClick={() => act('erase_buffer')}
              />
            </>
          }>
          {!dish_error && <NoticeBox info>No Error Present</NoticeBox>}
          {dish_error && <NoticeBox warn>ERROR: {dish_error}</NoticeBox>}
          <LabeledList>
            {memorybank && (
              <LabeledList.Item label={memorybank}>
                <Button
                  content="Burn Effect to Disk"
                  onClick={() => act('burn_buffer_to_disk')}
                />
              </LabeledList.Item>
            )}
            {dish_name && (
              <LabeledList.Item label={dish_name}>
                <Button
                  content="Splice Memorybank"
                  disabled={!memorybank}
                  onClick={() => act('splice_buffer_to_dish')}
                />
              </LabeledList.Item>
            )}
            <LabeledList.Item label={'Targeted Stage'}>
              <Slider
                width="70%"
                minValue={1}
                maxValue={4}
                step={1}
                stepPixelSize={50}
                value={target_stage}
                onDrag={(e, stage) => act('target_stage', { stage })}
                onChange={(e, stage) => act('target_stage', { stage })}>
                {target_stage}
              </Slider>
              <Button
                color="green"
                width="30%"
                disabled={!dish_name}
                content="Extract Effect"
                onClick={() => act('dish_effect_to_buffer')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

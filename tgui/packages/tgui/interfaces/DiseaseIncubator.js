import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const DiseaseIncubator = (props, context) => {
  const { act, data } = useBackend(context);
  const { dishes, on, can_focus } = data;
  return (
    <Window width={475} height={175}>
      <Section
        title="Incubator"
        buttons={
          <Button
            icon="power-off"
            content={on ? 'On' : 'Off'}
            color={on ? 'green' : 'red'}
            onClick={() => act('power')}
          />
        }>
        <LabeledList context="Dishes">
          {dishes.map((dish) => (
            <LabeledList.Item key={dish.name} label={dish.name}>
              <Button
                content="Eject Disk"
                tooltip="Eject the dish into your active hand"
                disabled={!dish.dish_slot}
                onClick={() => act('ejectdish', { slot: dish.dish_slot })}
              />
              <Button
                content="Examine"
                tooltip="Examine the dish, not very useful unless examined"
                disabled={!dish.dish_slot}
                onClick={() => act('examinedish', { slot: dish.dish_slot })}
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
                onClick={() => act('changefocus', { slot: dish.dish_slot })}
              />
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    </Window>
  );
};

import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const DiseaseIncubator = (props) => {
  const { act, data } = useBackend();
  const { dishes, on, can_focus } = data;
  return (
    <Window width={475} height={575}>
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
        <Section context="Dishes">
          {dishes.map((dish) => (
            <Section
              key={dish.name}
              title={dish.name}
              buttons={
                <>
                  {' '}
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
                </>
              }>
              <LabeledList key={dish.name}>
                <LabeledList.Item label="Growth">
                  {dish.growth}
                </LabeledList.Item>
                <LabeledList.Item label="Volume">
                  {dish.reagents_volume}
                </LabeledList.Item>
                <LabeledList.Item label="Major Mutate Count">
                  {dish.major_mutations}
                </LabeledList.Item>
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
            </Section>
          ))}
        </Section>
      </Section>
    </Window>
  );
};

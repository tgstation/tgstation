import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Mint = (props, context) => {
  const { act, data } = useBackend(context);
  const inserted_materials = data.inserted_materials || [];
  return (
    <Window>
      <Window.Content>
        <Section
          title="Materials"
          buttons={
            <Button
              icon={data.processing ? 'times' : 'power-off'}
              content={data.processing ? 'Stop' : 'Start'}
              selected={data.processing}
              onClick={() => act(data.processing
                ? 'stoppress'
                : 'startpress')} />
          }>
          <LabeledList>
            {inserted_materials.map(material => (
              <LabeledList.Item
                key={material.material}
                label={material.material}
                buttons={(
                  <Button.Checkbox
                    checked={data.chosen_material === material.material}
                    onClick={() => act('changematerial', {
                      material_name: material.material,
                    })} />
                )}>
                {material.amount} cm³
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section>
          Pressed {data.produced_coins} coins this cycle.
        </Section>
      </Window.Content>
    </Window>
  );
};

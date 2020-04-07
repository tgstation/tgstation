import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';

export const Mint = props => {
  const { act, data } = useBackend(props);
  const inserted_materials = data.inserted_materials || [];
  return (
    <Fragment>
      <Section
        title="Materials"
        buttons={
          <Button
            icon={data.processing ? 'times' : 'power-off'}
            content={data.processing ? 'Stop' : 'Start'}
            selected={data.processing}
            onClick={() => act(data.processing
              ? 'stoppress'
              : 'startpress')}
          />
        }>
        <LabeledList>
          {inserted_materials.map(material => (
            <LabeledList.Item
              key={material.material}
              label={material.material}
              buttons={(
                <Button
                  icon={data.chosen_material === material.material
                    ? 'check-square'
                    : 'square'}
                  selected={data.chosen_material === material.material}
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
    </Fragment>
  );
};

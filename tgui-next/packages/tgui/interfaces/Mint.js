import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, Section } from '../components';

export const Mint = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const inserted_materials = data.inserted_materials || [];
  return (
    <Fragment>
      <Section
        title="Materials"
        buttons={(data.processing ? (
          <Button
            content="Stop"
            onClick={() => act(ref, 'stoppress')} />
        ) : (
          <Button
            content="Start"
            onClick={() => act(ref, 'startpress')} />
        ))}>
        <LabeledList>
          {inserted_materials.map(material => {
            return (
              <LabeledList.Item
                key={material.material}
                label={material.material}
                buttons={(
                  <Button
                    content="Select"
                    selected={data.chosen_material === material.material}
                    onClick={() => act(ref, 'changematerial', {
                      material_name: material.material,
                    })} />
                )}>
                {material.amount} cm³
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      </Section>
      <Section>
        Pressed {data.produced_coins} coins this cycle.
      </Section>
    </Fragment>
  );
};

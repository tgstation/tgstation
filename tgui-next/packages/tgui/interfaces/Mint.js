import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, LabeledList, Box } from '../components';

export const Mint = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const inserted_materials = data.inserted_materials || [];
  return (
    <Fragment>
      <Section
        title="Materials">
        <LabeledList>
          {inserted_materials.map(material => {
            return (
              <LabeledList.Item
                label = {material.material}
                buttons={Boolean(data.chosen_material !== material.material) && (
                  <Button content="Select"
                    onClick={() => act(ref, 'changematerial', {
                      material_name: material.material,
                    })}
                  />)
                }>
                {material.amount} cm³
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      </Section>
      <Box as style={{
        'font-size': '13px',
      }}>
        Pressed {data.produced_coins} coins this cycle. <br /><br />
      </Box>
      <Button
        content="Press"
        onClick={() => act(ref, 'startpress')}
      />
      <Button
        content="Stop"
        onClick={() => act(ref, 'stoppress')}
      />
      <Box as style={{
        'font-size': '14px',
      }}>
        <br />Status: {data.processing ? ("PRESSING") : ("STOPPED")}
      </Box>
    </Fragment>
  );
};

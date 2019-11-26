import { act } from '../byond';
import { Fragment } from 'inferno';
import { Box, Table, Button, Section } from '../components';
import { toTitleCase } from 'common/string';

export const OreBox = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const { materials } = data;
  return (
    <Fragment>
      <Section
        title="Ores"
        buttons={(
          <Button
            content="Empty"
            onClick={() => act(ref, 'removeall')} />
        )}
      >
        <Table>
          <Table.Row bold>
            <Table.Cell bold>
              Ore
            </Table.Cell>
            <Table.Cell bold textAlign="right">
              Amount
            </Table.Cell>
          </Table.Row>
          {materials.map(material => (
            <Table.Row key={material.type}>
              <Table.Cell>
                {toTitleCase(material.name)}
              </Table.Cell>
              <Table.Cell textAlign="right">
                <Box mr={2} color="label" inline>
                  {material.amount}
                </Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
      <Section>
        <Box>
          All ores will be placed in here when you are wearing a mining stachel
          on your belt or in a pocket while dragging the ore box.<br />
          Gibtonite is not accepted.
        </Box>
      </Section>
    </Fragment>
  );
};

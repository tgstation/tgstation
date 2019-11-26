import { act } from '../byond';
import { Fragment } from 'inferno';
import { BlockQuote, Box, Table, Button, Section } from '../components';
import { toTitleCase } from 'common/string';

export const OreBox = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const { materials } = data;
  return (
    <Fragment>
      <Section
        title="Ore Box"
      >
        <BlockQuote mb={1}>
          If you are wearing a mining stachel on your belt or in a pocket and dragging the box,
          all ores will be places in here.<br />
          Gibtonite is not accepted.
        </BlockQuote>
        <Box>
          <Box inline color="label" mr={1}>
            Remove all ores from the box
          </Box>
          <Button
            content="Empty"
            onClick={() => act(ref, 'removeall')} />
        </Box>
      </Section>
      <Section title="Ores">
        <Table>
          {materials.map(material => (
            <Table.Row key={material.type}>
              <Table.Cell>
                {toTitleCase(material.name)}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Box mr={2} color="label" inline>
                  {material.amount} Ore
                </Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Fragment>
  );
};

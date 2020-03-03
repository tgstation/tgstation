import { toTitleCase } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Table } from '../components';

export const LaborClaimConsole = props => {
  const { act, data } = useBackend(props);
  const {
    can_go_home,
    id_points,
    ores,
    status_info,
    unclaimed_points,
  } = data;
  return (
    <Fragment>
      <Section>
        <LabeledList>
          <LabeledList.Item label="Status">
            {status_info}
          </LabeledList.Item>
          <LabeledList.Item label="Shuttle controls">
            <Button
              content="Move shuttle"
              disabled={!can_go_home}
              onClick={() => act('move_shuttle')} />
          </LabeledList.Item>
          <LabeledList.Item label="Points">
            {id_points}
          </LabeledList.Item>
          <LabeledList.Item
            label="Unclaimed points"
            buttons={(
              <Button
                content="Claim points"
                disabled={!unclaimed_points}
                onClick={() => act('claim_points')} />
            )}>
            {unclaimed_points}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Material values">
        <Table>
          <Table.Row header>
            <Table.Cell>
              Material
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              Value
            </Table.Cell>
          </Table.Row>
          {ores.map(ore => (
            <Table.Row key={ore.ore}>
              <Table.Cell>
                {toTitleCase(ore.ore)}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Box color="label" inline>
                  {ore.value}
                </Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Fragment>
  );
};

import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Table } from '../components';

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
      <Section title="Ore value">
        <Table>
          {ores.map(ore => (
            <Table.Row key={ore.ore}>
              <Table.Cell>
                {ore.ore}
              </Table.Cell>
              <Table.Cell textAlign="right">
                {ore.value}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
      <Section title="Points">
        <LabeledList>
          <LabeledList.Item label="Status">
            {status_info}
            <Button
              content="Move shuttle"
              disabled={!can_go_home}
              onClick={() => act('move_shuttle')} />
          </LabeledList.Item>
          <LabeledList.Item label="Points">
            {id_points}
          </LabeledList.Item>
          <LabeledList.Item label="Unclaimed points">
            {unclaimed_points}
            <Button
              content="Claim points"
              disabled={!unclaimed_points}
              onClick={() => act('claim_points')} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};

import { Blink, Modal, Section, Table } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { getRandomDoomMessage } from './helpers';
import type { Data } from './types';

export const AuditScreen = () => {
  const { data } = useBackend<Data>();
  const { crashing, audit_log } = data;

  return (
    <Section scrollable height="320px">
      {!!crashing && (
        <Modal width="300px" align="center">
          <Blink time={500} interval={500}>
            {getRandomDoomMessage()}
          </Blink>
        </Modal>
      )}
      <Table>
        <Table.Row>
          <Table.Cell bold>Account</Table.Cell>
          <Table.Cell bold>Cost</Table.Cell>
          <Table.Cell bold>Location</Table.Cell>
          <Table.Cell bold>Timestamp</Table.Cell>
        </Table.Row>
        {audit_log.map((purchase, index) => (
          <Table.Row key={`audit_${index}`} className="Accounting__TableHeader">
            <Table.Cell p={0.5}>{purchase.account}</Table.Cell>
            <Table.Cell p={0.5} className="Accounting__TableCellSides">
              {purchase.cost} cr
            </Table.Cell>
            <Table.Cell p={0.5} className="Accounting__TableCellSides">
              {purchase.vendor}
            </Table.Cell>
            <Table.Cell p={0.5} className="Accounting__TableCellSides">
              {purchase.stationtime || '00:00'} ST
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

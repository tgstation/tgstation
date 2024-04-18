import { useBackend } from '../../backend';
import { Box, Button, Section, Table } from '../../components';
import { formatMoney } from '../../format';
import { CargoData } from './types';

export function CargoRequests(props) {
  const { act, data } = useBackend<CargoData>();
  const { requests = [], requestonly, can_send, can_approve_requests } = data;

  // Labeled list reimplementation to squeeze extra columns out of it
  return (
    <Section
      title="Active Requests"
      buttons={
        !requestonly && (
          <Button
            icon="times"
            color="transparent"
            onClick={() => act('denyall')}
          >
            Clear
          </Button>
        )
      }
    >
      {requests.length === 0 && <Box color="good">No Requests</Box>}
      {requests.length > 0 && (
        <Table>
          {requests.map((request) => (
            <Table.Row key={request.id} className="candystripe">
              <Table.Cell collapsing color="label">
                #{request.id}
              </Table.Cell>
              <Table.Cell>{request.object}</Table.Cell>
              <Table.Cell>
                <b>{request.orderer}</b>
              </Table.Cell>
              <Table.Cell width="25%">
                <i>{request.reason}</i>
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                {formatMoney(request.cost)} cr
              </Table.Cell>
              {(!requestonly || !!can_send) && !!can_approve_requests && (
                <Table.Cell collapsing>
                  <Button
                    icon="check"
                    color="good"
                    onClick={() =>
                      act('approve', {
                        id: request.id,
                      })
                    }
                  />
                  <Button
                    icon="times"
                    color="bad"
                    onClick={() =>
                      act('deny', {
                        id: request.id,
                      })
                    }
                  />
                </Table.Cell>
              )}
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
}

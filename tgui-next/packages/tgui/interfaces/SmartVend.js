
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, Table, NoticeBox } from '../components';
import { map } from 'common/fp';

export const SmartVend = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Section
      title="Storage"
      buttons={!!data.isdryer && (
        <Button
          icon={data.drying ? "stop" : "tint"}
          onClick={() => act(ref, 'Dry')}>
          {data.drying ? "Stop drying" : "Dry"}
        </Button>
      )}>
      {data.contents.length === 0 ? (
        <NoticeBox>Unfortunately, this {data.name} is empty.</NoticeBox>
      ) : (
        <Table style={{ width: '100%' }}>
          <Table.Row>
            <Table.Cell>Item</Table.Cell>
            <Table.Cell>Quantity</Table.Cell>
            <Table.Cell>{data.verb ? data.verb : "Dispense"}</Table.Cell>
          </Table.Row>
          {map((value, key) => {
            return (
              <Table.Row key={key}>
                <Table.Cell>{value.name}</Table.Cell>
                <Table.Cell>{value.amount}</Table.Cell>
                <Table.Cell>
                  <Button
                    disabled={value.amount < 1}
                    onClick={() => act(ref, 'Release', {name: value.name, amount: 1})}>
                    One
                  </Button>
                  <Button
                    disabled={value.amount <= 1}
                    onClick={() => act(ref, 'Release', {name: value.name})}>
                    Many
                  </Button>
                </Table.Cell>
              </Table.Row>
            );
          })(data.contents)}
        </Table>
      )}
    </Section>); };

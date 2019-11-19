import { map } from 'common/collections';
import { act } from '../byond';
import { Button, NoticeBox, Section, Table } from '../components';

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
        <NoticeBox>
          Unfortunately, this {data.name} is empty.
        </NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>
              Item
            </Table.Cell>
            <Table.Cell collapsing />
            <Table.Cell collapsing textAlign="center">
              {data.verb ? data.verb : 'Dispense'}
            </Table.Cell>
          </Table.Row>
          {map((value, key) => (
            <Table.Row key={key}>
              <Table.Cell>
                {value.name}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                {value.amount}
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  content="One"
                  disabled={value.amount < 1}
                  onClick={() => act(ref, 'Release', {
                    name: value.name,
                    amount: 1,
                  })} />
                <Button
                  content="Many"
                  disabled={value.amount <= 1}
                  onClick={() => act(ref, 'Release', {
                    name: value.name,
                  })} />
              </Table.Cell>
            </Table.Row>
          ))(data.contents)}
        </Table>
      )}
    </Section>
  );
};

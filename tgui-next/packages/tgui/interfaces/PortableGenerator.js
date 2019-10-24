
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, Table, NoticeBox, LabeledList } from '../components';

export const PortableGenerator = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      {!data.anchored && (
        <NoticeBox>Generator not anchored.</NoticeBox>
      )}
      <Section
        title="Status">
        <LabeledList>
          <LabeledList.Item label="Power switch">
            <Button
              icon={data.active ? "power-off" : "cross"}
              onClick={() => act(ref, 'toggle_power')}
              disabled={!data.ready_to_boot}>

            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
        buttons={!!data.isdryer && (
          <Button
            icon={data.drying ? "stop" : "tint"}
            onClick={() => act(ref, 'Dry')}>
            {data.drying ? "Stop drying" : "Dry"}
          </Button>
        )} />
      <Section>
        {data.contents.length === 0 ? (
          <NoticeBox>Unfortunately, this {data.name} is empty.</NoticeBox>
        ) : (
          <Table>
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
      </Section>
    </Fragment>); };

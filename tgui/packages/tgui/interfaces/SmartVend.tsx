import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, NoticeBox, Section, Table } from '../components';
import { Window } from '../layouts';

type Item = {
  name: string;
  amount: number;
};

type Data = {
  contents: Item[];
  name: string;
  isdryer: BooleanLike;
  drying: BooleanLike;
};

export const SmartVend = (props) => {
  const { act, data } = useBackend<Data>();
  const { contents = [] } = data;
  return (
    <Window width={440} height={550}>
      <Window.Content scrollable>
        <Section
          title="Storage"
          buttons={
            !!data.isdryer && (
              <Button
                icon={data.drying ? 'stop' : 'tint'}
                onClick={() => act('Dry')}>
                {data.drying ? 'Stop drying' : 'Dry'}
              </Button>
            )
          }>
          {contents.length === 0 ? (
            <NoticeBox>Unfortunately, this {data.name} is empty.</NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Item</Table.Cell>
                <Table.Cell collapsing />
                <Table.Cell collapsing textAlign="center">
                  {data.isdryer ? 'Take' : 'Dispense'}
                </Table.Cell>
              </Table.Row>
              {Object.values(contents).map((value, key) => (
                <Table.Row key={key}>
                  <Table.Cell>{value.name}</Table.Cell>
                  <Table.Cell collapsing textAlign="right">
                    {value.amount}
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      content="One"
                      disabled={value.amount < 1}
                      onClick={() =>
                        act('Release', {
                          name: value.name,
                          amount: 1,
                        })
                      }
                    />
                    <Button
                      content="Many"
                      disabled={value.amount <= 1}
                      onClick={() =>
                        act('Release', {
                          name: value.name,
                        })
                      }
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

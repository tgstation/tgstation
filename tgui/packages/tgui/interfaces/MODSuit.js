import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section, Collapsible, Table } from '../components';
import { Window } from '../layouts';

export const MODsuit = (props, context) => {
  const { act, data } = useBackend(context);
  let inventory = [
    ...data.modules,
  ];
  return (
    <Window
      width={400}
      height={500}
      theme="ntos"
      title="MOD Interface Panel"
      resizable>
      <Window.Content scrollable>
        <Section title="Parameters">
          <LabeledList>
            <LabeledList.Item
              label="Status"
              buttons={
                <Button
                icon="power-off"
                content={data.active ? 'Deactivate' : 'Activate'}
                onClick={() => act('activate')} />
              } >
            {data.malfunctioning ? 'Malfunctioning' : data.active ? 'Active' : 'Inactive'}
            </LabeledList.Item>
            <LabeledList.Item label="Lock">
              {data.lock ? 'Locked' : 'Unlocked'}
              <Button
                icon={data.locked ? "lock-open" : "lock"}
                content={data.locked ? 'Unlock' : 'Lock'}
                onClick={() => act('lock')} />
            </LabeledList.Item>
            <LabeledList.Item label="Cover">
              {data.open ? 'Open' : 'Closed'}
            </LabeledList.Item>
            <LabeledList.Item label="Selected Module">
              {data.selected_module || "None"}
            </LabeledList.Item>
            <LabeledList.Item label="Occupant">
              {data.wearer_name}, {data.wearer_job}
            </LabeledList.Item>
            <LabeledList.Item label="Onboard AI">
              {data.AI || "None"}
            </LabeledList.Item>
            <LabeledList.Item
              label="Cell Charge"
              color={!data.cell && 'bad'}>
              {data.cell && (
                <ProgressBar
                  value={data.charge / 100}
                  content={data.charge + '%'}
                  ranges={{
                    good: [0.6, Infinity],
                    average: [0.3, 0.6],
                    bad: [-Infinity, 0.3],
                  }} />
              ) || 'None'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Hardware">
          <LabeledList>
            <LabeledList.Item label="Cell">
              {data.cell || "None"}
            </LabeledList.Item>
            <LabeledList.Item label="Helmet">
              {data.helmet || "None"}
            </LabeledList.Item>
            <LabeledList.Item label="Chestplate">
              {data.chestplate || "None"}
            </LabeledList.Item>
            <LabeledList.Item label="Gauntlets">
              {data.gauntlets || "None"}
            </LabeledList.Item>
            <LabeledList.Item label="Boots">
              {data.boots || "No AI"}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Modules">
          {inventory.map((module => {
            return (
              <Table key={module.name}>
                <Table.Row>
                  <Table.Cell>
                    <b>{module.name}</b>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      content={'Select'}
                      onClick={() => act('select', {
                        'ref': module.ref,
                      })} />
                  </Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Collapsible title="Information">
                    <Table.Cell>
                      {module.description}
                    </Table.Cell>
                    <Table.Cell>
                      {module.idle_power + ' Idle Power Use'}
                    </Table.Cell>
                    <Table.Cell>
                      {module.active_power + ' Active Power Use'}
                    </Table.Cell>
                  </Collapsible>
                </Table.Row>
              </Table>
            );
          }))}
        </Section>
      </Window.Content>
    </Window>
  );
};

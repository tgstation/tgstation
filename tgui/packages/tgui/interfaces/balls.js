import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section, Collapsible, Box } from '../components';
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
            <LabeledList.Item
              label="Lock"
              buttons={
                <Button
                  icon={data.locked ? "lock-open" : "lock"}
                  content={data.locked ? 'Unlock' : 'Lock'}
                  onClick={() => act('lock')} />
              } >
              {data.locked ? 'Locked' : 'Unlocked'}
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
              <Collapsible
                title={module.name}
                key={module.name}
                buttons={!!module.selectable && (
                  <Button
                    content={module.selectable === 1 ? 'Activate' : 'Select'}
                    selected={module.active}
                    onClick={() => act('select', {
                      'ref': module.ref,
                    })} />)}>
                <Box mb={1}>
                  {module.description}
                </Box>
                <LabeledList>
                  <LabeledList.Item label="Idle Power Use">
                    {module.idle_power}
                  </LabeledList.Item>
                  <LabeledList.Item label="Active Power Use">
                    {module.active_power}
                  </LabeledList.Item>
                </LabeledList>
              </Collapsible>
            );
          }))}
        </Section>
      </Window.Content>
    </Window>
  );
};

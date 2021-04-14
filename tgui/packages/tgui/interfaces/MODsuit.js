import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section, Collapsible, Box, Icon, Stack } from '../components';
import { Window } from '../layouts';

const ID2MODULE = {
  rad_counter: () => RadCounter
}

const RadCounter = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Stack fill vertical>
      <Stack.Item>
        hi
      </Stack.Item>
    </Stack>
  );
};

export const MODsuit = (props, context) => {
  const { act, data } = useBackend(context);
  let inventory = [
    ...data.modules,
  ]
  const displayText = param => {
    switch(param){
      case 1:
          return "Use"
      case 2:
          return "Toggle"
      case 3:
          return "Select"
  }}
  const LockedInterface = (props) => (
    <Window.Content>
      <Section align="center" fill>
        <Icon
          color="red"
          name="exclamation-triangle"
          size={15}
           />
        <Box fontSize="30px" color="red">
          ERROR: INTERFACE UNRESPONSIVE.
        </Box>
      </Section>
    </Window.Content>
  );
  return (
    <Window
      width={400}
      height={525}
      theme={data.ui_theme}
      title="MOD Interface Panel"
      resizable>
      {data.interface_break && (
        <LockedInterface />
      ) || (
      <Window.Content scrollable>
        <Section title="Parameters">
          <LabeledList>
            <LabeledList.Item
              label="Status"
              buttons={
                <Button
                  icon="power-off"
                  content={data.active ? 'Deactivate' : 'Activate'}
                  onClick={() => act('activate')} />} >
              {data.malfunctioning ? 'Malfunctioning' : data.active ? 'Active' : 'Inactive'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Lock"
              buttons={
                <Button
                  icon={data.locked ? "lock-open" : "lock"}
                  content={data.locked ? 'Unlock' : 'Lock'}
                  onClick={() => act('lock')} />} >
              {data.locked ? 'Locked' : 'Unlocked'}
            </LabeledList.Item>
            <LabeledList.Item label="Cover">
              {data.open ? 'Open' : 'Closed'}
            </LabeledList.Item>
            <LabeledList.Item label="Selected Module">
              {data.selected_module || "None"}
            </LabeledList.Item>
            <LabeledList.Item label="Complexity">
              {data.complexity} ({data.complexity_max})
            </LabeledList.Item>
            <LabeledList.Item label="Occupant">
              {data.wearer_name}, {data.wearer_job}
            </LabeledList.Item>
            <LabeledList.Item label="Onboard AI">
              {data.AI || 'None'}
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
              ) || 'No Cell'}
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
        <Section title="Info">
          <Stack>
            {inventory.map((module => {
              data.active && (
              <Stack.Item key={module}>
                {!!module.id && (
                  ID2MODULE[module.id]
                )}
              </Stack.Item>)
            }))}
          </Stack>
        </Section>
        <Section title="Modules">
          {inventory.map((module => {
            <Collapsible
              title={module.name}
              key={module.name}
              buttons={!!module.module_type && (
                <Button
                  content={displayText(module.module_type)}
                  selected={module.active}
                  onClick={() => act('select', {
                    'ref': module.ref,
                  })} />)}>
              <Box mb={1}>
                {module.description}
              </Box>
              <LabeledList>
                <LabeledList.Item label="Complexity">
                  {module.module_complexity}
                </LabeledList.Item>
                <LabeledList.Item label="Idle Power Cost">
                  {module.idle_power}
                </LabeledList.Item>
                <LabeledList.Item label="Active Power Cost">
                  {module.active_power}
                </LabeledList.Item>
                <LabeledList.Item label="Use Power Cost">
                  {module.use_power}
                </LabeledList.Item>
              </LabeledList>
            </Collapsible>
          }))}
        </Section>
      </Window.Content> )}
    </Window>
  );
};

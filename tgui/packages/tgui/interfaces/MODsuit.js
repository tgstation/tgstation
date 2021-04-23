import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section, Collapsible, Box, Icon, Stack } from '../components';
import { Window } from '../layouts';

const rad_counter = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Stack fill vertical>
      <Stack.Item>
        hi
      </Stack.Item>
    </Stack>
  );
};

const LockedInterface = () => (
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
);

const displayText = param => {
  switch (param) {
    case 1:
      return "Use";
    case 2:
      return "Toggle";
    case 3:
      return "Select";
  }
};

const ParametersSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    malfunctioning,
    locked,
    open,
    selected_module,
    complexity,
    complexity_max,
    wearer_name,
    wearer_job,
    AI,
    cell,
    charge,
  } = data;
  const status = malfunctioning
    ? 'Malfunctioning' : active
      ? 'Active' : 'Inactive';
  return (
    <Section title="Parameters">
      <LabeledList>
        <LabeledList.Item
          label="Status"
          buttons={
            <Button
              icon="power-off"
              content={active ? 'Deactivate' : 'Activate'}
              onClick={() => act('activate')} />
          } >
          {status}
        </LabeledList.Item>
        <LabeledList.Item
          label="Lock"
          buttons={
            <Button
              icon={!locked ? "lock-open" : "lock"}
              content={!locked ? 'Unlock' : 'Lock'}
              onClick={() => act('lock')} />
          } >
          {locked ? 'Locked' : 'Unlocked'}
        </LabeledList.Item>
        <LabeledList.Item label="Cover">
          {open ? 'Open' : 'Closed'}
        </LabeledList.Item>
        <LabeledList.Item label="Selected Module">
          {selected_module || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Complexity">
          {complexity} ({complexity_max})
        </LabeledList.Item>
        <LabeledList.Item label="Occupant">
          {wearer_name}, {wearer_job}
        </LabeledList.Item>
        <LabeledList.Item label="Onboard AI">
          {AI || 'None'}
        </LabeledList.Item>
        <LabeledList.Item
          label="Cell Charge"
          color={!cell && 'bad'}>
          {cell && (
            <ProgressBar
              value={charge / 100}
              content={charge + '%'}
              ranges={{
                good: [0.6, Infinity],
                average: [0.3, 0.6],
                bad: [-Infinity, 0.3],
              }} />
          ) || 'No Cell'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const HardwareSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    cell,
    helmet,
    chestplate,
    gauntlets,
    boots,
  } = data;
  return (
    <Section title="Hardware">
      <LabeledList>
        <LabeledList.Item label="Cell">
          {cell || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Helmet">
          {helmet || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Chestplate">
          {chestplate || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Gauntlets">
          {gauntlets || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Boots">
          {boots || "None"}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};



const InfoSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    modules,
  } = data;

  return (
    <Section title="Info">
      <Stack vertical>
        {modules.map(module => (
          <Stack.Item key={module.id}>
            {module.name}
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const ModuleSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    modules,
  } = data;
  return (
    <Section title="Modules" fill>
      {modules.map(module => {
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
        </Collapsible>;
      })}
    </Section>
  );
};

export const MODsuit = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    ui_theme,
    interface_break,
  } = data;
  return (
    <Window
      width={400}
      height={525}
      theme={ui_theme}
      title="MOD Interface Panel"
      resizable>
      <Window.Content scrollable={!interface_break}>
        {!!interface_break && (
          <LockedInterface />
        ) || (
          <Stack vertical fill>
            <Stack.Item>
              <ParametersSection />
            </Stack.Item>
            <Stack.Item>
              <HardwareSection />
            </Stack.Item>
            <Stack.Item>
              <InfoSection />
            </Stack.Item>
            <Stack.Item grow>
              <ModuleSection />
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};

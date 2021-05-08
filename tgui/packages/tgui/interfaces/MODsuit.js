import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section, Collapsible, Box, Icon, Stack, Table } from '../components';
import { Window } from '../layouts';

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

const ID2MODULE = {
  rad_counter: () => RadCounter
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
              icon={locked ? "lock-open" : "lock"}
              content={locked ? 'Unlock' : 'Lock'}
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
      </LabeledList>
    </Section>
  );
};

const HardwareSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    control,
    helmet,
    chestplate,
    gauntlets,
    boots,
    cell,
    charge
  } = data;
  return (
    <Section title="Hardware">
      <Collapsible title="Parts">
        <LabeledList>
          <LabeledList.Item label="Control Unit">
            {control}
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
      </Collapsible>
      <Collapsible title="Cell">
        <LabeledList>
          <LabeledList.Item label="Cell Type">
            {cell || "None"}
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
      </Collapsible>
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
            {!!module.id && (
            ID2MODULE[module.id]
            )}
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const ModuleSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    complexity_max,
    modules,
  } = data;
  return (
    <Section title="Modules" fill>
      {modules.map(module => {
        return (
          <Collapsible
            title={module.name}
            key={module.name} >
            <Table>
              <Table.Row
                header>
                <Table.Cell
                  textAlign="center">
                  <Button
                    color="transparent"
                    icon="save"
                    tooltip="Complexity"
                    tooltipPosition="top" />
                </Table.Cell>
                <Table.Cell
                  textAlign="center">
                  <Button
                    color="transparent"
                    icon="plug"
                    tooltip="Idle Power Cost"
                    tooltipPosition="top" />
                </Table.Cell>
                <Table.Cell
                  textAlign="center">
                  <Button
                    color="transparent"
                    icon="lightbulb"
                    tooltip="Active Power Cost"
                    tooltipPosition="top" />
                </Table.Cell>
                <Table.Cell
                  textAlign="center">
                  <Button
                    color="transparent"
                    icon="bolt"
                    tooltip="Use Power Cost"
                    tooltipPosition="top" />
                </Table.Cell>
                <Table.Cell
                  textAlign="center">
                  <Button
                    color="transparent"
                    icon="hourglass-half"
                    tooltip="Cooldown"
                    tooltipPosition="top" />
                </Table.Cell>
                <Table.Cell
                  textAlign="center">
                  <Button
                    color="transparent"
                    icon="tasks"
                    tooltip="Actions"
                    tooltipPosition="top" />
                </Table.Cell>
              </Table.Row>
              <Table.Row
              key={module.ref}>
                <Table.Cell  textAlign="center">
                  {module.complexity}/{complexity_max}
                </Table.Cell>
                <Table.Cell  textAlign="center">
                  {module.idle_power}
                </Table.Cell>
                <Table.Cell textAlign="center">
                  {module.active_power}
                </Table.Cell>
                <Table.Cell textAlign="center">
                  {module.use_power}
                </Table.Cell>
                <Table.Cell
                  textAlign="center">
                  {(module.cooldown > 0) && (
                    Math.ceil(module.cooldown / 10)
                  ) || ("0")}/{module.cooldown_time / 10}s
                </Table.Cell>
                <Table.Cell
                  textAlign="center">
                  <Button
                    onClick={() => act("select", { "ref": module.ref })}
                    icon="bullseye"
                    color={module.active ? "good" : "default"}
                    tooltip={displayText(module.module_type)}
                    tooltipPosition="left"
                    disabled={!module.module_type} />
                  <Button
                    onClick={() => act("configure", { "ref": module.ref })}
                    icon="cog"
                    tooltip="Configure"
                    tooltipPosition="left"
                    disabled={!module.configurable} />
                </Table.Cell>
              </Table.Row>
            </Table>
            <Box mb={1}>
              {module.description}
            </Box>
          </Collapsible>
          )
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

import { toFixed } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Button, ColorBox, LabeledList, ProgressBar, Section, Collapsible, Box, Icon, Stack, Table, RoundGauge, Dimmer, Modal, NumberInput, Input, Flex } from '../components';
import { Window } from '../layouts';

const ConfigureIntegerEntry = (props, context) => {
  const { value, name, configureName } = props;
  const { act } = useBackend(context);
  return (
    <NumberInput
      value={value}
      minValue={-50}
      maxValue={50}
      stepPixelSize={5}
      width="39px"
      onDrag={(e, value) => act('modify_configure_value', {
        name: configureName,
        new_data: {
          [name]: value,
        },
      })} />
  );
};

const ConfigureBoolEntry = (props, context) => {
  const { value, name, configureName } = props;
  const { act } = useBackend(context);
  return (
    <NumberInput
      value={value}
      minValue={-50}
      maxValue={50}
      stepPixelSize={5}
      width="39px"
      onDrag={(e, value) => act('modify_configure_value', {
        name: configureName,
        new_data: {
          [name]: value,
        },
      })} />
  );
};

const ConfigureColorEntry = (props, context) => {
  const { value, configureName, name } = props;
  const { act } = useBackend(context);
  return (
    <>
      <Button
        icon="pencil-alt"
        onClick={() => act('modify_color_value', {
          name: configureName,
        })} />
      <ColorBox
        color={value}
        mr={0.5} />
      <Input
        value={value}
        width="90px"
        onInput={(e, value) => act('transition_configure_value', {
          name: configureName,
          new_data: {
            [name]: value,
          },
        })} />
    </>
  );
};

const ConfigureDataEntry = (props, context) => {
  const { name, value, hasValue, configureName } = props;

  const configureEntryTypes = {
    int: <ConfigureIntegerEntry {...props} />,
    bool: <ConfigureBoolEntry {...props} />,
    color: <ConfigureColorEntry {...props} />,
  };

  return (
    <LabeledList.Item label={name}>
      {configureEntryTypes[configureEntryMap[name]] || "Not Found (This is an error)"}
      {' '}
      {!hasValue && <Box inline color="average">(Default)</Box>}
    </LabeledList.Item>
  );
};

const ConfigureEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const { name, configureDataEntry } = props;
  const { type, priority, ...restOfProps } = configureDataEntry;

  const configureDefaults = data["configure_info"];

  const targetConfigurePossibleKeys = Object.keys(configureDefaults[type]['defaults']);

  return (
    <Collapsible
      title={name + " (" + type + ")"}
      buttons={(
        <>
          <NumberInput
            value={priority}
            stepPixelSize={10}
            width="60px"
            onChange={(e, value) => act('change_priority', {
              name: name,
              new_priority: value,
            })}
          />
          <Button.Input
            content="Rename"
            placeholder={name}
            onCommit={(e, new_name) => act('rename_configure', {
              name: name,
              new_name: new_name,
            })}
            width="90px" />
          <Button.Confirm
            icon="minus"
            onClick={() => act("remove_configure", { name: name })} />
        </>
      )}>
      <Section level={2}>
        <LabeledList>
          {targetConfigurePossibleKeys.map(entryName => {
            const defaults = configureDefaults[type]['defaults'];
            const value = restOfProps[entryName] || defaults[entryName];
            const hasValue = value !== defaults[entryName];
            return (
              <ConfigureDataEntry
                key={entryName}
                display_name={display_name}
                type={type}
                value={value} />
            );
          })}
        </LabeledList>
      </Section>
    </Collapsible>
  );
};

const RadCounter = (props, context) => {
  const {
    active,
    radcount,
    userrads,
    usercontam,
  } = props;
  return (
    <Stack fill>
      <Stack.Item>
        <Section title="Radiation Magnitude">
          {active && userrads ? userrads : "N/A"}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Radiation Contamination">
          {active && usercontam ? usercontam : "N/A"}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <RoundGauge
          size={3}
          value={active ? radcount : "N/A"}
          minValue={0}
          maxValue={1500}
          alertAfter={400}
          ranges={{
            "good": [0, 400],
            "average": [400, 800],
            "bad": [800, 1500],
          }}
          format={value => toFixed(value/10) + '%'} />
      </Stack.Item>
    </Stack>
  );
};

const ID2MODULE = {
  rad_counter: RadCounter,
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

const LockedModule = (props, context) => {
  const { act, data } = useBackend(context);
  const { owner } = data;
  return (
    <Dimmer>
      <Stack>
        <Stack.Item fontSize="16px" color="blue">
          ERROR: SUIT UNPOWERED.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const ConfigureScreen = (props, context) => {
  const { configuration_data } = props;
  const configuration_keys = Object.keys(configuration_data);
  return (
    <Dimmer backgroundColor="rgba(0, 0, 0, 0.8)">
      <Stack>
        {configuration_keys.map(key => {
          const data = configuration_data[key];
          return (
            <Stack.Item key={data.key}>
              {data.display_name}
            </Stack.Item>
          );
        })}
      </Stack>
    </Dimmer>
  );
};

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
    charge,
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
        {cell && (
          <LabeledList>
            <LabeledList.Item label="Cell Type">
              {cell}
            </LabeledList.Item>
            <LabeledList.Item label="Cell Charge">
              <ProgressBar
                value={charge / 100}
                content={charge + '%'}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0.3, 0.6],
                  bad: [-Infinity, 0.3],
                }} />
            </LabeledList.Item>
          </LabeledList>
        ) || (
          <Box color="bad" textAlign="center">No Cell Detected</Box>
        )}
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
  const info_modules = modules.filter(module => !!module.id);

  return (
    <Section title="Info">
      <Stack vertical>
        {info_modules.length !== 0 && info_modules.map(module => {
          const Module = ID2MODULE[module.id];
          return (
            <Stack.Item key={module.id}>
              {!active && <LockedModule />}
              <Module {...module} active={active} />
            </Stack.Item>
          );
        }) || (
          <Box textAlign="center">No Info Modules Detected</Box>
        )}
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
  const [configureState, setConfigureState]
    = useLocalState(context, "module_configuration", null);
  return (
    <Section title="Modules" fill>
      <Flex direction="column">
        {modules.length !== 0 && modules.map(module => {
          return (
            <Flex.Item key={module.name} >
              <Collapsible
                title={module.name} >
                <Section>
                  {configureState === module.ref && (
                    <ConfigureScreen
                      configuration_data={module.configuration_data} />)}
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
                      <Table.Cell textAlign="center">
                        {module.complexity}/{complexity_max}
                      </Table.Cell>
                      <Table.Cell textAlign="center">
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
                          module.cooldown / 10
                        ) || ("0")}/{module.cooldown_time / 10}s
                      </Table.Cell>
                      <Table.Cell
                        textAlign="center">
                        <Button
                          onClick={() => act("select", { "ref": module.ref })}
                          icon="bullseye"
                          selected={module.active}
                          tooltip={displayText(module.module_type)}
                          tooltipPosition="left"
                          disabled={!module.module_type} />
                        <Button
                          onClick={() => setConfigureState(module.ref)}
                          selected={configureState === module.ref}
                          icon="cog"
                          tooltip="Configure"
                          tooltipPosition="left"
                          disabled={module.configuration_data.length === 0} />
                      </Table.Cell>
                    </Table.Row>
                  </Table>
                  <Box>
                    {module.description}
                  </Box>
                </Section>
              </Collapsible>
            </Flex.Item>
          );
        }) || (
          <Flex.Item>
            <Box textAlign="center">No Modules Detected</Box>
          </Flex.Item>
        )}
      </Flex>
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

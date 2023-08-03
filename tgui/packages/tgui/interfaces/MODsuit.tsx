import { BooleanLike } from 'common/react';
import { formatSiUnit } from '../format';
import { useBackend, useLocalState } from '../backend';
import { Button, ColorBox, LabeledList, ProgressBar, Section, Collapsible, Box, Icon, Stack, Table, Dimmer, NumberInput, AnimatedNumber, Dropdown, NoticeBox } from '../components';
import { Window } from '../layouts';

type MODsuitData = {
  // Static
  ui_theme: string;
  control: string;
  complexity_max: number;
  helmet: string;
  chestplate: string;
  gauntlets: string;
  boots: string;
  // Dynamic
  suit_status: SuitStatus;
  user_status: UserStatus;
  module_custom_status: ModuleCustomStatus;
  module_info: Module[];
};

type SuitStatus = {
  core_name: string;
  cell_charge_current: number;
  cell_charge_max: number;
  active: BooleanLike;
  open: BooleanLike;
  seconds_electrified: number;
  malfunctioning: BooleanLike;
  locked: BooleanLike;
  interface_break: BooleanLike;
  complexity: number;
  selected_module: string;
  ai_name: string;
  has_pai: boolean;
  is_ai: boolean;
};

type UserStatus = {
  user_name: string;
  user_assignment: string;
};

type ModuleCustomStatus = {
  health: number;
  health_max: number;
  loss_brute: number;
  loss_fire: number;
  loss_tox: number;
  loss_oxy: number;
  is_user_irradiated: BooleanLike;
  background_radiation_level: number;
  display_time: BooleanLike;
  shift_time: string;
  shift_id: string;
  body_temperature: number;
  nutrition: number;
  dna_unique_identity: string;
  dna_unique_enzymes: string;
  viruses: VirusData[];
};

type VirusData = {
  name: string;
  type: string;
  stage: number;
  maxstage: number;
  cure: string;
};

type Module = {
  module_name: string;
  description: string;
  module_type: number;
  module_active: BooleanLike;
  pinned: BooleanLike;
  idle_power: number;
  active_power: number;
  use_power: number;
  module_complexity: number;
  cooldown_time: number;
  cooldown: number;
  id: string;
  ref: string;
  configuration_data: ModuleConfig[];
};

type ModuleConfig = {
  display_name: string;
  type: string;
  value: number;
  values: [];
};

export const MODsuit = (props, context) => {
  const { act, data } = useBackend<MODsuitData>(context);
  const { ui_theme } = data;
  const { interface_break } = data.suit_status;
  return (
    <Window
      width={600}
      height={600}
      theme={ui_theme}
      title="MOD Interface Panel"
      resizable>
      <Window.Content scrollable={!interface_break}>
        <MODsuitContent />
      </Window.Content>
    </Window>
  );
};

export const MODsuitContent = (props, context) => {
  const { act, data } = useBackend<MODsuitData>(context);
  const { interface_break } = data.suit_status;
  return (
    <Box>
      {interface_break ? (
        <LockedInterface />
      ) : (
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <SuitStatusSection />
              </Stack.Item>
              <Stack.Item grow>
                <UserStatusSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <ModuleSection />
          </Stack.Item>
          <Stack.Item>
            <HardwareSection />
          </Stack.Item>
        </Stack>
      )}
    </Box>
  );
};

const ConfigureNumberEntry = (props, context) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <NumberInput
      value={value}
      minValue={-50}
      maxValue={50}
      stepPixelSize={5}
      width="39px"
      onChange={(e, value) =>
        act('configure', {
          'key': name,
          'value': value,
          'ref': module_ref,
        })
      }
    />
  );
};

const ConfigureBoolEntry = (props, context) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <Button.Checkbox
      checked={value}
      onClick={() =>
        act('configure', {
          'key': name,
          'value': !value,
          'ref': module_ref,
        })
      }
    />
  );
};

const ConfigureColorEntry = (props, context) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <>
      <Button
        icon="paint-brush"
        onClick={() =>
          act('configure', {
            'key': name,
            'ref': module_ref,
          })
        }
      />
      <ColorBox color={value} mr={0.5} />
    </>
  );
};

const ConfigureListEntry = (props, context) => {
  const { name, value, values, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <Dropdown
      displayText={value}
      options={values}
      onSelected={(value) =>
        act('configure', {
          'key': name,
          'value': value,
          'ref': module_ref,
        })
      }
    />
  );
};

const ConfigureDataEntry = (props, context) => {
  const { name, display_name, type, value, values, module_ref } = props;
  const configureEntryTypes = {
    number: <ConfigureNumberEntry {...props} />,
    bool: <ConfigureBoolEntry {...props} />,
    color: <ConfigureColorEntry {...props} />,
    list: <ConfigureListEntry {...props} />,
  };
  return (
    <LabeledList.Item label={display_name}>
      {configureEntryTypes[type]}
    </LabeledList.Item>
  );
};

const LockedInterface = () => (
  <Section align="center" fill>
    <Icon color="red" name="exclamation-triangle" size={15} />
    <Box fontSize="30px" color="red">
      ERROR: INTERFACE UNRESPONSIVE
    </Box>
  </Section>
);

const LockedModule = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Dimmer>
      <Stack>
        <Stack.Item fontSize="16px" color="blue">
          SUIT UNPOWERED
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const ConfigureScreen = (props, context) => {
  const { configuration_data, module_ref, module_name } = props;
  const configuration_keys = Object.keys(configuration_data);
  return (
    <Box pb={1}>
      <LabeledList>
        {configuration_keys.map((key) => {
          const data = configuration_data[key];
          return (
            <ConfigureDataEntry
              key={data.key}
              name={key}
              display_name={data.display_name}
              type={data.type}
              value={data.value}
              values={data.values}
              module_ref={module_ref}
            />
          );
        })}
      </LabeledList>
    </Box>
  );
};

const moduleTypeAction = (param) => {
  switch (param) {
    case 1:
      return 'Use';
    case 2:
      return 'Toggle';
    case 3:
      return 'Select';
  }
};

const radiationLevels = (param) => {
  switch (param) {
    case 1:
      return 'Low';
    case 2:
      return 'Medium';
    case 3:
      return 'High';
    case 4:
      return 'Extreme';
  }
};

const SuitStatusSection = (props, context) => {
  const { act, data } = useBackend<MODsuitData>(context);
  const {
    core_name,
    cell_charge_current,
    cell_charge_max,
    active,
    open,
    seconds_electrified,
    malfunctioning,
    locked,
    ai_name,
    has_pai,
    is_ai,
  } = data.suit_status;
  const { display_time, shift_time, shift_id } = data.module_custom_status;
  const status = malfunctioning
    ? 'Malfunctioning'
    : active
      ? 'Active'
      : 'Inactive';
  const charge_percent = Math.round(
    (100 * cell_charge_current) / cell_charge_max
  );

  return (
    <Section
      title="Suit Status"
      fill
      buttons={
        <Button
          icon="power-off"
          color={active ? 'good' : 'default'}
          content={status}
          onClick={() => act('activate')}
        />
      }>
      <LabeledList>
        <LabeledList.Item label="Charge">
          <ProgressBar
            value={cell_charge_current / cell_charge_max}
            ranges={{
              good: [0.6, Infinity],
              average: [0.3, 0.6],
              bad: [-Infinity, 0.3],
            }}
            style={{
              'text-shadow': '1px 1px 0 black',
            }}>
            {!core_name
              ? 'No Core Detected'
              : cell_charge_max === 1
                ? 'Power Cell Missing'
                : cell_charge_current === 1e31
                  ? 'Infinite'
                  : `${formatSiUnit(
                    cell_charge_current * 1000,
                    0,
                    'J'
                  )} of ${formatSiUnit(
                    cell_charge_max * 1000,
                    0,
                    'J'
                  )} (${charge_percent}%)`}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="ID Lock">
          <Button
            icon={locked ? 'lock' : 'lock-open'}
            color={locked ? 'good' : 'default'}
            content={locked ? 'Locked' : 'Unlocked'}
            onClick={() => act('lock')}
          />
        </LabeledList.Item>
        {!!open && (
          <LabeledList.Item label="Cover">
            <Box color="red">Open</Box>
          </LabeledList.Item>
        )}
        {!!seconds_electrified && (
          <LabeledList.Item label="Circuits">
            <Box color="red">Shorted</Box>
          </LabeledList.Item>
        )}
        {!!ai_name && (
          <LabeledList.Item label="pAI Control">
            {has_pai && (
              <Button
                icon="eject"
                content="Eject pAI"
                disabled={is_ai}
                onClick={() => act('eject_pai')}
              />
            )}
          </LabeledList.Item>
        )}
      </LabeledList>

      {!!display_time && (
        <Section title="Operation" mt={2}>
          <LabeledList.Item label="Time">
            {active ? shift_time : '00:00:00'}
          </LabeledList.Item>
          <LabeledList.Item label="Number">
            {active && shift_id ? shift_id : '???'}
          </LabeledList.Item>
        </Section>
      )}
    </Section>
  );
};

const HardwareSection = (props, context) => {
  const { act, data } = useBackend<MODsuitData>(context);
  const { control, helmet, chestplate, gauntlets, boots } = data;
  const { ai_name, core_name } = data.suit_status;
  return (
    <Section title="Hardware" style={{ 'text-transform': 'capitalize' }}>
      <LabeledList>
        <LabeledList.Item label="AI Assistant">
          {ai_name || 'No AI Detected'}
        </LabeledList.Item>
        <LabeledList.Item label="Core">
          {core_name || 'No Core Detected'}
        </LabeledList.Item>
        <LabeledList.Item label="Control Unit">{control}</LabeledList.Item>
        <LabeledList.Item label="Helmet">{helmet || 'None'}</LabeledList.Item>
        <LabeledList.Item label="Chestplate">
          {chestplate || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Gauntlets">
          {gauntlets || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Boots">{boots || 'None'}</LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const UserStatusSection = (props, context) => {
  const { act, data } = useBackend<MODsuitData>(context);
  const { active } = data.suit_status;
  const { user_name, user_assignment } = data.user_status;
  const {
    health,
    health_max,
    loss_brute,
    loss_fire,
    loss_tox,
    loss_oxy,
    is_user_irradiated,
    background_radiation_level,
    body_temperature,
    nutrition,
    dna_unique_identity,
    dna_unique_enzymes,
    viruses,
  } = data.module_custom_status;
  return (
    <Section title="User Status" fill>
      {!active && <LockedModule />}
      <LabeledList>
        {health !== undefined && (
          <LabeledList.Item label="Health">
            <ProgressBar
              value={active ? health / health_max : 0}
              ranges={{
                good: [0.5, Infinity],
                average: [0.2, 0.5],
                bad: [-Infinity, 0.2],
              }}>
              <AnimatedNumber value={active ? health : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_brute !== undefined && (
          <LabeledList.Item label="Brute Damage">
            <ProgressBar
              value={active ? loss_brute / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}>
              <AnimatedNumber value={active ? loss_brute : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_fire !== undefined && (
          <LabeledList.Item label="Burn Damage">
            <ProgressBar
              value={active ? loss_fire / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}>
              <AnimatedNumber value={active ? loss_fire : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_oxy !== undefined && (
          <LabeledList.Item label="Oxy Damage">
            <ProgressBar
              value={active ? loss_oxy / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}>
              <AnimatedNumber value={active ? loss_oxy : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_tox !== undefined && (
          <LabeledList.Item label="Tox Damage">
            <ProgressBar
              value={active ? loss_tox / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}>
              <AnimatedNumber value={active ? loss_tox : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {background_radiation_level !== undefined && (
          <LabeledList.Item label="Radiation">
            {!active ? (
              'Unknown'
            ) : is_user_irradiated ? (
              <NoticeBox danger>User Irradiated</NoticeBox>
            ) : background_radiation_level ? (
              <NoticeBox>
                {`Background: ${radiationLevels(background_radiation_level)}`}
              </NoticeBox>
            ) : (
              <NoticeBox info>Not Detected</NoticeBox>
            )}
          </LabeledList.Item>
        )}
        {body_temperature !== undefined && (
          <LabeledList.Item label="Body Temp">
            {`${active ? Math.round(body_temperature) : 0} K`}
          </LabeledList.Item>
        )}
        {nutrition !== undefined && (
          <LabeledList.Item label="Satiety Level">
            {`${active ? Math.round(nutrition) : 0}`}
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Name">{user_name}</LabeledList.Item>
        <LabeledList.Item label="Assignment">
          {user_assignment}
        </LabeledList.Item>
        {dna_unique_identity !== undefined && (
          <LabeledList.Item label="Fingerprints">
            <Box
              style={{
                'word-break': 'break-all',
                'word-wrap': 'break-word',
              }}>
              {active ? dna_unique_identity : '???'}
            </Box>
          </LabeledList.Item>
        )}
        {dna_unique_enzymes !== undefined && (
          <LabeledList.Item label="Enzymes">
            <Box
              style={{
                'word-break': 'break-all',
                'word-wrap': 'break-word',
              }}>
              {active ? dna_unique_enzymes : '???'}
            </Box>
          </LabeledList.Item>
        )}
      </LabeledList>
      {!!viruses && (
        <Section title="Diseases">
          {viruses.map((virus) => {
            return (
              <Collapsible title={virus.name} key={virus.name}>
                <LabeledList>
                  <LabeledList.Item label="Spread">
                    {virus.type}
                  </LabeledList.Item>
                  <LabeledList.Item label="Stage">
                    {virus.stage}/{virus.maxstage}
                  </LabeledList.Item>
                  <LabeledList.Item label="Cure">{virus.cure}</LabeledList.Item>
                </LabeledList>
              </Collapsible>
            );
          })}
        </Section>
      )}
    </Section>
  );
};

const ModuleSection = (props, context) => {
  const { act, data } = useBackend<MODsuitData>(context);
  const { complexity_max, module_info } = data;
  const { complexity } = data.suit_status;
  const [configureState, setConfigureState] = useLocalState(
    context,
    'module_configuration',
    ''
  );
  return (
    <Section
      title="Modules"
      fill
      buttons={`${complexity} of ${complexity_max} complexity used`}>
      {!module_info.length ? (
        <NoticeBox>No Modules Detected</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell colspan={3}>Actions</Table.Cell>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="plug"
                tooltip="Idle Power Cost"
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="lightbulb"
                tooltip="Active Power Cost"
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="bolt"
                tooltip="Use Power Cost"
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="save"
                tooltip="Complexity"
                tooltipPosition="top"
              />
            </Table.Cell>
          </Table.Row>
          {module_info.map((module) => {
            return (
              <Table.Row key={module.ref}>
                <Table.Cell width={1}>
                  <Button
                    onClick={() => act('select', { 'ref': module.ref })}
                    icon={
                      module.module_type === 3
                        ? module.module_active
                          ? 'check-square-o'
                          : 'square-o'
                        : 'power-off'
                    }
                    selected={module.module_active}
                    tooltip={moduleTypeAction(module.module_type)}
                    tooltipPosition="left"
                    disabled={!module.module_type || module.cooldown > 0}
                  />
                </Table.Cell>
                <Table.Cell width={1}>
                  <Button
                    onClick={() =>
                      setConfigureState(
                        configureState === module.ref ? '' : module.ref
                      )
                    }
                    icon="cog"
                    selected={configureState === module.ref}
                    tooltip="Configure"
                    tooltipPosition="left"
                    disabled={module.configuration_data.length === 0}
                  />
                </Table.Cell>
                <Table.Cell width={1}>
                  <Button
                    onClick={() => act('pin', { 'ref': module.ref })}
                    icon="thumbtack"
                    selected={module.pinned}
                    tooltip="Pin"
                    tooltipPosition="left"
                    disabled={!module.module_type}
                  />
                </Table.Cell>
                <Table.Cell>
                  <Collapsible
                    title={module.module_name}
                    color={module.module_active ? 'green' : 'default'}>
                    <Section mr={-19}>{module.description}</Section>
                  </Collapsible>
                  {configureState === module.ref && (
                    <ConfigureScreen
                      configuration_data={module.configuration_data}
                      module_ref={module.ref}
                      module_name={module.module_name}
                    />
                  )}
                </Table.Cell>
                <Table.Cell textAlign="center">{module.idle_power}</Table.Cell>
                <Table.Cell textAlign="center">
                  {module.active_power}
                </Table.Cell>
                <Table.Cell textAlign="center">{module.use_power}</Table.Cell>
                <Table.Cell textAlign="center">
                  {module.module_complexity}
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      )}
    </Section>
  );
};

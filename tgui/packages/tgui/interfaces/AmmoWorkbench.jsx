import { toTitleCase } from 'common/string';
import { useBackend, useSharedState, useLocalState } from '../backend';
import {
  Box,
  Button,
  NumberInput,
  NoticeBox,
  ProgressBar,
  Section,
  Flex,
  Stack,
  RoundGauge,
  Tabs,
  Table,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

export const AmmoWorkbench = (props) => {
  const [tab, setTab] = useSharedState('tab', 1);
  return (
    <Window
      width={600}
      height={600}
      theme="hackerman"
      title="Ammunitions Workbench"
    >
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Ammunitions
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            Materials
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
            Datadisks
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <AmmunitionsTab />}
        {tab === 2 && <MaterialsTab />}
        {tab === 3 && <DatadiskTab />}
      </Window.Content>
    </Window>
  );
};

export const AmmunitionsTab = (props) => {
  const { act, data } = useBackend();
  const {
    mag_loaded,
    system_busy,
    hacked,
    error,
    error_type,
    mag_name,
    turboBoost,
    current_rounds,
    max_rounds,
    efficiency,
    time,
    caliber,
    available_rounds = [],
  } = data;
  return (
    <>
      {!!error && (
        <NoticeBox textAlign="center" color={error_type}>
          {error}
        </NoticeBox>
      )}
      <Section title="Machine Settings">
        <Box inline mr={4}>
          Current Efficiency:{' '}
          <RoundGauge
            value={efficiency}
            minValue={1.6}
            maxValue={1}
            format={() => null}
          />
        </Box>
        <Box>Time Per Round: {time} seconds</Box>
        <Button.Checkbox
          textAlign="right"
          checked={turboBoost}
          onClick={() => act('turboBoost')}
        >
          Turbo Boost
        </Button.Checkbox>
      </Section>
      <Section
        title="Loaded Magazine"
        buttons={
          <>
            {!!mag_loaded && (
              <Box inline mr={2}>
                <ProgressBar
                  value={current_rounds}
                  minValue={0}
                  maxValue={max_rounds}
                />
              </Box>
            )}
            <Button
              icon="eject"
              content="Eject"
              disabled={!mag_loaded}
              onClick={() => act('EjectMag')}
            />
          </>
        }
      >
        {!!mag_loaded && <Box>{mag_name}</Box>}
        {!!mag_loaded && (
          <Box bold textAlign="right">
            {current_rounds} / {max_rounds}
          </Box>
        )}
      </Section>
      <Section title="Available Ammunition Types">
        {!!mag_loaded && (
          <Flex.Item grow={1} basis={0}>
            {available_rounds.map((available_round) => (
              <Box
                key={available_round.name}
                className="candystripe"
                p={1}
                pb={2}
              >
                <Stack.Item>
                  <Tooltip
                    content={available_round.mats_list}
                    position={'right'}
                  >
                    <Button
                      content={available_round.name}
                      disabled={system_busy}
                      onClick={() =>
                        act('FillMagazine', {
                          selected_type: available_round.typepath,
                        })
                      }
                    />
                  </Tooltip>
                </Stack.Item>
              </Box>
            ))}
          </Flex.Item>
        )}
      </Section>
      {!!hacked && (
        <NoticeBox textAlign="center" color="bad">
          !WARNING! - ARMADYNE SAFETY PROTOCOLS ARE NOT ENGAGED! MISUSE IS NOT
          COVERED UNDER WARRANTY. SOME MUNITION TYPES MAY CONSTITUTE A WAR CRIME
          IN YOUR AREA. PLEASE CONTACT AN ARMADYNE ADMINISTRATOR IMMEDIATELY.
        </NoticeBox>
      )}
    </>
  );
};

export const MaterialsTab = (props) => {
  const { act, data } = useBackend();
  const { materials = [] } = data;
  return (
    <Section title="Materials">
      <Table>
        {materials.map((material) => (
          <MaterialRow
            key={material.id}
            material={material}
            onRelease={(amount) =>
              act('Release', {
                id: material.id,
                sheets: amount,
              })
            }
          />
        ))}
      </Table>
    </Section>
  );
};

export const DatadiskTab = (props) => {
  const { act, data } = useBackend();
  const {
    loaded_datadisks = [],
    datadisk_loaded,
    datadisk_name,
    datadisk_desc,
    disk_error,
    disk_error_type,
  } = data;
  return (
    <>
      {!!disk_error && (
        <NoticeBox textAlign="center" color={disk_error_type}>
          {disk_error}
        </NoticeBox>
      )}
      <Section
        title="Datadisk"
        buttons={
          <>
            <Button
              icon="save"
              content="Load Disk"
              disabled={!datadisk_loaded}
              onClick={() => act('ReadDisk')}
            />
            <Button
              icon="eject"
              content="Eject"
              disabled={!datadisk_loaded}
              onClick={() => act('EjectDisk')}
            />
          </>
        }
      >
        {!!datadisk_loaded && (
          <Box>
            Inserted Datadisk: {datadisk_name}
            <Box>Description: {datadisk_desc}</Box>
          </Box>
        )}
      </Section>
      <Section title="Loaded Datadisks">
        <Table>
          {loaded_datadisks.map((loaded_datadisk) => (
            <Box key={loaded_datadisk.loaded_disk_name}>
              {loaded_datadisk.loaded_disk_name}
              <Box textAlign="right">
                Description: {loaded_datadisk.loaded_disk_desc}
              </Box>
            </Box>
          ))}
        </Table>
      </Section>
    </>
  );
};

const MaterialRow = (props) => {
  const { material, onRelease } = props;

  const [amount, setAmount] = useLocalState('amount' + material.name, 1);

  const amountAvailable = Math.floor(material.amount);
  return (
    <Table.Row>
      <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
      <Table.Cell collapsing textAlign="right">
        <Box mr={2} color="label" inline>
          {amountAvailable} sheets
        </Box>
      </Table.Cell>
      <Table.Cell collapsing>
        <NumberInput
          width="32px"
          step={1}
          stepPixelSize={5}
          minValue={1}
          maxValue={50}
          value={amount}
          onChange={(e, value) => setAmount(value)}
        />
        <Button
          disabled={amountAvailable < 1}
          content="Release"
          onClick={() => onRelease(amount)}
        />
      </Table.Cell>
    </Table.Row>
  );
};

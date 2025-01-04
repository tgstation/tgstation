import {
  Box,
  Button,
  Knob,
  LabeledControls,
  LabeledList,
  NoticeBox,
  RoundGauge,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { toFixed } from 'tgui-core/math';
import { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Data = {
  // Dynamic
  tankPresent: BooleanLike;
  tankPressure: number;
  leaking: BooleanLike;
  active: BooleanLike;
  transferRate: number;
  lastPressure: number;
  disk: string;
  storage: string;
  records: Record[];
  // Static
  maxTransfer: number;
  leakPressure: number;
  fragmentPressure: number;
  ejectPressure: number;
};

type Record = {
  ref: string;
  name: string;
  timestamp: string;
  source: string;
  gases: GasMoles[];
};

type GasMoles = {
  [key: string]: number;
};

const formatPressure = (value) => {
  if (value < 10000) {
    return toFixed(value) + ' kPa';
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
};

export const TankCompressor = (props) => {
  return (
    <Window title="Tank Compressor" width={440} height={440}>
      <Window.Content>
        <TankCompressorContent />
      </Window.Content>
    </Window>
  );
};

const TankCompressorContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { disk, storage } = data;

  return (
    <Stack vertical fill>
      <TankCompressorControls />
      <Stack.Item grow>
        <Section
          scrollable
          fill
          style={{
            textTransform: 'capitalize',
          }}
          title={disk ? disk + ' (' + storage + ')' : 'No Disk Inserted'}
          buttons={
            <Button
              icon="eject"
              disabled={!disk}
              onClick={() => act('eject_disk')}
            >
              Eject Disk
            </Button>
          }
        >
          <TankCompressorRecords />
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const TankCompressorControls = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    tankPresent,
    leaking,
    lastPressure,
    leakPressure,
    fragmentPressure,
    tankPressure,
    maxTransfer,
    active,
    transferRate,
    ejectPressure,
  } = data;
  const pressure = tankPresent ? tankPressure : lastPressure;
  const usingLastData = !!(lastPressure && !tankPresent);
  const notice_color =
    usingLastData || leaking || pressure > fragmentPressure
      ? 'bad'
      : !tankPresent
        ? 'blue'
        : pressure > leakPressure
          ? 'average'
          : 'good';
  const notice_text = usingLastData
    ? 'Tank destroyed. Displaying last recorded data.'
    : !tankPresent
      ? 'No Tank Detected'
      : leaking
        ? 'Tank Leaking'
        : !pressure
          ? 'No Pressure Detected'
          : pressure < leakPressure
            ? 'Tank Pressure Nominal'
            : pressure < fragmentPressure
              ? 'Leak Hazard'
              : 'Explosive Hazard';

  return (
    <Stack.Item>
      <Section
        title="Tank"
        buttons={
          <Button
            icon="eject"
            disabled={!tankPresent || tankPressure > ejectPressure}
            onClick={() => act('eject_tank')}
          >
            {'Eject Tank'}
          </Button>
        }
      >
        <NoticeBox color={notice_color}>{notice_text}</NoticeBox>
        <LabeledControls p={2}>
          <LabeledControls.Item label="Pressure">
            <RoundGauge
              size={2.5}
              value={pressure}
              minValue={0}
              maxValue={fragmentPressure * 1.15}
              alertAfter={leakPressure}
              ranges={{
                good: [0, leakPressure],
                average: [leakPressure, fragmentPressure],
                bad: [fragmentPressure, fragmentPressure * 1.15],
              }}
              format={formatPressure}
            />
          </LabeledControls.Item>
          <LabeledControls.Item label="Flow rate">
            <Box position="relative">
              <Knob
                size={2}
                value={transferRate}
                unit="Liters/sec."
                minValue={0}
                maxValue={maxTransfer}
                step={1}
                stepPixelSize={8}
                onDrag={(e, value) =>
                  act('change_rate', {
                    target: value,
                  })
                }
              />
              <Button
                fluid
                position="absolute"
                top="-2px"
                right="-24px"
                color="transparent"
                icon="fast-forward"
                onClick={() =>
                  act('change_rate', {
                    target: maxTransfer,
                  })
                }
              />
              <Button
                fluid
                position="absolute"
                top="16px"
                right="-24px"
                color="transparent"
                icon="undo"
                onClick={() =>
                  act('change_rate', {
                    target: 0,
                  })
                }
              />
            </Box>
          </LabeledControls.Item>
          <LabeledControls.Item label="Compressor">
            <Button
              my={0.5}
              lineHeight={2}
              fontSize="18px"
              icon="power-off"
              disabled={!tankPresent || (!!leaking && pressure < leakPressure)}
              selected={active}
              onClick={() => act('toggle_injection')}
            >
              {active ? 'On' : 'Off'}
            </Button>
          </LabeledControls.Item>
        </LabeledControls>
      </Section>
    </Stack.Item>
  );
};

const TankCompressorRecords = (props) => {
  const { act, data } = useBackend<Data>();
  const { records = [], disk } = data;
  const [activeRecordRef, setActiveRecordRef] = useSharedState(
    'recordRef',
    records[0]?.ref,
  );
  const activeRecord =
    !!activeRecordRef &&
    records.find((record) => activeRecordRef === record.ref);
  if (records.length === 0) {
    return (
      <Stack.Item grow>
        <NoticeBox>No Records</NoticeBox>
      </Stack.Item>
    );
  }

  return (
    <Stack.Item grow>
      <Stack fill>
        <Stack.Item mr={2}>
          <Tabs vertical>
            {records.map((record) => (
              <Tabs.Tab
                icon="file"
                key={record.name}
                selected={record.ref === activeRecordRef}
                onClick={() => setActiveRecordRef(record.ref)}
              >
                {record.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        {activeRecord ? (
          <Stack.Item grow>
            <LabeledList>
              <LabeledList.Item label="Title">
                {activeRecord.name}
              </LabeledList.Item>
              <LabeledList.Item label="Time">
                {activeRecord.timestamp}
              </LabeledList.Item>
              <LabeledList.Item label="Source">
                {activeRecord.source}
              </LabeledList.Item>
              <LabeledList.Item label="Gases">
                <LabeledList>
                  {Object.keys(activeRecord.gases).map((gas_name) => (
                    <LabeledList.Item label={gas_name} key={gas_name}>
                      {(activeRecord.gases[gas_name]
                        ? activeRecord.gases[gas_name].toFixed(2)
                        : '-') + ' moles'}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </LabeledList.Item>
              <LabeledList.Item label="Actions">
                <Button
                  icon="floppy-disk"
                  content="Save to Disk"
                  disabled={!disk}
                  tooltip="Save the record selected to an inserted data disk."
                  tooltipPosition="bottom"
                  onClick={() => {
                    act('save_record', {
                      ref: activeRecord.ref,
                    });
                  }}
                />
                <Button.Confirm
                  icon="trash"
                  color="bad"
                  onClick={() => {
                    act('delete_record', {
                      ref: activeRecord.ref,
                    });
                  }}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        ) : (
          <Stack.Item grow={1} basis={0}>
            <NoticeBox>No Record Selected</NoticeBox>
          </Stack.Item>
        )}
      </Stack>
    </Stack.Item>
  );
};

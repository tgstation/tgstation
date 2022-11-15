import { useBackend, useSharedState } from '../backend';
import { Box, Button, Flex, Icon, Modal, RoundGauge, Section, Slider, Stack, NoticeBox, Tabs, LabeledList } from '../components';
import { Window } from '../layouts';
import { GasmixParser } from './common/GasmixParser';

export const TankCompressor = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window title="Tank Compressor" width={650} height={550}>
      <Window.Content>
        <TankCompressorContent />
      </Window.Content>
    </Window>
  );
};

const TankCompressorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { disk, storage } = data;
  const [currentTab, changeTab] = useSharedState(context, 'compressorTab', 1);
  return (
    <Stack vertical fill>
      {currentTab === 1 && <TankCompressorControls />}
      {currentTab === 2 && <TankCompressorRecords />}
      <Stack.Item>
        <Section
          title={disk ? disk + ' (' + storage + ')' : 'No Disk Inserted'}>
          <Stack>
            <Stack.Item grow>
              <Button
                textAlign="center"
                fluid
                icon={currentTab === 1 ? 'clipboard-list' : 'times'}
                onClick={() =>
                  currentTab === 1 ? changeTab(2) : changeTab(1)
                }>
                {currentTab === 1 ? 'Open Records' : 'Close Records'}
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                textAlign="center"
                fluid
                icon="eject"
                content="Eject Disk"
                disabled={!disk}
                onClick={() => act('eject_disk')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const AlertBoxes = (props, context) => {
  const { text_content, icon_name, icon_break, color, active } = props;
  const { act, data } = useBackend(context);
  return (
    <Box
      bold
      height="100%"
      fontSize={1.25}
      backgroundColor={active ? color : '#999999'}>
      <Flex height="100%" width="100%" justify="center" direction="column">
        <Flex.Item>
          <Icon name={icon_name} width={2} />
          {icon_break && <br />}
          {text_content}
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const TankCompressorControls = (props, context) => {
  const { act, data } = useBackend(context);
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
    inputData,
    outputData,
    bufferData,
  } = data;
  const pressure = tankPresent ? tankPressure : lastPressure;
  const usingLastData = !!(lastPressure && !tankPresent);
  return (
    <>
      <Stack.Item>
        <Section
          title="Tank Integrity"
          buttons={
            <Button
              icon="eject"
              disabled={!tankPresent || tankPressure > ejectPressure}
              onClick={() => act('eject_tank')}>
              {'Eject Tank'}
            </Button>
          }>
          {!pressure && <Modal>{'No Pressure Detected'}</Modal>}
          {usingLastData && (
            <NoticeBox warning>
              {'Tank destroyed. Displaying last recorded data.'}
            </NoticeBox>
          )}
          <Stack fill textAlign="center">
            <Stack.Item>
              <RoundGauge
                value={pressure}
                minValue={0}
                maxValue={fragmentPressure * 1.15}
                alertAfter={leakPressure}
                ranges={{
                  'good': [0, leakPressure],
                  'average': [leakPressure, fragmentPressure],
                  'bad': [fragmentPressure, fragmentPressure * 1.15],
                }}
                size={5}
                textAlign="center"
                format={(value) => (value ? value.toFixed(2) : '-') + ' kPa'}
              />
            </Stack.Item>
            <Stack.Item basis={0} grow>
              <AlertBoxes
                text_content="Tank Pressure Nominal"
                icon_name="check"
                icon_break
                color="green"
                active={pressure < leakPressure}
              />
            </Stack.Item>
            <Stack.Item basis={0} grow>
              <AlertBoxes
                text_content="Tank Integrity Faltering"
                icon_name="exclamation-triangle"
                icon_break
                color="yellow"
                active={pressure >= leakPressure}
              />
            </Stack.Item>
            <Stack.Item basis={0} grow>
              <Stack vertical fill>
                <Stack.Item grow>
                  <AlertBoxes
                    text_content="Leak Hazard"
                    icon_name="biohazard"
                    color="red"
                    active={
                      (pressure >= leakPressure &&
                        pressure < fragmentPressure) ||
                      leaking
                    }
                  />
                </Stack.Item>
                <Stack.Item grow>
                  <AlertBoxes
                    text_content="Explosive Hazard"
                    icon_name="bomb"
                    color="red"
                    active={pressure >= fragmentPressure}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Compressor Control">
          <Stack fill>
            <Stack.Item grow>
              <Slider
                minValue={0}
                maxValue={maxTransfer}
                value={transferRate}
                stepPixelSize={12.5}
                step={0.5}
                unit="L/S"
                onDrag={(e, new_rate) =>
                  act('change_rate', { target: new_rate })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                disabled={
                  !tankPresent || (!!leaking && pressure < leakPressure)
                }
                selected={active}
                icon={active ? 'power-off' : 'times'}
                onClick={() => act('toggle_injection')}>
                {active ? 'On' : 'Off'}
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <Section fill scrollable title={inputData.name}>
              {!inputData.total_moles && <Modal>{'No Gas Present'}</Modal>}
              <GasmixParser gasmix={inputData} />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title={outputData.name}>
              {!outputData.inputData && <Modal>{'No Gas Present'}</Modal>}
              <GasmixParser gasmix={outputData} />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title={bufferData.name}
              buttons={
                <Button
                  icon="exclamation"
                  tooltip="The buffer gas mixture will be recorded when a tank is destroyed or ejected. The printed records will refer to this port for it's experimental data."
                />
              }>
              {!bufferData.total_moles && <Modal>{'No Gas Present'}</Modal>}
              <GasmixParser gasmix={bufferData} />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </>
  );
};

const TankCompressorRecords = (props, context) => {
  const { act, data } = useBackend(context);
  const { records = [], disk } = data;
  const [activeRecordRef, setActiveRecordRef] = useSharedState(
    context,
    'recordRef',
    records[0]?.ref
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
  } else {
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
                  onClick={() => setActiveRecordRef(record.ref)}>
                  {record.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          {activeRecord ? (
            <Stack.Item grow>
              <Section
                title={activeRecord.name}
                buttons={[
                  <Button.Confirm
                    key="delete"
                    icon="trash"
                    content="Delete"
                    color="bad"
                    onClick={() => {
                      act('delete_record', {
                        'ref': activeRecord.ref,
                      });
                    }}
                  />,
                  <Button
                    key="save"
                    icon="floppy-disk"
                    content="Save"
                    disabled={!disk}
                    tooltip="Save the record selected to an inserted data disk."
                    tooltipPosition="bottom"
                    onClick={() => {
                      act('save_record', {
                        'ref': activeRecord.ref,
                      });
                    }}
                  />,
                ]}>
                <LabeledList>
                  <LabeledList.Item label="Timestamp">
                    {activeRecord.timestamp}
                  </LabeledList.Item>
                  <LabeledList.Item label="Source">
                    {activeRecord.source}
                  </LabeledList.Item>
                  <LabeledList.Item label="Detected Gas">
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
                </LabeledList>
              </Section>
            </Stack.Item>
          ) : (
            <Stack.Item grow={1} basis={0}>
              <NoticeBox>No Record Selected</NoticeBox>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    );
  }
};

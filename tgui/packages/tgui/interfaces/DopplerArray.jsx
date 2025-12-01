import {
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

export const DopplerArray = (props) => {
  return (
    <Window width={650} height={320} resizable>
      <Window.Content>
        <DopplerArrayContent />
      </Window.Content>
    </Window>
  );
};

const DopplerArrayContent = (props) => {
  const { act, data } = useBackend();
  const { records = [], disk, storage } = data;
  const [activeRecordName, setActiveRecordName] = useSharedState(
    'activeRecordrecord',
    records[0]?.name,
  );
  const activeRecord = records.find((record) => {
    return record.name === activeRecordName;
  });
  const DopplerArrayFooter = (
    <Section title={disk ? `${disk} (${storage})` : 'No Disk Inserted'}>
      <Button
        textAlign="center"
        fluid
        icon="eject"
        content="Eject Disk"
        disabled={!disk}
        onClick={() => act('eject_disk')}
      />
    </Section>
  );
  const DopplerArrayRecords = (
    <Section>
      <Stack>
        <Stack.Item mr={2}>
          <Tabs vertical>
            {records.map((record) => (
              <Tabs.Tab
                icon="file"
                key={record.name}
                selected={record.name === activeRecordName}
                onClick={() => setActiveRecordName(record.name)}
              >
                {record.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        {activeRecord ? (
          <Stack.Item>
            <Section
              title={activeRecord.name}
              buttons={
                <>
                  <Button.Confirm
                    icon="trash"
                    content="Delete"
                    color="bad"
                    onClick={() =>
                      act('delete_record', {
                        ref: activeRecord.ref,
                      })
                    }
                  />
                  <Button
                    icon="floppy-disk"
                    content="Save"
                    disabled={!disk}
                    tooltip="Save the record selected to an inserted data disk."
                    tooltipPosition="bottom"
                    onClick={() =>
                      act('save_record', {
                        ref: activeRecord.ref,
                      })
                    }
                  />
                </>
              }
            >
              <LabeledList>
                <LabeledList.Item label="Timestamp">
                  {activeRecord.timestamp}
                </LabeledList.Item>
                <LabeledList.Item label="Coordinates">
                  {activeRecord.coordinates}
                </LabeledList.Item>
                <LabeledList.Item label="Displacement">
                  {activeRecord.displacement} seconds
                </LabeledList.Item>
                <LabeledList.Item label="Epicenter Radius">
                  {activeRecord.factual_epicenter_radius}
                  {activeRecord.theory_epicenter_radius &&
                    ' (Theoretical: ' +
                      activeRecord.theory_epicenter_radius +
                      ')'}
                </LabeledList.Item>
                <LabeledList.Item label="Outer Radius">
                  {activeRecord.factual_outer_radius}
                  {activeRecord.theory_outer_radius &&
                    ` (Theoretical: ${activeRecord.theory_outer_radius})`}
                </LabeledList.Item>
                <LabeledList.Item label="Shockwave Radius">
                  {activeRecord.factual_shockwave_radius}
                  {activeRecord.theory_shockwave_radius &&
                    ' (Theoretical: ' +
                      activeRecord.theory_shockwave_radius +
                      ')'}
                </LabeledList.Item>
                <LabeledList.Item label="Possible Cause(s)">
                  {activeRecord.reaction_results.length
                    ? activeRecord.reaction_results.map((reaction_name) => (
                        <Box key={reaction_name}>{reaction_name}</Box>
                      ))
                    : 'No information available'}
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
    </Section>
  );
  return (
    <Flex direction="column" height="100%">
      <Flex.Item grow>
        {!records.length ? (
          <NoticeBox>No Records</NoticeBox>
        ) : (
          DopplerArrayRecords
        )}
      </Flex.Item>
      <Flex.Item>{DopplerArrayFooter}</Flex.Item>
    </Flex>
  );
};

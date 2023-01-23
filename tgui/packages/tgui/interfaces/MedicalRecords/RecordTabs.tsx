import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from '../../backend';
import { Stack, Input, Section, Tabs, NoticeBox, Box, Icon, Button } from '../../components';
import { JOB2ICON } from '../common/JobToIcon';
import { isRecordMatch } from '../SecurityRecords/helpers';
import { MedicalRecord, MedicalRecordData } from './types';

/** Displays all found records. */
export const MedicalRecordTabs = (props, context) => {
  const { act, data } = useBackend<MedicalRecordData>(context);
  const { records = [] } = data;

  const errorMessage = !records.length
    ? 'No records found.'
    : 'No match. Refine your search.';

  const [search, setSearch] = useLocalState(context, 'search', '');
  const [selectedRecord, setSelectedRecord] = useLocalState<
    MedicalRecord | undefined
  >(context, 'medicalRecord', undefined);

  const sorted: MedicalRecord[] = flow([
    filter((record: MedicalRecord) => isRecordMatch(record, search)),
    sortBy((record: MedicalRecord) => record.name?.toLowerCase()),
  ])(records);

  const selectRecord = (record: MedicalRecord) => {
    if (selectedRecord?.crew_ref === record.crew_ref) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
      act('view_record', { lock_ref: record.lock_ref });
    }
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          fluid
          onInput={(_, value) => setSearch(value)}
          placeholder="Name/Job/DNA"
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack fill vertical>
            <Stack.Item grow>
              <Tabs vertical>
                {!sorted.length ? (
                  <NoticeBox>{errorMessage}</NoticeBox>
                ) : (
                  sorted.map((record, index) => (
                    <Tabs.Tab
                      className="candystripe"
                      key={index}
                      label={record.name}
                      onClick={() => selectRecord(record)}
                      selected={selectedRecord?.crew_ref === record.crew_ref}>
                      <Box wrap>
                        <Icon name={JOB2ICON[record.rank] || 'question'} />{' '}
                        {record.name}
                      </Box>
                    </Tabs.Tab>
                  ))
                )}
              </Tabs>
            </Stack.Item>
            <Stack.Item>
              <Box align="right">
                <Button.Confirm
                  content="Purge Records"
                  icon="trash"
                  onClick={() => act('purge_records')}
                />
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from 'tgui/backend';
import { Stack, Input, Section, Tabs, NoticeBox, Box, Icon, Button } from 'tgui/components';
import { JOB2ICON } from '../common/JobToIcon';
import { CRIMESTATUS2COLOR } from './constants';
import { isRecordMatch } from './helpers';
import { SecurityRecordsData, SecurityRecord } from './types';

/** Tabs on left, with search bar */
export const SecurityRecordTabs = (props, context) => {
  const { act, data } = useBackend<SecurityRecordsData>(context);
  const { records = [] } = data;

  const errorMessage = !records.length
    ? 'No records found.'
    : 'No match. Refine your search.';

  const [search, setSearch] = useLocalState(context, 'search', '');

  const sorted: SecurityRecord[] = flow([
    filter((record: SecurityRecord) => isRecordMatch(record, search)),
    sortBy((record: SecurityRecord) => record.name),
  ])(records);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          fluid
          placeholder="Name/Job/Fingerprints"
          onInput={(event, value) => setSearch(value)}
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
                    <CrewTab record={record} key={index} />
                  ))
                )}
              </Tabs>
            </Stack.Item>
            <Stack.Item>
              <Box align="right">
                <Button
                  disabled
                  icon="plus"
                  tooltip="Add new records by inserting a photo into the terminal. You do not need this screen open.">
                  Add Record
                </Button>
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

/** Individual record */
const CrewTab = ({ record }: { record: SecurityRecord }, context) => {
  const { act } = useBackend<SecurityRecordsData>(context);
  const [selectedRecord, setSelectedRecord] = useLocalState<
    SecurityRecord | undefined
  >(context, 'securityRecord', undefined);

  /** Chooses a record */
  const selectRecord = (record: SecurityRecord) => {
    if (selectedRecord?.crew_ref === record.crew_ref) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
      act('view_record', { crew_ref: record.crew_ref });
    }
  };

  const { crew_ref, name, rank, wanted_status } = record;
  const isSelected = selectedRecord?.crew_ref === crew_ref;

  return (
    <Tabs.Tab
      className="candystripe"
      label={record.name}
      onClick={() => selectRecord(record)}
      selected={isSelected}>
      <Box bold={isSelected} color={CRIMESTATUS2COLOR[wanted_status]} wrap>
        <Icon name={JOB2ICON[rank] || 'question'} /> {name}
      </Box>
    </Tabs.Tab>
  );
};

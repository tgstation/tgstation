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
  const { higher_access, records = [] } = data;

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
          <Tabs vertical>
            {!sorted.length ? (
              <NoticeBox>{errorMessage}</NoticeBox>
            ) : (
              sorted.map((record, index) => (
                <CrewTab record={record} key={index} />
              ))
            )}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item align="center">
        <Stack fill>
          <Stack.Item>
            <Button
              disabled
              icon="plus"
              tooltip="Add new records by inserting a 1 by 1 meter photo into the terminal. You do not need this screen open.">
              Create
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              content="Purge"
              disabled={!higher_access}
              icon="trash"
              onClick={() => act('purge_records')}
              tooltip="Wipe criminal record data."
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

/** Individual record */
const CrewTab = (props: { record: SecurityRecord }, context) => {
  const [selectedRecord, setSelectedRecord] = useLocalState<
    SecurityRecord | undefined
  >(context, 'securityRecord', undefined);

  const { act, data } = useBackend<SecurityRecordsData>(context);
  const { assigned_view } = data;
  const { record } = props;
  const { crew_ref, name, rank, wanted_status } = record;

  /** Chooses a record */
  const selectRecord = (record: SecurityRecord) => {
    if (selectedRecord?.crew_ref === crew_ref) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
      act('view_record', { assigned_view: assigned_view, crew_ref: crew_ref });
    }
  };

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

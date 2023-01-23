import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from 'tgui/backend';
import { Stack, Input, Section, Tabs, NoticeBox, Box, Icon, Button } from 'tgui/components';
import { JOB2ICON } from '../common/JobToIcon';
import { CRIMESTATUS2COLOR } from './constants';
import { isRecordMatch } from './helpers';
import { SecureData, SecurityRecord } from './types';

/** Tabs on left, with search bar */
export const SecurityRecordTabs = (props, context) => {
  const { act, data } = useBackend<SecureData>(context);
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
const CrewTab = ({ record }, context) => {
  const { act } = useBackend<SecureData>(context);
  const [selectedRecord, setSelectedRecord] = useLocalState<
    SecurityRecord | undefined
  >(context, 'securityRecord', undefined);

  /** Chooses a record */
  const selectRecord = (record: SecurityRecord) => {
    if (selectedRecord?.ref === record.ref) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
      act('view_record', { lock_ref: record.lock_ref });
    }
  };

  const { name, rank, ref, wanted_status } = record;
  const isSelected = selectedRecord?.ref === ref;

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

import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from 'tgui/backend';
import { Stack, Input, Section, Tabs, NoticeBox, Box } from 'tgui/components';
import { CRIMESTATUS2COLOR } from './constants';
import { SecureData, SecurityRecord } from './types';

/** Tabs on left, with search bar */
export const RecordTabs = (props, context) => {
  const { act, data } = useBackend<SecureData>(context);
  const { records } = data;

  const errorMessage = !records.length
    ? 'No records found.'
    : 'No match. Refine your search.';

  const [selectedRecord, setSelectedRecord] = useLocalState<
    SecurityRecord | undefined
  >(context, 'securityRecord', undefined);
  const [search, setSearch] = useLocalState(context, 'search', '');

  const sorted = flow([
    filter(
      (record: SecurityRecord) =>
        record.fingerprint?.toLowerCase().includes(search?.toLowerCase()) ||
        record.name?.toLowerCase().includes(search?.toLowerCase())
    ),
    sortBy((record: SecurityRecord) => record.name),
  ])(records);

  /** Chooses a record */
  const selectRecord = (record: SecurityRecord) => {
    if (selectedRecord?.ref === record.ref) {
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
          placeholder="Fingerprint Search"
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
                <Tabs.Tab
                  className="candystripe"
                  key={index}
                  label={record.name}
                  onClick={() => selectRecord(record)}
                  selected={selectedRecord?.ref === record.ref}>
                  <Box color={CRIMESTATUS2COLOR[record.wanted_status]}>
                    {record.name}
                  </Box>
                </Tabs.Tab>
              ))
            )}
          </Tabs>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

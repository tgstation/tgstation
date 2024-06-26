import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from 'tgui/backend';
import { Stack, Section, Tabs, NoticeBox, Box, Icon } from 'tgui/components';
import { MedicalRecord, MedicalRecordData } from './types';

/** Displays all found records. */
export const MedicalRecordTabs = (props) => {
  const { act, data } = useBackend<MedicalRecordData>();
  const { records = [], station_z } = data;

  const errorMessage = !records.length
    ? 'No records found.'
    : 'No match. Refine your search.';

  const [search, setSearch] = useLocalState('search', '');

  const sorted: MedicalRecord[] = flow([
    sortBy((record: MedicalRecord) => record.name?.toLowerCase()),
  ])(records);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable>
          <Tabs vertical>
            {!sorted.length ? (
              <NoticeBox>{errorMessage}</NoticeBox>
            ) : (
              sorted.map((record, index) => (
                <CrewTab key={index} record={record} />
              ))
            )}
          </Tabs>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Individual crew tab */
const CrewTab = (props: { record: MedicalRecord }) => {
  const [selectedRecord, setSelectedRecord] = useLocalState<
    MedicalRecord | undefined
  >('medicalRecord', undefined);

  const { act, data } = useBackend<MedicalRecordData>();
  const { assigned_view } = data;
  const { record } = props;
  const { crew_ref, name, nickname } = record;

  /** Sets the record to preview */
  const selectRecord = (record: MedicalRecord) => {
    if (selectedRecord?.crew_ref === crew_ref) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
      act('view_record', { assigned_view: assigned_view, crew_ref: crew_ref });
    }
  };

  return (
    <Tabs.Tab
      className="candystripe"
      label={nickname ? nickname : name}
      onClick={() => selectRecord(record)}
      selected={selectedRecord?.crew_ref === crew_ref}
    >
      <Box wrap>
        <Icon name={'question'} /> {nickname ? nickname : name}
      </Box>
    </Tabs.Tab>
  );
};

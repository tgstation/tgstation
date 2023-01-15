import { useBackend, useLocalState } from '../backend';
import { LabeledList, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { CharacterPreview } from './PreferencesMenu/CharacterPreview';

type Data = {
  records: MedicalRecord[];
};

type MedicalRecord = {
  age: number;
  appearance: string;
  blood_type: string;
  dna: string;
  major_disabilities: string;
  minor_disabilities: string;
  name: string;
  notes: string;
  rank: string;
  ref: string;
  species: string;
};

export const MedicalRecords = (props, context) => {
  return (
    <Window title="Medical Records" width={700} height={500}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <RecordTabs />
          </Stack.Item>
          <Stack.Item grow={3}>
            <RecordView />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RecordTabs = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { records } = data;
  const [selectedRecord, setSelectedRecord] = useLocalState<
    MedicalRecord | undefined
  >(context, 'selectedRecord', undefined);

  const selectRecord = (record: MedicalRecord) => {
    if (selectedRecord === record) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
      act('view_record', { ref: record.ref });
    }
  };

  return (
    <Section fill>
      <Tabs vertical>
        {records.map((record, index) => (
          <Tabs.Tab
            className="candystripe"
            key={index}
            label={record.name}
            onClick={() => selectRecord(record)}
            selected={selectedRecord === record}>
            {record.name}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

const RecordView = (props, context) => {
  const { act } = useBackend<Data>(context);
  const [selectedRecord] = useLocalState<MedicalRecord | undefined>(
    context,
    'selectedRecord',
    undefined
  );

  if (!selectedRecord) return <NoticeBox>Nothing selected</NoticeBox>;

  const {
    age,
    appearance,
    blood_type,
    dna,
    major_disabilities,
    minor_disabilities,
    name,
    notes,
    rank,
    species,
  } = selectedRecord;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <CharacterPreview height="100%" id={appearance} />
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Notes">
              <pre>{notes}</pre>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={name}>
          <LabeledList>
            <LabeledList.Item label="Rank">{rank}</LabeledList.Item>
            <LabeledList.Item label="Age">{age}</LabeledList.Item>
            <LabeledList.Item label="Species">{species}</LabeledList.Item>
            <LabeledList.Item color="good" label="DNA">
              {dna}
            </LabeledList.Item>
            <LabeledList.Item color="bad" label="Blood Type">
              {blood_type}
            </LabeledList.Item>
            <LabeledList.Item label="Minor Disabilities">
              <pre>{minor_disabilities.replace('<br>', '\n')}</pre>
            </LabeledList.Item>
            <LabeledList.Item label="Major Disabilities">
              <pre>{major_disabilities.replace('<br>', '\n')}</pre>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

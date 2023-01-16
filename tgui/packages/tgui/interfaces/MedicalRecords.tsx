import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Icon, LabeledList, NoticeBox, Section, Stack, Tabs, TextArea, Tooltip } from '../components';
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
  notes: string[];
  quirk_notes: string;
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

/** Displays all found records. */
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
      act('view_record', { name: record.name });
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

/** Views a selected record. */
const RecordView = (props, context) => {
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
    quirk_notes,
    rank,
    species,
  } = selectedRecord;

  const minor_disabilities_array = getStringArray(minor_disabilities);
  const major_disabilities_array = getStringArray(major_disabilities);
  const quirk_notes_array = getStringArray(quirk_notes);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <CharacterPreview height="100%" id={appearance} />
          </Stack.Item>
          <Stack.Item grow>
            <NoteKeeper />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={name} wrap>
          <LabeledList>
            <LabeledList.Item label="Job">{rank}</LabeledList.Item>
            <LabeledList.Item label="Age">{age}</LabeledList.Item>
            <LabeledList.Item label="Species">{species}</LabeledList.Item>
            <LabeledList.Item color="good" label="DNA">
              <Box wrap>{dna}</Box>
            </LabeledList.Item>
            <LabeledList.Item color="bad" label="Blood Type">
              {blood_type}
            </LabeledList.Item>
            <LabeledList.Item label="Minor Disabilities">
              {minor_disabilities_array.map((disability, index) => (
                <Box key={index}>&#8226; {disability}</Box>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Major Disabilities">
              {major_disabilities_array.map((disability, index) => (
                <Box key={index}>&#8226; {disability}</Box>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Quirks">
              {quirk_notes_array.map((quirk, index) => (
                <Box key={index}>&#8226; {quirk}</Box>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Small section for adding notes. Passes a ref and note to Byond. */
const NoteKeeper = (props, context) => {
  const { act, data } = useBackend<Data>(context);

  const [selectedRecord] = useLocalState<MedicalRecord | undefined>(
    context,
    'selectedRecord',
    undefined
  );
  if (!selectedRecord) return <> </>;

  // We have to find the record because the selectedRecord is a copy of the
  // record in the data.
  const locatedRecord = data.records.find(
    (record) => record.ref === selectedRecord.ref
  );
  if (!locatedRecord) return <> </>;
  const { notes, ref } = locatedRecord;

  const [selectedNote, setSelectedNote] = useLocalState<number | undefined>(
    context,
    'selectedNote',
    undefined
  );
  const [writing, setWriting] = useLocalState(context, 'note', false);

  const addNote = (event, value: string) => {
    act('add_notes', { ref: ref, note: value });
    setWriting(false);
  };

  return (
    <Section buttons={<NoteTabs />} fill scrollable title="Notes">
      {writing && (
        <TextArea
          height="100%"
          maxLength={1024}
          onEnter={addNote}
          onEscape={() => setWriting(false)}
        />
      )}

      {selectedNote !== undefined && (
        <Box color="label" wrap>
          {notes[selectedNote]}
        </Box>
      )}
    </Section>
  );
};

/** Displays the notes with an add tab next to. */
const NoteTabs = (props, context) => {
  const [selectedRecord] = useLocalState<MedicalRecord | undefined>(
    context,
    'selectedRecord',
    undefined
  );
  if (!selectedRecord) return <> </>;

  const { data } = useBackend<Data>(context);
  const { records } = data;
  const notes =
    records.find((record) => record.ref === selectedRecord.ref)?.notes || [];

  const [selectedNote, setSelectedNote] = useLocalState<number | undefined>(
    context,
    'selectedNote',
    undefined
  );
  const [writing, setWriting] = useLocalState(context, 'note', false);

  /** Selects or deselects a note. */
  const setNote = (index: number) => {
    if (selectedNote === index) {
      setSelectedNote(undefined);
    } else {
      setSelectedNote(index);
    }
  };

  /** Sets the note to writing mode. */
  const composeNew = () => {
    setWriting(true);
    setSelectedNote(undefined);
  };

  return (
    <Tabs>
      {notes.map((note, index) => (
        <Tabs.Tab
          key={index}
          label={index + 1}
          onClick={() => setNote(index)}
          selected={index === selectedNote}>
          {index + 1}
        </Tabs.Tab>
      ))}
      <Tooltip
        content={multiline`Add a new note. Press enter or escape to exit view.`}
        position="bottom">
        <Tabs.Tab onClick={composeNew} selected={writing}>
          <Icon name="plus" /> New
        </Tabs.Tab>
      </Tooltip>
    </Tabs>
  );
};

/** Splits a medical string on <br> into a string array */
const getStringArray = (string: string) => {
  return string.split('<br>');
};

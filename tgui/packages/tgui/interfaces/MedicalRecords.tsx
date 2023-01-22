import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { BooleanLike } from 'common/react';
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, Icon, Input, LabeledList, NoticeBox, Section, Stack, Tabs, TextArea, Tooltip } from '../components';
import { Window } from '../layouts';
import { JOB2ICON } from './common/JobToIcon';
import { CharacterPreview } from './PreferencesMenu/CharacterPreview';
import { isRecordMatch } from './SecurityRecords/helpers';

type Data = {
  can_view: BooleanLike;
  records: MedicalRecord[];
};

type MedicalRecord = {
  age: number;
  appearance: string;
  blood_type: string;
  crew_ref: string;
  dna: string;
  gender: string;
  lock_ref: string;
  major_disabilities: string;
  minor_disabilities: string;
  name: string;
  notes: Note[];
  quirk_notes: string;
  rank: string;
  species: string;
};

type Note = {
  author: string;
  content: string;
  note_ref: string;
  time: string;
};

export const MedicalRecords = (props, context) => {
  return (
    <Window title="Medical Records" width={750} height={550}>
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
                    <Icon name={JOB2ICON[record.rank]} /> {record.name}
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

/** Views a selected record. */
const RecordView = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <NoticeBox>No record selected.</NoticeBox>;

  const { data } = useBackend<Data>(context);
  const { can_view } = data;

  const {
    age,
    appearance,
    blood_type,
    dna,
    gender,
    major_disabilities,
    minor_disabilities,
    name,
    quirk_notes,
    rank,
    species,
  } = foundRecord;

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
            {!can_view ? <NoteAuthorized /> : <NoteKeeper />}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={name} wrap>
          <LabeledList>
            <LabeledList.Item label="Job">{rank}</LabeledList.Item>
            <LabeledList.Item label="Age">{age}</LabeledList.Item>
            <LabeledList.Item label="Species">{species}</LabeledList.Item>
            <LabeledList.Item label="Gender">{gender}</LabeledList.Item>
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
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;

  const { act } = useBackend<Data>(context);
  const { crew_ref } = foundRecord;

  const [selectedNote, setSelectedNote] = useLocalState<Note | undefined>(
    context,
    'selectedNote',
    undefined
  );

  const [writing, setWriting] = useLocalState(context, 'note', false);

  const addNote = (event, value: string) => {
    act('add_note', {
      crew_ref: crew_ref,
      content: value,
    });
    setWriting(false);
  };

  const deleteNote = () => {
    if (!selectedNote) return;
    act('delete_note', {
      crew_ref: crew_ref,
      note_ref: selectedNote.note_ref,
    });
    setSelectedNote(undefined);
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

      {!!selectedNote && (
        <>
          <LabeledList>
            <LabeledList.Item
              label="Author"
              buttons={
                <Button color="bad" icon="trash" onClick={deleteNote} />
              }>
              {selectedNote.author}
            </LabeledList.Item>
            <LabeledList.Item label="Time">
              {selectedNote.time}
            </LabeledList.Item>
          </LabeledList>
          <Box color="label" mb={1} mt={1}>
            Content:
          </Box>
          <BlockQuote wrap>{selectedNote.content}</BlockQuote>
        </>
      )}
    </Section>
  );
};

/** Displays the notes with an add tab next to. */
const NoteTabs = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;
  const { notes } = foundRecord;

  const [selectedNote, setSelectedNote] = useLocalState<Note | undefined>(
    context,
    'selectedNote',
    undefined
  );
  const [writing, setWriting] = useLocalState(context, 'note', false);

  /** Selects or deselects a note. */
  const setNote = (note: Note) => {
    if (selectedNote?.note_ref === note.note_ref) {
      setSelectedNote(undefined);
    } else {
      setSelectedNote(note);
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
          onClick={() => setNote(note)}
          selected={selectedNote?.note_ref === note.note_ref}>
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

/** Warning on notes */
const NoteAuthorized = (props, context) => {
  // Psychic damage from this pun
  return (
    <Section fill title="Notes">
      <NoticeBox align="center" info>
        <Stack fill>
          <Stack.Item>
            <Icon color="average" name="exclamation-triangle" size={1.3} />
          </Stack.Item>
          <Stack.Item grow>Confidential</Stack.Item>
          <Stack.Item>
            <Icon color="average" name="exclamation-triangle" size={1.3} />
          </Stack.Item>
        </Stack>
      </NoticeBox>
    </Section>
  );
};

/** Splits a medical string on <br> into a string array */
const getStringArray = (string: string) => {
  return string.split('<br>');
};

/** We need an active reference and this a pain to rewrite */
const getCurrentRecord = (context) => {
  const [selectedRecord] = useLocalState<MedicalRecord | undefined>(
    context,
    'medicalRecord',
    undefined
  );
  if (!selectedRecord) return;
  const { data } = useBackend<Data>(context);
  const { records = [] } = data;
  const foundRecord = records.find(
    (record) => record.crew_ref === selectedRecord.crew_ref
  );
  if (!foundRecord) return;

  return foundRecord;
};

import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, Collapsible, Dropdown, Icon, Input, LabeledList, NoticeBox, RestrictedInput, Section, Stack, Table, Tabs, TextArea, Tooltip } from '../components';
import { formatTime } from '../format';
import { Window } from '../layouts';
import { CharacterPreview } from './PreferencesMenu/CharacterPreview';

type Data = {
  available_statuses: string[];
  logged_in: boolean;
  records: SecurityRecord[];
};

type SecurityRecord = {
  age: number;
  appearance: string;
  citations: Crime[];
  crimes: Crime[];
  fingerprint: string;
  gender: string;
  lock_ref: string;
  name: string;
  note: string;
  rank: string;
  ref: string;
  species: string;
  wanted_status: string;
};

type Crime = {
  author: string;
  details: string;
  fine: number;
  name: string;
  paid: number;
  ref: string;
  time: number;
};

const STATUS2COLOR = {
  '': 'white',
  'None': 'white',
  '*Arrest*': 'bad',
  'Suspected': 'purple',
  'Incarcerated': 'good',
  'Paroled': 'average',
  'Discharged': 'blue',
} as const;

enum TAB {
  Crimes,
  Citations,
  Add,
}

export const SecurityRecords = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { logged_in } = data;

  return (
    <Window title="Security Records" width={700} height={550}>
      <Window.Content>
        <Stack fill>
          {!logged_in ? (
            <Stack.Item grow>
              <Stack fill vertical>
                <Stack.Item grow />
                <Stack.Item align="center" grow={2}>
                  <Icon color="average" name="exclamation-triangle" size={15} />
                </Stack.Item>
                <Stack.Item align="center" grow>
                  <Box color="red" fontSize="18px" bold mt={5}>
                    Nanotrasen SecurityHUB
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <NoticeBox align="right">
                    You are not logged in.
                    <Button
                      ml={2}
                      icon="lock-open"
                      onClick={() => act('login')}>
                      Login
                    </Button>
                  </NoticeBox>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          ) : (
            <>
              <Stack.Item grow>
                <RecordTabs />
              </Stack.Item>
              <Stack.Item grow={3}>
                <Stack fill vertical>
                  <Stack.Item grow>
                    <RecordView />
                  </Stack.Item>
                  <Stack.Item>
                    <NoticeBox align="right" info>
                      Secure Your Workspace.
                      <Button
                        align="right"
                        icon="lock"
                        color="good"
                        ml={2}
                        onClick={() => act('logout')}>
                        Log Out
                      </Button>
                    </NoticeBox>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RecordTabs = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { records } = data;

  const [selectedRecord, setSelectedRecord] = useLocalState<
    SecurityRecord | undefined
  >(context, 'selectedRecord', undefined);
  const [search, setSearch] = useLocalState(context, 'search', '');

  // Filters the records by the search string
  const filteredRecords = records.filter((record) =>
    record.fingerprint?.toLowerCase().includes(search?.toLowerCase())
  );

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
            {!filteredRecords.length ? (
              <NoticeBox>No fingerprints match. Refine your search.</NoticeBox>
            ) : (
              filteredRecords.map((record, index) => (
                <Tabs.Tab
                  className="candystripe"
                  key={index}
                  label={record.name}
                  onClick={() => selectRecord(record)}
                  selected={selectedRecord === record}>
                  <Box color={STATUS2COLOR[record.wanted_status]}>
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

/** Views a selected record. */
const RecordView = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <NoticeBox>Nothing selected.</NoticeBox>;

  const { act, data } = useBackend<Data>(context);
  const { available_statuses } = data;

  const {
    age,
    appearance,
    fingerprint,
    gender,
    name,
    note,
    rank,
    ref,
    species,
    wanted_status,
  } = foundRecord;

  /** Sets the note */
  const setNote = (event, value) => {
    if (value === foundRecord.note) return;
    act('set_note', { note: value, ref: ref });
  };

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <CharacterPreview height="100%" id={appearance} />
          </Stack.Item>
          <Stack.Item grow>
            <CrimeWatch />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  height="1.7rem"
                  icon="print"
                  onClick={() => act('print_record', { ref: ref })}>
                  Print
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Dropdown
                  height="1.7rem"
                  onSelected={(value) =>
                    act('set_wanted', { ref: ref, status: value })
                  }
                  options={available_statuses}
                  selected={wanted_status}
                  width="10rem"
                />
              </Stack.Item>
            </Stack>
          }
          fill
          scrollable
          title={
            <Table.Cell color={STATUS2COLOR[wanted_status]}>{name}</Table.Cell>
          }
          wrap>
          <LabeledList>
            <LabeledList.Item label="Job">{rank}</LabeledList.Item>
            <LabeledList.Item label="Age">{age}</LabeledList.Item>
            <LabeledList.Item label="Species">{species}</LabeledList.Item>
            <LabeledList.Item label="Gender">{gender}</LabeledList.Item>
            <LabeledList.Item color="good" label="Fingerprint">
              {fingerprint}
            </LabeledList.Item>
            <LabeledList.Item label="Notes">
              <Input
                onEnter={setNote}
                placeholder={note ?? 'No notes. Click to add.'}
                value={note}
                width="85%"
              />
              <Button
                disabled={!note}
                icon="trash"
                ml={1}
                onClick={(event) => setNote(event, '')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Displays a list of crimes and allows to add new ones. */
const CrimeWatch = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;

  const { crimes, citations } = foundRecord;
  const [selectedTab, setSelectedTab] = useLocalState<TAB>(
    context,
    'selectedTab',
    TAB.Crimes
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            onClick={() => setSelectedTab(TAB.Crimes)}
            selected={selectedTab === TAB.Crimes}>
            Crimes: {crimes.length}
          </Tabs.Tab>
          <Tabs.Tab
            onClick={() => setSelectedTab(TAB.Citations)}
            selected={selectedTab === TAB.Citations}>
            Citations: {citations.length}
          </Tabs.Tab>
          <Tooltip content="Add a new crime or citation" position="bottom">
            <Tabs.Tab
              onClick={() => setSelectedTab(TAB.Add)}
              selected={selectedTab === TAB.Add}>
              <Icon name="plus" />
            </Tabs.Tab>
          </Tooltip>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {selectedTab < TAB.Add ? (
            <CrimeList tab={selectedTab} />
          ) : (
            <CrimeAuthor />
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Displays the crimes and citations of a record. */
const CrimeList = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;

  const { citations, crimes } = foundRecord;
  const { tab } = props;
  const toDisplay = tab === TAB.Crimes ? crimes : citations;

  return (
    <Stack fill vertical>
      {!toDisplay.length ? (
        <Stack.Item>
          <NoticeBox>
            No {tab === TAB.Crimes ? 'crimes' : 'citations'} found.
          </NoticeBox>
        </Stack.Item>
      ) : (
        toDisplay.map((item, index) => <CrimeDisplay key={index} item={item} />)
      )}
    </Stack>
  );
};

/** Displays an individual crime */
const CrimeDisplay = ({ item }: { item: Crime }, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;
  const { act } = useBackend<Data>(context);
  const { author, details, fine, name, paid, time } = item;
  const showFine = !!fine && fine > 0 ? `: ${fine} cr` : '';

  return (
    <Stack.Item>
      <Collapsible
        buttons={
          <Button
            color="bad"
            icon="trash"
            onClick={() =>
              act('delete_crime', {
                crew_ref: foundRecord.ref,
                crime_ref: item.ref,
              })
            }
          />
        }
        color={fine && fine > 0 ? 'average' : ''}
        title={name.slice(0, 18) + showFine}>
        <LabeledList>
          <LabeledList.Item label="Time">{formatTime(time)}</LabeledList.Item>
          <LabeledList.Item label="Author">{author}</LabeledList.Item>
          {fine && (
            <>
              <LabeledList.Item color="bad" label="Fine">
                {fine}cr <Icon color="gold" name="coins" />
              </LabeledList.Item>
              <LabeledList.Item color="good" label="Paid">
                {paid}cr <Icon color="gold" name="coins" />
              </LabeledList.Item>
            </>
          )}
        </LabeledList>
        <Box color="label" mt={1} mb={1}>
          Details:
        </Box>
        <BlockQuote>{details}</BlockQuote>
      </Collapsible>
    </Stack.Item>
  );
};

/** Writes a new crime. Reducers don't seem to work here, so... */
const CrimeAuthor = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;

  const { ref } = foundRecord;
  const { act } = useBackend<Data>(context);

  const [crimeName, setCrimeName] = useLocalState(context, 'crimeName', '');
  const [crimeDetails, setCrimeDetails] = useLocalState(
    context,
    'crimeDetails',
    ''
  );
  const [crimeFine, setCrimeFine] = useLocalState(context, 'crimeFine', 0);
  const [selectedTab, setSelectedTab] = useLocalState<TAB>(
    context,
    'selectedTab',
    TAB.Crimes
  );

  const createCrime = () => {
    if (!crimeName) return;
    act('add_crime', {
      details: crimeDetails || 'No details.',
      fine: crimeFine,
      name: crimeName,
      ref: ref,
    });
    setSelectedTab(crimeFine ? TAB.Citations : TAB.Crimes);
  };

  return (
    <Stack fill vertical>
      <Stack.Item color="label">
        Name
        <Input
          onChange={(_, value) => setCrimeName(value)}
          fluid
          placeholder="Brief overview"
        />
      </Stack.Item>
      <Stack.Item color="label">
        Details
        <TextArea
          onChange={(_, value) => setCrimeDetails(value)}
          multiline
          height={4}
          fluid
          placeholder="Type some details..."
        />
      </Stack.Item>
      <Stack.Item color="label">
        Fine (leave blank to arrest)
        <RestrictedInput
          onChange={(_, value) => setCrimeFine(value)}
          fluid
          maxValue={1000}
        />
      </Stack.Item>
      <Stack.Item>
        <Button disabled={!crimeName} icon="plus" onClick={createCrime}>
          Create
        </Button>
      </Stack.Item>
    </Stack>
  );
};

/** We need an active reference and this a pain to rewrite */
const getCurrentRecord = (context) => {
  const [selectedRecord] = useLocalState<SecurityRecord | undefined>(
    context,
    'selectedRecord',
    undefined
  );
  if (!selectedRecord) return;
  const { data } = useBackend<Data>(context);
  const { records } = data;
  const foundRecord = records.find(
    (record) => record.ref === selectedRecord.ref
  );
  if (!foundRecord) return;

  return foundRecord;
};

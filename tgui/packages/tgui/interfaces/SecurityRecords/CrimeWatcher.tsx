import { useLocalState, useBackend } from 'tgui/backend';
import { SECURETAB, Crime, SecureData } from './types';
import { getCurrentRecord } from './helpers';
import { Stack, Section, Tabs, Tooltip, Icon, NoticeBox, BlockQuote, Box, Button, Collapsible, Input, LabeledList, RestrictedInput, TextArea } from 'tgui/components';
import { formatTime } from 'tgui/format';

/** Displays a list of crimes and allows to add new ones. */
export const CrimeWatcher = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;

  const { crimes, citations } = foundRecord;
  const [selectedTab, setSelectedTab] = useLocalState<SECURETAB>(
    context,
    'selectedTab',
    SECURETAB.Crimes
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            onClick={() => setSelectedTab(SECURETAB.Crimes)}
            selected={selectedTab === SECURETAB.Crimes}>
            Crimes: {crimes.length}
          </Tabs.Tab>
          <Tabs.Tab
            onClick={() => setSelectedTab(SECURETAB.Citations)}
            selected={selectedTab === SECURETAB.Citations}>
            Citations: {citations.length}
          </Tabs.Tab>
          <Tooltip content="Add a new crime or citation" position="bottom">
            <Tabs.Tab
              onClick={() => setSelectedTab(SECURETAB.Add)}
              selected={selectedTab === SECURETAB.Add}>
              <Icon name="plus" />
            </Tabs.Tab>
          </Tooltip>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {selectedTab < SECURETAB.Add ? (
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
  const toDisplay = tab === SECURETAB.Crimes ? crimes : citations;

  return (
    <Stack fill vertical>
      {!toDisplay.length ? (
        <Stack.Item>
          <NoticeBox>
            No {tab === SECURETAB.Crimes ? 'crimes' : 'citations'} found.
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
  const { act } = useBackend<SecureData>(context);
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
  const { act } = useBackend<SecureData>(context);

  const [crimeName, setCrimeName] = useLocalState(context, 'crimeName', '');
  const [crimeDetails, setCrimeDetails] = useLocalState(
    context,
    'crimeDetails',
    ''
  );
  const [crimeFine, setCrimeFine] = useLocalState(context, 'crimeFine', 0);
  const [selectedTab, setSelectedTab] = useLocalState<SECURETAB>(
    context,
    'selectedTab',
    SECURETAB.Crimes
  );

  const createCrime = () => {
    if (!crimeName) return;
    act('add_crime', {
      details: crimeDetails,
      fine: crimeFine,
      name: crimeName,
      ref: ref,
    });
    setSelectedTab(crimeFine ? SECURETAB.Citations : SECURETAB.Crimes);
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

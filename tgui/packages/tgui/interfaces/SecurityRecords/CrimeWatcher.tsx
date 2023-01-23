import { useLocalState, useBackend } from 'tgui/backend';
import { SECURETAB, Crime, SecurityRecordsData } from './types';
import { getSecurityRecord } from './helpers';
import { BlockQuote, Box, Button, Collapsible, Icon, Input, LabeledList, NoticeBox, RestrictedInput, Section, Stack, Tabs, TextArea, Tooltip } from 'tgui/components';

/** Displays a list of crimes and allows to add new ones. */
export const CrimeWatcher = (props, context) => {
  const foundRecord = getSecurityRecord(context);
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
  const foundRecord = getSecurityRecord(context);
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
  const foundRecord = getSecurityRecord(context);
  if (!foundRecord) return <> </>;

  const { crew_ref } = foundRecord;
  const { act } = useBackend<SecurityRecordsData>(context);
  const { author, crime_ref, details, fine, name, paid, time } = item;
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
                crew_ref: crew_ref,
                crime_ref: crime_ref,
              })
            }
          />
        }
        color={fine && fine > 0 ? 'average' : ''}
        title={name.slice(0, 18) + showFine}>
        <LabeledList>
          <LabeledList.Item label="Time">{time}</LabeledList.Item>
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
  const foundRecord = getSecurityRecord(context);
  if (!foundRecord) return <> </>;

  const { crew_ref } = foundRecord;
  const { act } = useBackend<SecurityRecordsData>(context);

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

  /** Sends form to backend */
  const createCrime = () => {
    if (!crimeName) return;
    act('add_crime', {
      crew_ref: crew_ref,
      details: crimeDetails,
      fine: crimeFine,
      name: crimeName,
    });
    reset();
  };

  /** Resets form data since it persists.. */
  const reset = () => {
    setCrimeDetails('');
    setCrimeFine(0);
    setCrimeName('');
    setSelectedTab(crimeFine ? SECURETAB.Citations : SECURETAB.Crimes);
  };

  return (
    <Stack fill vertical>
      <Stack.Item color="label">
        Name
        <Input
          onChange={(_, value) => setCrimeName(value)}
          fluid
          maxLength={25}
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
        <Button.Confirm
          content="Create"
          disabled={!crimeName}
          icon="plus"
          onClick={createCrime}
        />
      </Stack.Item>
    </Stack>
  );
};

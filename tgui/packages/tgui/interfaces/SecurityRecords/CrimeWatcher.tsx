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
  const { act, data } = useBackend<SecurityRecordsData>(context);
  const { current_user, higher_access } = data;
  const { author, crime_ref, details, fine, name, paid, time, valid } = item;
  const showFine = !!fine && fine > 0 ? `: ${fine} cr` : '';

  let collapsibleColor = '';
  if (!valid) {
    collapsibleColor = 'grey';
  } else if (fine && fine > 0) {
    collapsibleColor = 'average';
  }

  let displayTitle = name;
  if (fine && fine > 0) {
    displayTitle = name.slice(0, 18) + showFine;
  }

  const [editing, setEditing] = useLocalState(
    context,
    `editing_${crime_ref}`,
    false
  );

  return (
    <Stack.Item>
      <Collapsible color={collapsibleColor} open={editing} title={displayTitle}>
        <LabeledList>
          <LabeledList.Item label="Time">{time}</LabeledList.Item>
          <LabeledList.Item label="Author">{author}</LabeledList.Item>
          <LabeledList.Item color={!valid ? 'bad' : 'good'} label="Status">
            {!valid ? 'Void' : 'Active'}
          </LabeledList.Item>
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

        {!editing ? (
          <Box mt={2}>
            <Button
              disabled={!valid || (!higher_access && author !== current_user)}
              icon="pen"
              onClick={() => setEditing(true)}>
              Edit
            </Button>
            <Button.Confirm
              content="Invalidate"
              disabled={!higher_access || !valid}
              icon="ban"
              onClick={() =>
                act('invalidate_crime', {
                  crew_ref: crew_ref,
                  crime_ref: crime_ref,
                })
              }
            />
          </Box>
        ) : (
          <>
            <Input
              fluid
              maxLength={25}
              onEscape={() => setEditing(false)}
              onEnter={(event, value) => {
                setEditing(false);
                act('edit_crime', {
                  crew_ref: crew_ref,
                  crime_ref: crime_ref,
                  name: value,
                });
              }}
              placeholder="Enter a new name"
            />
            <Input
              fluid
              maxLength={1025}
              mt={1}
              onEscape={() => setEditing(false)}
              onEnter={(event, value) => {
                setEditing(false);
                act('edit_crime', {
                  crew_ref: crew_ref,
                  crime_ref: crime_ref,
                  description: value,
                });
              }}
              placeholder="Enter a new description"
            />
          </>
        )}
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

  const nameMeetsReqs = crimeName?.length > 2;

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
          fluid
          maxLength={25}
          onChange={(_, value) => setCrimeName(value)}
          placeholder="Brief overview"
        />
      </Stack.Item>
      <Stack.Item color="label">
        Details
        <TextArea
          fluid
          height={4}
          maxLength={1025}
          multiline
          onChange={(_, value) => setCrimeDetails(value)}
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
          disabled={!nameMeetsReqs}
          icon="plus"
          onClick={createCrime}
          tooltip={!nameMeetsReqs ? 'Name must be at least 3 characters.' : ''}
        />
      </Stack.Item>
    </Stack>
  );
};

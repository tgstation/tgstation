import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { BlockQuote, Button, Collapsible, LabeledList, NoticeBox, RestrictedInput, Section, Stack, Tabs } from '../components';
import { formatTime } from '../format';

type Data = {
  records: WarrantRecord[];
};

type WarrantRecord = {
  citations: Citation[];
  crew_name: string;
  crew_ref: string;
  rank: string;
};

type Citation = {
  details: string;
  fine_name: string;
  fine_ref: string;
  fine: number;
  paid: number;
  time: number;
};

export const WarrantConsole = (props, context) => {
  const [selectedRecord] = useLocalState<WarrantRecord | undefined>(
    context,
    'selectedRecord',
    undefined
  );

  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={2}>
            <RecordList />
          </Stack.Item>
          {selectedRecord && (
            <Stack.Item grow={3}>
              <ViewRecord />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays all valid records with warrants. */
const RecordList = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { records } = data;

  const [selectedRecord, setSelectedRecord] = useLocalState<
    WarrantRecord | undefined
  >(context, 'selectedRecord', undefined);

  const selectHandler = (record: WarrantRecord) => {
    if (selectedRecord?.crew_ref === record.crew_ref) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
    }
  };

  return (
    <Section
      buttons={
        <Button
          icon="sync"
          onClick={() => act('refresh')}
          tooltip="Refresh"
          tooltipPosition="bottom-start"
        />
      }
      fill
      scrollable
      title="Citations">
      <Stack fill vertical>
        {!records?.length ? (
          <NoticeBox>No citations issued.</NoticeBox>
        ) : (
          <Tabs vertical>
            {records.map((record, index) => (
              <Tabs.Tab
                className="candystripe"
                key={index}
                onClick={() => selectHandler(record)}
                selected={selectedRecord?.crew_ref === record.crew_ref}>
                {record.crew_name}: {record.citations.length}
              </Tabs.Tab>
            ))}
          </Tabs>
        )}
      </Stack>
    </Section>
  );
};

/** Views info on the current selection. */
const ViewRecord = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;

  const { citations = [], crew_name } = foundRecord;

  return (
    <Section fill scrollable title={crew_name}>
      <Stack fill vertical>
        {citations.map((citation, index) => (
          <Stack.Item key={index}>
            <CitationManager citation={citation} />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

/** Handles paying fines */
const CitationManager = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;

  const { act } = useBackend<Data>(context);
  const {
    citation: { author, details, fine, fine_ref, fine_name, paid, time },
  } = props;

  const { crew_ref } = foundRecord;

  const [paying, setPaying] = useLocalState(context, 'citationAmount', 5);

  return (
    <Collapsible
      buttons={
        <Button
          disabled={fine <= 0}
          icon="print"
          onClick={() =>
            act('print', { crew_ref: crew_ref, fine_ref: fine_ref })
          }>
          Print
        </Button>
      }
      title={fine_name}>
      <LabeledList>
        <LabeledList.Item label="Details">
          <BlockQuote>{details}</BlockQuote>
        </LabeledList.Item>
        <LabeledList.Item label="Author">{author}</LabeledList.Item>
        <LabeledList.Item label="Time">{formatTime(time)}</LabeledList.Item>
        <LabeledList.Item label="Fine">{fine}</LabeledList.Item>
        <LabeledList.Item label="Paid">{paid}</LabeledList.Item>
        {fine > 0 && (
          <LabeledList.Item label="Pay">
            <RestrictedInput
              maxValue={fine}
              minValue={5}
              onChange={(event, value) => setPaying(value)}
              value={paying}
            />
            <Button.Confirm
              content="Pay"
              onClick={() =>
                act('pay', {
                  amount: paying,
                  crew_ref: crew_ref,
                  fine_ref: fine_ref,
                })
              }
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Collapsible>
  );
};

/** We need an active reference and this a pain to rewrite */
export const getCurrentRecord = (context) => {
  const [selectedRecord] = useLocalState<WarrantRecord | undefined>(
    context,
    'selectedRecord',
    undefined
  );
  if (!selectedRecord) return;
  const { data } = useBackend<Data>(context);
  const { records } = data;
  const foundRecord = records.find(
    (record) => record.crew_ref === selectedRecord.crew_ref
  );
  if (!foundRecord) return;

  return foundRecord;
};

import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, Box, NoticeBox, Table } from '../components';
import { Window } from '../layouts';
import { AdventureDataProvider, AdventureScreen } from './ExodroneConsole';
import { formatTime } from '../format';

type Adventure = {
  ref: string;
  name: string;
  id: string;
  approved: boolean;
  uploader: string;
  version: number;
  timestamp: string;
  json_status: string;
};

type AdventureBrowserData = AdventureDataProvider & {
  adventures: Array<Adventure>;
  feedback_message: string;
  play_mode: boolean;
  adventure_data: any;
  delay_time: number;
  delay_message: string;
};

const AdventureEntry = (props, context) => {
  const { data, act } = useBackend<AdventureBrowserData>(context);
  const { entry_ref, close }: { entry_ref: string, close: () => void } = props;
  const entry = data.adventures.find(x => x.ref === entry_ref);
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="ID">{entry.id}</LabeledList.Item>
        <LabeledList.Item label="Name">{entry.name}</LabeledList.Item>
        <LabeledList.Item label="JSON Version">{entry.version}</LabeledList.Item>
        <LabeledList.Item label="Uploader">{entry.uploader}</LabeledList.Item>
        <LabeledList.Item label="Last Update">{entry.timestamp}</LabeledList.Item>
        <LabeledList.Item label="Approved">
          <Button.Checkbox
            checked={entry.approved}
            onClick={() => act("approve", { ref: entry.ref })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="JSON">
          {entry.json_status}
          <Button onClick={() => act("upload", { ref: entry.ref })} content="Upload" />
          <Button onClick={() => act("download", { ref: entry.ref })} content="Download" />
        </LabeledList.Item>
      </LabeledList>
      <Button.Confirm onClick={() => { close(); act("delete", { ref: entry.ref }); }} content="Delete" />
      <Button onClick={() => act("play", { ref: entry.ref })} content="Play" />
      <Button onClick={() => act("refresh", { ref: entry.ref })} content="Refresh" />
      <Button.Confirm onClick={() => act("save", { ref: entry.ref })} content="Save" />
      <Button onClick={close} content="Close" />
    </Section>
  );
};

const AdventureList = (props, context) => {
  const { data, act } = useBackend<AdventureBrowserData>(context);
  const [
    openAdventure,
    setOpenAdventure,
  ] = useLocalState(context, 'openAdventure', null);

  return (
    <>
      {openAdventure && (
        <AdventureEntry
          entry_ref={openAdventure}
          close={() => setOpenAdventure(null)} />
      )}
      {!openAdventure && (
        <Table>
          <Table.Row>
            <Table.Cell color="label">ID</Table.Cell>
            <Table.Cell color="label">Title</Table.Cell>
            <Table.Cell color="label">Edit</Table.Cell>
          </Table.Row>
          {data.adventures.map(p => (
            <Table.Row
              key={p.ref}
              className="candystripe">
              <Table.Cell>{p.id}</Table.Cell>
              <Table.Cell>{p.name}</Table.Cell>
              <Table.Cell><Button icon="edit" onClick={() => setOpenAdventure(p.ref)} /></Table.Cell>
            </Table.Row>
          ))}
          <Table.Row>
            <Button onClick={() => act("create")}>Create New</Button>
          </Table.Row>
        </Table>
      )}
    </>
  );
};

const DebugPlayer = (props, context) => {
  const { data, act } = useBackend<AdventureBrowserData>(context);
  return (
    <Section
      title="Playtest"
      buttons={<Button onClick={() => act("end_play")}>End Playtest</Button>}>
      {data.delay_time > 0
        ? <Box>DELAY {formatTime(data.delay_time)} / {data.delay_message}</Box>
        : <AdventureScreen hide_status />}
    </Section>);
};

export const AdventureBrowser = (props, context) => {
  const { data } = useBackend<AdventureBrowserData>(context);

  return (
    <Window width={650} height={500} title="Adventure Manager">
      <Window.Content>
        {!!data.feedback_message && (
          <NoticeBox>
            {data.feedback_message}
          </NoticeBox>
        )}
        {data.play_mode ? (<DebugPlayer />) : (<AdventureList />)}
      </Window.Content>
    </Window>
  );
};

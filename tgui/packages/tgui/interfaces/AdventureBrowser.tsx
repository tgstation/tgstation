import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, NoticeBox, Table } from '../components';
import { Window } from '../layouts';
import { AdventureDataProvider, AdventureScreen } from './ExodroneConsole';
import { formatTime } from '../format';

type Adventure = {
  ref: string;
  name: string;
  filename: string;
  approved: boolean;
  uploader: string;
  version: number;
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

const AdventureList = (props, context) => {
  const { data, act } = useBackend<AdventureBrowserData>(context);
  const [openAdventure, setOpenAdventure] = useLocalState<string | null>(
    context,
    'openAdventure',
    null
  );

  return (
    <Table>
      <Table.Row>
        <Table.Cell color="label">Filename</Table.Cell>
        <Table.Cell color="label">Title</Table.Cell>
        <Table.Cell color="label">Author</Table.Cell>
        <Table.Cell color="label">Playtest</Table.Cell>
      </Table.Row>
      {data.adventures.map((adventure) => (
        <Table.Row key={adventure.ref} className="candystripe">
          <Table.Cell>{adventure.filename}</Table.Cell>
          <Table.Cell>{adventure.name}</Table.Cell>
          <Table.Cell>{adventure.uploader}</Table.Cell>
          <Table.Cell>
            <Button
              color="good"
              onClick={() => act('play', { ref: adventure.ref })}
              content="Play"
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const DebugPlayer = (props, context) => {
  const { data, act } = useBackend<AdventureBrowserData>(context);
  return (
    <Section
      title="Playtest"
      buttons={<Button onClick={() => act('end_play')}>End Playtest</Button>}>
      {data.delay_time > 0 ? (
        <Box>
          DELAY {formatTime(data.delay_time)} / {data.delay_message}
        </Box>
      ) : (
        <AdventureScreen
          adventure_data={data.adventure_data}
          drone_integrity={100}
          drone_max_integrity={100}
          hide_status
        />
      )}
    </Section>
  );
};

export const AdventureBrowser = (props, context) => {
  const { data } = useBackend<AdventureBrowserData>(context);

  return (
    <Window width={600} height={400} title="Adventure Overview">
      <Window.Content>
        {!!data.feedback_message && (
          <NoticeBox>{data.feedback_message}</NoticeBox>
        )}
        {data.play_mode ? <DebugPlayer /> : <AdventureList />}
      </Window.Content>
    </Window>
  );
};

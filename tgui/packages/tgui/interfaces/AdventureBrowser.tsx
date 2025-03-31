import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';
import { formatTime } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AdventureDataProvider, AdventureScreen } from './ExodroneConsole';

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

const AdventureList = (props) => {
  const { data, act } = useBackend<AdventureBrowserData>();

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

const DebugPlayer = (props) => {
  const { data, act } = useBackend<AdventureBrowserData>();
  return (
    <Section
      title="Playtest"
      buttons={<Button onClick={() => act('end_play')}>End Playtest</Button>}
    >
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

export const AdventureBrowser = (props) => {
  const { data } = useBackend<AdventureBrowserData>();

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

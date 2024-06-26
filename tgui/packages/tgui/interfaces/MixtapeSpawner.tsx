import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Section, Button, Stack, Tabs } from '../components';

type Data = {
  approved_cassettes: Cassette[];
};

type Cassette = {
  name: string;
  desc: string;
  cassette_design_front: string;
  creator_ckey: string;
  creator_name: string;
  song_names: SongNames;
  id: string;
};

type SongNames = {
  side1: string[];
  side2: string[];
};

export const MixtapeSpawner = (props) => {
  const { act, data } = useBackend<Data>();
  const { approved_cassettes } = data;
  const [selected_cassette, setSelectedCassette] = useLocalState(
    'selected_cassette',
    approved_cassettes[0],
  );
  return (
    <Window title="Mixtape Spawner" width={500} height={488}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width={'50%'}>
            <Section fill scrollable>
              <Tabs fluid vertical>
                {approved_cassettes.map((cassette) => (
                  <Tabs.Tab
                    key={cassette.id}
                    fluid
                    ellipsis
                    color="transparent"
                    selected={cassette.id === selected_cassette.id}
                    onClick={() => setSelectedCassette(cassette)}
                  >
                    {cassette.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item width={'50%'}>
            <Stack vertical>
              <Stack.Item>
                <Stack vertical>
                  <Stack.Item>{selected_cassette.name}</Stack.Item>
                  <Stack.Item>
                    CKey: {selected_cassette.creator_ckey}
                  </Stack.Item>
                  <Stack.Item>
                    Character: {selected_cassette.creator_name}
                  </Stack.Item>
                  <Stack.Item>
                    <span style={{ 'text-decoration': 'underline' }}>
                      Side 1:
                    </span>
                  </Stack.Item>
                  {selected_cassette.song_names.side1.map((songs) => (
                    <Stack.Item key={songs}>{songs}</Stack.Item>
                  ))}
                  <Stack.Item>
                    <span style={{ 'text-decoration': 'underline' }}>
                      Side 2:
                    </span>
                  </Stack.Item>
                  {selected_cassette.song_names.side2.map((songs) => (
                    <Stack.Item key={songs}>{songs}</Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item align="center">
                <Button
                  onClick={() =>
                    act('spawn', {
                      id: selected_cassette.id,
                    })
                  }
                >
                  Spawn
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

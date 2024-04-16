import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Button, Dropdown, NoticeBox, Section, Table } from '../components';
import { Window } from '../layouts';

type Lobby = {
  name: string;
  players: number;
  max_players: number;
  map: string;
  playing: BooleanLike;
};

type Data = {
  hosting: BooleanLike;
  admin: BooleanLike;
  playing: string;
  lobbies: Lobby[];
};

export function DeathmatchPanel(props) {
  const { act, data } = useBackend<Data>();
  const { hosting } = data;

  return (
    <Window title="Deathmatch Lobbies" width={360} height={400}>
      <Window.Content>
        <NoticeBox danger>
          If you play, you can still possibly be returned to your body (No
          Guarantees)!
        </NoticeBox>
        <LobbyPane />
        <Button
          disabled={!!hosting}
          fluid
          textAlign="center"
          color="good"
          onClick={() => act('host')}
        >
          Create Lobby
        </Button>
      </Window.Content>
    </Window>
  );
}

function LobbyPane(props) {
  const { act, data } = useBackend<Data>();
  const { admin, lobbies = [], playing, hosting } = data;

  return (
    <Section height="80%">
      <Table>
        <Table.Row>
          <Table.Cell bold>Host</Table.Cell>
          <Table.Cell bold>Map</Table.Cell>
          <Table.Cell bold>Players</Table.Cell>
        </Table.Row>
        {lobbies.map((lobby) => (
          <Table.Row key={lobby.name}>
            <Table.Cell>
              {(!admin && lobby.name) || (
                <Dropdown
                  width={10}
                  selected={lobby.name}
                  options={['Close', 'View']}
                  onSelected={(value) =>
                    act('admin', {
                      id: lobby.name,
                      func: value,
                    })
                  }
                />
              )}
            </Table.Cell>
            <Table.Cell>{lobby.map}</Table.Cell>
            <Table.Cell>
              {lobby.players}/{lobby.max_players}
            </Table.Cell>
            <Table.Cell>
              {(!lobby.playing && (
                <>
                  <Button
                    disabled={
                      (!!hosting || !!playing) && playing !== lobby.name
                    }
                    color="good"
                    onClick={() => act('join', { id: lobby.name })}
                  >
                    {playing === lobby.name ? 'View' : 'Join'}
                  </Button>
                  <Button
                    color="caution"
                    icon="eye"
                    onClick={() => act('spectate', { id: lobby.name })}
                  />
                </>
              )) || (
                <Button
                  disabled={(!!hosting || !!playing) && playing !== lobby.name}
                  color="good"
                  onClick={() => act('spectate', { id: lobby.name })}
                >
                  Spectate
                </Button>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}

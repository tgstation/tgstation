import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  Modal,
  Section,
  Stack,
  Table,
} from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

type Player = Record<string, PlayerInfo>;

type PlayerInfo = {
  host: number;
  ready: BooleanLike;
};

type Modifier = {
  name: string;
  desc: string;
  modpath: string;
  selected: BooleanLike;
  selectable: BooleanLike;
  player_selected: BooleanLike;
  player_selectable: BooleanLike;
};

type Data = {
  self: string;
  host: BooleanLike;
  admin: BooleanLike;
  playing: BooleanLike;
  loadouts: string[];
  maps: string[];
  map: {
    name: string;
    desc: string;
    time: number;
    min_players: number;
    max_players: number;
  };
  mod_menu_open: BooleanLike;
  modifiers: Modifier[];
  active_mods: string;
  loadoutdesc: string;
  players: Player[];
  observers: Player[];
};

export function DeathmatchLobby(props) {
  const { act, data } = useBackend<Data>();
  const { admin, observers = [], self } = data;

  return (
    <Window title="Deathmatch Lobby" width={560} height={480}>
      <ModSelector />
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow={3}>
                <PlayerColumn />
              </Stack.Item>
              <Stack.Item grow={2}>
                <HostControls />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section align="center">
              <Button color="good" onClick={() => act('start_game')}>
                Start Game
              </Button>
              <Button color="bad" onClick={() => act('leave_game')}>
                Leave Game
              </Button>
              <Button color="caution" onClick={() => act('observe')}>
                {observers[self] ? 'Join' : 'Observe'}
              </Button>
              {!!admin && (
                <Button
                  icon="exclamation"
                  color="caution"
                  onClick={() => act('admin', { func: 'Force start' })}
                >
                  Force Start
                </Button>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function PlayerColumn(props) {
  const { act, data } = useBackend<Data>();
  const {
    players = [],
    host,
    admin,
    self,
    observers = [],
    loadouts = [],
  } = data;

  return (
    <Section fill scrollable>
      <Table>
        <Table.Row>
          <Table.Cell collapsing />
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Loadout</Table.Cell>
          <Table.Cell collapsing>Ready</Table.Cell>
        </Table.Row>
        {Object.keys(players).map((player) => {
          const fullAccess = (!!host && !!players[player].host) || !admin;

          return (
            <Table.Row className="candystripe" key={player}>
              <Table.Cell collapsing verticalAlign="top" pt="2px">
                {!!players[player].host && <Icon name="star" />}
              </Table.Cell>
              <Table.Cell verticalAlign="top" pt={!fullAccess && '2px'}>
                {!fullAccess ? (
                  <b>{player}</b>
                ) : (
                  <Dropdown
                    width={9}
                    selected={player}
                    options={['Kick', 'Transfer host', 'Toggle observe']}
                    onSelected={(value) =>
                      act('host', {
                        id: player,
                        func: value,
                      })
                    }
                  />
                )}
              </Table.Cell>
              <Table.Cell>
                <Dropdown
                  width={10}
                  selected={players[player].loadout}
                  disabled={!(host || player === self)}
                  options={loadouts}
                  onSelected={(value) =>
                    act('change_loadout', {
                      player: player,
                      loadout: value,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell collapsing verticalAlign="top" pt="2px">
                <ButtonCheckbox
                  disabled={player !== self}
                  checked={players[player].ready}
                  onClick={() => act('ready')}
                />
              </Table.Cell>
            </Table.Row>
          );
        })}
        {Object.keys(observers).map((observer) => {
          const fullAccess = (!!host && !!players[observer].host) || !admin;

          return (
            <Table.Row key={observer}>
              <Table.Cell collapsing>
                {(!!observers[observer].host && <Icon name="star" />) || (
                  <Icon name="eye" />
                )}
              </Table.Cell>
              <Table.Cell>
                {!fullAccess ? (
                  <b>{observer}</b>
                ) : (
                  <Dropdown
                    width={8}
                    selected={observer}
                    options={['Kick', 'Transfer host', 'Toggle observe']}
                    onSelected={(value) =>
                      act('host', {
                        id: observer,
                        func: value,
                      })
                    }
                  />
                )}
              </Table.Cell>
              <Table.Cell>Observing</Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
}

function HostControls(props) {
  const { act, data } = useBackend<Data>();
  const {
    active_mods = [],
    admin,
    host,
    loadoutdesc,
    map,
    maps = [],
    players = [],
    playing,
  } = data;

  return (
    <Section fill>
      <Box textAlign="center">
        {(!!host && (
          <Dropdown
            selected={map.name}
            options={maps}
            onSelected={(value) =>
              act('host', {
                func: 'change_map',
                map: value,
              })
            }
          />
        )) || <b>{map.name}</b>}
      </Box>
      <Divider />
      {map.desc}
      <Divider />
      <Box textAlign="center">
        Maximum Play Time: <b>{`${map.time / 600}min`}</b>
        <br />
        Min players: <b>{map.min_players}</b>
        <br />
        Max players: <b>{map.max_players}</b>
        <br />
        Current players: <b>{Object.keys(players).length}</b>
      </Box>
      <Divider />
      <Box textAlign="center">{active_mods}</Box>
      {(!!admin || !!host) && (
        <>
          <Divider />
          <Button textAlign="center" fluid onClick={() => act('open_mod_menu')}>
            Toggle Modifiers
          </Button>
        </>
      )}
      <Divider />
      <Box textAlign="center">Loadout Description</Box>
      <Divider />
      <Box textAlign="center">{loadoutdesc}</Box>
      {!!playing && (
        <>
          <Divider />
          <Box textAlign="center">
            The game is currently in progress, or loading.
          </Box>
        </>
      )}
    </Section>
  );
}

const ModSelector = (props) => {
  const { act, data } = useBackend<Data>();
  const { admin, host, mod_menu_open, modifiers = [] } = data;
  if (!mod_menu_open || !(host || admin)) {
    return null;
  }
  return (
    <Modal>
      <Button fluid color="bad" onClick={() => act('exit_mod_menu')}>
        Go Back
      </Button>
      {modifiers.map((mod, index) => {
        return (
          <Button.Checkbox
            key={index}
            mb={2}
            checked={mod.selected}
            tooltip={mod.desc}
            color={mod.selected ? 'green' : 'blue'}
            disabled={!mod.selected && !mod.selectable}
            onClick={() =>
              act('toggle_modifier', {
                modpath: mod.modpath,
              })
            }
          >
            {mod.name}
          </Button.Checkbox>
        );
      })}
    </Modal>
  );
};

import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

type Player = Record<string, PlayerInfo>;

type PlayerInfo = {
  host: number;
  ready: BooleanLike;
};

type Modifier = {
  desc: string;
  modpath: string;
  name: string;
  player_selectable: BooleanLike;
  player_selected: BooleanLike;
  selectable: BooleanLike;
  selected: BooleanLike;
};

type Map = {
  desc: string;
  max_players: number;
  min_players: number;
  name: string;
  time: number;
};

type Data = {
  active_mods: string;
  admin: BooleanLike;
  host: BooleanLike;
  loadoutdesc: string;
  loadouts: string[];
  map: Map;
  maps: string[];
  mod_menu_open: BooleanLike;
  modifiers: Modifier[];
  observers: Player[];
  players: Player[];
  playing: BooleanLike;
  self: string;
};

export function DeathmatchLobby(props) {
  const { act, data } = useBackend<Data>();
  const { admin, observers = [], self, players } = data;

  const allReady = Object.keys(players).every(
    (player) => players[player].ready,
  );

  return (
    <Window title="Deathmatch Lobby" width={560} height={480}>
      <ModSelector />
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow={4}>
                <PlayerColumn />
              </Stack.Item>
              <Stack.Item grow={3}>
                <HostControls />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack fill>
                <Stack.Item grow>
                  {!!admin && (
                    <Button
                      icon="exclamation"
                      color="caution"
                      onClick={() => act('admin', { func: 'Force start' })}
                    >
                      Force Start
                    </Button>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Button color="caution" onClick={() => act('observe')}>
                    {observers[self] ? 'Join' : 'Observe'}
                  </Button>
                  <Button color="bad" onClick={() => act('leave_game')}>
                    Leave Game
                  </Button>
                  <Button
                    color="good"
                    disabled={!allReady}
                    onClick={() => act('start_game')}
                  >
                    Start Game
                  </Button>
                </Stack.Item>
              </Stack>
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
    admin,
    host,
    loadouts = [],
    observers = [],
    players = [],
    self,
  } = data;

  const allReady = Object.keys(players).every(
    (player) => players[player].ready,
  );

  return (
    <Section fill scrollable={Object.keys(players).length > 30}>
      <Table>
        <Table.Row header>
          <Table.Cell collapsing />
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Loadout</Table.Cell>
          <Table.Cell collapsing align="center">
            <Tooltip
              content={!allReady ? 'Players are preparing' : 'Press start!'}
            >
              <Icon
                name={!allReady ? 'check' : 'check-circle'}
                color={allReady && 'green'}
              />
            </Tooltip>
          </Table.Cell>
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
                  disabled={!host && player !== self}
                  options={loadouts}
                  onSelected={(value) =>
                    act('change_loadout', {
                      player: player,
                      loadout: value,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell align="right" verticalAlign="top" pt="2px">
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
          const fullAccess = (!!host && !!players[observer].host) || admin;

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
    <Section fill scrollable>
      {!host ? (
        <NoticeBox danger>{map.name}</NoticeBox>
      ) : (
        <Dropdown
          color="average"
          width="100%"
          selected={map.name}
          options={maps}
          onSelected={(value) =>
            act('host', {
              func: 'change_map',
              map: value,
            })
          }
        />
      )}
      <Divider />
      {map.desc}
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Max Play Time">
          {`${map.time / 600}min`}
        </LabeledList.Item>
        <LabeledList.Item label="Min Players">
          {map.min_players}
        </LabeledList.Item>
        <LabeledList.Item label="Max Players">
          {map.max_players}
        </LabeledList.Item>
        <LabeledList.Item label="Current Players">
          {Object.keys(players).length}
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Box textAlign="center" color="average">
        {active_mods}
      </Box>
      {(!!admin || !!host) && (
        <>
          <Divider />
          <Button textAlign="center" fluid onClick={() => act('open_mod_menu')}>
            Toggle Modifiers
          </Button>
        </>
      )}
      <Divider />
      <NoticeBox info align="center">
        Loadout Description
      </NoticeBox>

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

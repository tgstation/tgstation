import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Flex,
  Icon,
  Modal,
  Section,
  Table,
} from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

type PlayerLike = {
  [key: string]: {
    host: number;
    ready: BooleanLike;
  };
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
  global_chat: BooleanLike;
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
  players: PlayerLike[];
  observers: PlayerLike[];
};

export const DeathmatchLobby = (props) => {
  const { act, data } = useBackend<Data>();
  const { modifiers = [] } = data;
  return (
    <Window title="Deathmatch Lobby" width={560} height={480}>
      <ModSelector />
      <Window.Content>
        <Flex height="94%">
          <Flex.Item width="63%">
            <Section fill scrollable>
              <Table>
                <Table.Row>
                  <Table.Cell collapsing />
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell grow>Loadout</Table.Cell>
                  <Table.Cell collapsing>Ready</Table.Cell>
                </Table.Row>
                {Object.keys(data.players).map((player) => (
                  <Table.Row className="candystripe" key={player}>
                    <Table.Cell collapsing>
                      {!!data.players[player].host && <Icon name="star" />}
                    </Table.Cell>
                    <Table.Cell>
                      {(!(
                        (data.host && !data.players[player].host) ||
                        data.admin
                      ) && <b>{player}</b>) || (
                        <Dropdown
                          displayText={player}
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
                    <Table.Cell grow>
                      <Dropdown
                        displayText={data.players[player].loadout}
                        disabled={!(data.host || player === data.self)}
                        options={data.loadouts}
                        onSelected={(value) =>
                          act('change_loadout', {
                            player: player,
                            loadout: value,
                          })
                        }
                      />
                    </Table.Cell>
                    <Table.Cell collapsing>
                      <ButtonCheckbox
                        disabled={player !== data.self}
                        checked={data.players[player].ready}
                        onClick={() => act('ready')}
                      />
                    </Table.Cell>
                  </Table.Row>
                ))}
                {Object.keys(data.observers).map((observer) => (
                  <Table.Row key={observer}>
                    <Table.Cell collapsing>
                      {(!!data.observers[observer].host && (
                        <Icon name="star" />
                      )) || <Icon name="eye" />}
                    </Table.Cell>
                    <Table.Cell>
                      {(!(
                        (data.host && !data.observers[observer].host) ||
                        data.admin
                      ) && <b>{observer}</b>) || (
                        <Dropdown
                          displayText={observer}
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
                    <Table.Cell grow>Observing</Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Flex.Item>
          <Flex.Item width="210px">
            <Section>
              <Box textAlign="center">
                {(!!data.host && (
                  <Dropdown
                    displayText={data.map.name}
                    options={data.maps}
                    onSelected={(value) =>
                      act('host', {
                        func: 'change_map',
                        map: value,
                      })
                    }
                  />
                )) || <b>{data.map.name}</b>}
              </Box>
              <Divider />
              {data.map.desc}
              <Divider />
              <Box textAlign="center">
                Maximum Play Time: <b>{`${data.map.time / 600}min`}</b>
                <br />
                Min players: <b>{data.map.min_players}</b>
                <br />
                Max players: <b>{data.map.max_players}</b>
                <br />
                Current players: <b>{Object.keys(data.players).length}</b>
              </Box>
              <Button.Checkbox
                checked={data.global_chat}
                disabled={!(data.host || data.admin)}
                content="Heightened Hearing"
                tooltip="Players can hear ghosts and hear through walls."
                onClick={() =>
                  act('host', {
                    func: 'global_chat',
                  })
                }
              />
              <Divider />
              <Box textAlign="center">{data.active_mods}</Box>
              {(!!data.admin || !!data.host) && (
                <>
                  <Divider />
                  <Button
                    textAlign="center"
                    fluid
                    content="Toggle Modifiers"
                    onClick={() => act('open_mod_menu')}
                  />
                </>
              )}
              <Divider />
              <Box textAlign="center">Loadout Description</Box>
              <Divider />
              <Box textAlign="center">{data.loadoutdesc}</Box>
              {!!data.playing && (
                <>
                  <Divider />
                  <Box textAlign="center">
                    The game is currently in progress, or loading.
                  </Box>
                </>
              )}
            </Section>
          </Flex.Item>
        </Flex>
        <Button
          color="good"
          content="Start Game"
          onClick={() => act('start_game')}
        />
        <Button
          color="bad"
          content="Leave Game"
          onClick={() => act('leave_game')}
        />
        <Button
          color="caution"
          content={data.observers[data.self] ? 'Join' : 'Observe'}
          onClick={() => act('observe')}
        />
        {!!data.admin && (
          <Button
            icon="exclamation"
            color="caution"
            content="Force Start"
            onClick={() => act('admin', { func: 'Force start' })}
          />
        )}
      </Window.Content>
    </Window>
  );
};

const ModSelector = (props) => {
  const { act, data } = useBackend<Data>();
  const { admin, host, mod_menu_open, modifiers = [] } = data;
  if (!mod_menu_open || !host || !admin) {
    return null;
  }
  return (
    <Modal>
      <Button
        fluid
        content="Go Back"
        color="bad"
        onClick={() => act('exit_mod_menu')}
      />
      {modifiers.map((mod, index) => {
        return (
          <Button.Checkbox
            key={index}
            mb={2}
            checked={mod.selected}
            content={mod.name}
            tooltip={mod.desc}
            color={mod.selected ? 'green' : 'blue'}
            disabled={!mod.selected && !mod.selectable}
            onClick={() =>
              act('toggle_modifier', {
                modpath: mod.modpath,
              })
            }
          />
        );
      })}
    </Modal>
  );
};

import { useBackend } from '../backend';
import { map } from 'common/collections';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Flex,
  Icon,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';
import { ButtonCheckbox } from '../components/Button';

type Data = {
  global_chat: boolean;
};

export const DeathmatchLobby = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window title="Deathmatch Lobby" width={560} height={400}>
      <Window.Content>
        <Flex height="94%">
          <Flex.Item width="350px">
            <Section height="99%">
              <Table>
                <Table.Row>
                  <Table.Cell collapsing />
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell grow>Loadout</Table.Cell>
                  <Table.Cell collapsing>Ready</Table.Cell>
                </Table.Row>
                {map((pdata, player) => (
                  <Table.Row className="candystripe">
                    <Table.Cell collapsing>
                      {!!pdata.host && <Icon name="star" />}
                    </Table.Cell>
                    <Table.Cell>
                      {(!((data.host && !pdata.host) || data.admin) && (
                        <b>{player}</b>
                      )) || (
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
                        displayText={pdata.loadout}
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
                        checked={pdata.ready}
                        onClick={() => act('ready')}
                      />
                    </Table.Cell>
                  </Table.Row>
                ))(data.players)}
                {map((odata, observer) => (
                  <Table.Row>
                    <Table.Cell collapsing>
                      {(!!odata.host && <Icon name="star" />) || (
                        <Icon name="eye" />
                      )}
                    </Table.Cell>
                    <Table.Cell collapsing>
                      {(!((data.host && !odata.host) || data.admin) && (
                        <b>{observer}</b>
                      )) || (
                        <Dropdown
                          sameline
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
                ))(data.observers)}
              </Table>
            </Section>
          </Flex.Item>
          <Flex.Item width="210px">
            <Section>
              <Box textAlign="center">
                {(!!data.host && (
                  <Dropdown
                    fluid
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
              <Box textAlign="center">Loadout Description</Box>
              <Divider />
              <Box textAlign="center">{data.loadoutdesc}</Box>
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

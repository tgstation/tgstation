import { useBackend } from '../backend';
import { Flex, Button, LabeledList, Section, Box, Table, TimeDisplay } from '../components';
import { Fragment } from 'inferno';
import { Window } from '../layouts';
import { FlexItem } from '../components/Flex';

export const MafiaPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    players,
    actions,
    phase,
    roleinfo,
    admin_controls,
    judgement_phase,
    timeleft,
    all_roles } = data;
  return (
    <Window resizable>
      <Window.Content>
        <Section title={phase}>
          {!!roleinfo && (
            <Table>
              <Table.Row>
                <Table.Cell>
                  <TimeDisplay auto="down" value={timeleft} />
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell bold>
                  You are a {roleinfo.role}
                </Table.Cell>
              </Table.Row>
              <Table.Row bold>
                <Table.Cell>
                  {roleinfo.desc}
                </Table.Cell>
              </Table.Row>
            </Table>
          )}
        </Section>
        <Flex>
          {!!actions && actions.map(action => {
            return (
              <Flex.Item key={action}>
                <Button
                  onClick={() => act("mf_action", { atype: action })}>
                  {action}
                </Button>
              </Flex.Item>);
          })}
        </Flex>
        {!!admin_controls && (
          <Section
            title="ADMIN CONTROLS"
            backgroundColor="red">
            THESE ARE DEBUG, THEY WILL BREAK THE GAME, DO NOT TOUCH <br />
            <Button
              onClick={() => act("next_phase")}>Next Phase
            </Button>
            <Button
              onClick={() => act("new_game")}>New Game
            </Button>
          </Section>
        )}
        <Section title="Players">
          <LabeledList>
            {!!players && players.map(player => { return (
              <LabeledList.Item
                className="candystripe"
                key={player.ref}
                label={player.name}>
                {!player.alive && (<Box color="red">DEAD</Box>)}
                {player.votes !== undefined && player.alive
                && (<Fragment>Votes : {player.votes} </Fragment>)}
                {
                  !!player.actions && player.actions.map(action => {
                    return (
                      <Button
                        key={action}
                        onClick={
                        // eslint-disable-next-line indent
      () => act("mf_targ_action", { atype: action, target: player.ref })
                        }>
                        {action}
                      </Button>); })
                }
              </LabeledList.Item>);
            })}
          </LabeledList>
        </Section>
        {!!judgement_phase && (
          <Section title="JUDGEMENT">
            <Flex justify="space-around">
              <Button
                icon="smile-beam"
                color="green"
                onClick={() => act("vote_innocent")}>INNOCENT!
              </Button>
              Use these buttons to vote the accused innocent or guilty!
              <Button
                icon="angry"
                color="red"
                onClick={() => act("vote_guilty")}>GUILTY!
              </Button>
            </Flex>
          </Section>
        )}
        <Flex mt={1}>
          <Flex.Item grow={1} basis={0}>
            <Section
              title="Roles">
              <Table>
                {!!all_roles && all_roles.map(r => (
                  <Table.Row key={r}>
                    <Table.Cell bold>
                      <Flex justify="space-between">
                        {r}
                        <Button
                          content="?"
                          onClick={() => act("mf_lookup", { atype: r })}
                        />
                      </Flex>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Flex.Item>
          <Flex.Item grow={2} basis={0}>
            <Section
              title="Notes">
              <Table>
                {!!roleinfo.action_log && roleinfo.action_log.map(log_line => (
                  <Table.Row key={log_line}>
                    <Table.Cell>
                      {log_line}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Flex.Item>
        </Flex>

      </Window.Content>
    </Window>
  );
};

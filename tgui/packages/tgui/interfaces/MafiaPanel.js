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
    role_info,
    admin_controls,
    judgement_phase,
    timeleft,
    all_roles } = data;
  return (
    <Window resizable>
      <Window.Content>
        <Section title={phase}>
          {!!role_info && (
            <Table>
              <Table.Row>
                <Table.Cell>
                  <TimeDisplay auto="down" value={timeleft} />
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell bold>
                  You are a {role_info.role}
                </Table.Cell>
              </Table.Row>
              <Table.Row bold>
                <Table.Cell>
                  {role_info.desc}
                </Table.Cell>
              </Table.Row>
              {!!role_info.action_log && role_info.action_log.map(log_line => (
                <Table.Row key={log_line}>
                  <Table.Cell>
                    {role_info.action_log}
                  </Table.Cell>
                </Table.Row>
              ))}
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
          <Section title="ADMIN CONTROLS">
            DO NOT USE THESE IF YOU ARE PLAYING, ADMIN
            <Flex.Item>
              <Button
                onClick={() => act("next_phase")}>Next Phase
              </Button>
            </Flex.Item>
            <FlexItem>
              <Button
                onClick={() => act("new_game")}>New Game
              </Button>
            </FlexItem>
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
            Use these buttons to vote the accused innocent or guilty!
            <Fragment>
              <Flex.Item>
                <Button
                  onClick={() => act("vote_innocent")}>INNOCENT!
                </Button>
              </Flex.Item>
              <FlexItem>
                <Button
                  onClick={() => act("vote_guilty")}>GUILTY!
                </Button>
              </FlexItem>
            </Fragment>
          </Section>
        )}
        <Section title="Roles">
          <Table>
            {!!all_roles && all_roles.map(r => (
              <Table.Row key={r}>
                <Table.Cell bold>
                  {r}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

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
          { !!admin_controls && (
            <Fragment>
              <Flex.Item>
                <Button onClick={() => act("next_phase")}>Next Phase</Button>
              </Flex.Item>
              <FlexItem>
                <Button onClick={() => act("new_game")}>New Game</Button>
              </FlexItem>
            </Fragment>)}
        </Flex>
        <Section title="Players">
          <LabeledList>
            {!!players && players.map(player => { return (
              <LabeledList.Item
                className="candystripe"
                key={player.ref}
                label={player.name}>
                {player.votes !== undefined
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

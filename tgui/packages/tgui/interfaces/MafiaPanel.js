import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, Section, TimeDisplay } from '../components';
import { Window } from '../layouts';

export const MafiaPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    players,
    actions,
    phase,
    roleinfo,
    role_theme,
    admin_controls,
    judgement_phase,
    timeleft,
    all_roles,
  } = data;
  return (
    <Window
      title="Mafia"
      theme={role_theme}
      width={650}
      height={550}
      resizable>
      <Window.Content>
        <Section title={phase}>
          {!!roleinfo && (
            <Fragment>
              <Box>
                <TimeDisplay auto="down" value={timeleft} />
              </Box>
              <Box>
                <b>You are a {roleinfo.role}</b>
              </Box>
              <Box>
                <b>{roleinfo.desc}</b>
              </Box>
            </Fragment>
          )}
        </Section>
        <Flex>
          {!!actions && actions.map(action => (
            <Flex.Item key={action}>
              <Button
                onClick={() => act("mf_action", { atype: action })}>
                {action}
              </Button>
            </Flex.Item>
          ))}
        </Flex>
        {!!admin_controls && (
          <Section
            title="ADMIN CONTROLS"
            backgroundColor="red">
            THESE ARE DEBUG, THEY WILL BREAK THE GAME, DO NOT TOUCH <br />
            Also because an admin did it: do not gib/delete/etc
            anyone! It will runtime the game to death! <br />
            <Button
              icon="arrow-right"
              onClick={() => act("next_phase")}>
              Next Phase
            </Button>
            <Button
              icon="home"
              onClick={() => act("players_home")}>
              Send All Players Home
            </Button>
            <Button
              icon="radiation"
              onClick={() => act("new_game")}>
              New Game
            </Button>
            <br />
            <Button
              icon="skull"
              onClick={() => act("nuke")}
              color="black">
              Nuke (delete datum + landmarks, hope it fixes everything!)
            </Button>
          </Section>
        )}
        <Section title="Players">
          <LabeledList>
            {!!players && players.map(player => (
              <LabeledList.Item
                className="candystripe"
                key={player.ref}
                label={player.name}>
                {!player.alive && (<Box color="red">DEAD</Box>)}
                {player.votes !== undefined && !!player.alive
                && (<Fragment>Votes : {player.votes} </Fragment>)}
                {
                  !!player.actions && player.actions.map(action => {
                    return (
                      <Button
                        key={action}
                        onClick={() => act('mf_targ_action', {
                          atype: action,
                          target: player.ref,
                        })}>
                        {action}
                      </Button>); })
                }
              </LabeledList.Item>)
            )}
          </LabeledList>
        </Section>
        {!!judgement_phase && (
          <Section title="JUDGEMENT">
            <Flex justify="space-around">
              <Button
                icon="smile-beam"
                color="good"
                onClick={() => act("vote_innocent")}>
                INNOCENT!
              </Button>
              Use these buttons to vote the accused innocent or guilty!
              <Button
                icon="angry"
                color="bad"
                onClick={() => act("vote_guilty")}>
                GUILTY!
              </Button>
            </Flex>
          </Section>
        )}
        <Flex mt={1} spacing={1}>
          <Flex.Item grow={1} basis={0}>
            <Section
              title="Roles"
              minHeight={10}>
              {!!all_roles && all_roles.map(r => (
                <Box key={r}>
                  <Flex justify="space-between">
                    {r}
                    <Button
                      content="?"
                      onClick={() => act("mf_lookup", {
                        atype: r.slice(0, -3),
                      })}
                    />
                  </Flex>
                </Box>
              ))}
            </Section>
          </Flex.Item>
          <Flex.Item grow={2} basis={0}>
            <Section
              title="Notes"
              minHeight={10}>
              {roleinfo !== undefined && !!roleinfo.action_log
              && roleinfo.action_log.map(log_line => (
                <Box key={log_line}>
                  {log_line}
                </Box>
              ))}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

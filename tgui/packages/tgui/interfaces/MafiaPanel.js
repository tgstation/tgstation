import { classes } from 'common/react';
import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, Flex, NoticeBox, Section, Stack, TimeDisplay } from '../components';
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
      height={600}
      resizable>
      <Window.Content>
        <Stack fill vertical>
          {!roleinfo && (
            <Stack.Item grow>
              <MafiaLobby />
            </Stack.Item>
          )}
          {!!roleinfo && (
            <Stack.Item>
              <MafiaRole />
            </Stack.Item>
          )}
          {!!actions && actions.map(action => (
            <Stack.Item key={action}>
              <Button
                onClick={() => act('mf_action', {
                  atype: action,
                })}>
                {action}
              </Button>
            </Stack.Item>
          ))}
          {!!roleinfo && (
            <Stack.Item>
              <MafiaJudgement />
            </Stack.Item>
          )}
          {phase !== 'No Game' && (
            <>
              <Stack.Item>
                <MafiaPlayers />
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill vertical>
                  <Stack.Item>
                    <MafiaListOfRoles />
                  </Stack.Item>
                  {!!roleinfo && (
                    <Stack.Item grow>
                      <Section fill scrollable>
                        {roleinfo?.action_log?.map(line => (
                          <Box key={line}>{line}</Box>
                        ))}
                      </Section>
                    </Stack.Item>
                  )}
                </Stack>
              </Stack.Item>
            </>
          )}
          {!!admin_controls && (
            <Stack.Item>
              <MafiaAdmin />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MafiaLobby = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lobbydata,
    phase,
    timeleft,
  } = data;
  const readyGhosts = lobbydata ? lobbydata.filter(
    player => player.status === "Ready") : null;
  return (
    <Section
      fill
      scrollable
      title="Lobby"
      buttons={(
        <>
          Phase = {phase}
          {' | '}
          <TimeDisplay auto="down" value={timeleft} />
          {' '}
          <Button
            icon="clipboard-check"
            tooltipPosition="bottom-left"
            tooltip={multiline`
              Signs you up for the next game. If there
              is an ongoing one, you will be signed up
              for the next.
            `}
            content="Sign Up"
            onClick={() => act('mf_signup')} />
          <Button
            icon="eye"
            tooltipPosition="bottom-left"
            tooltip={multiline`
              Spectates games until you turn it off.
              Automatically enabled when you die in game,
              because I assumed you would want to see the
              conclusion. You won't get messages if you
              rejoin SS13.
            `}
            content="Spectate"
            onClick={() => act('mf_spectate')} />
        </>
      )}>
      <NoticeBox info>
        The lobby currently has {readyGhosts.length + '/12'} valid
        players signed up.
      </NoticeBox>
      {lobbydata?.map(lobbyist => (
        <Stack
          key={lobbyist}
          className="candystripe"
          align="baseline">
          <Stack.Item grow>
            {lobbyist.name}
          </Stack.Item>
          <Stack.Item>
            Status:
          </Stack.Item>
          <Stack.Item
            color={lobbyist.status === 'Ready' ? 'green' : 'red'}>
            {lobbyist.status} {lobbyist.spectating}
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};

const MafiaRole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    phase,
    roleinfo,
    timeleft,
  } = data;
  return (
    <Section
      title={phase}
      minHeight="100px"
      maxHeight="50px"
      buttons={
        <TimeDisplay auto="down" value={timeleft} />
      }>
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>
            You are the {roleinfo.role}
          </Box>
          <Box italic>
            {roleinfo.desc}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box
            className={classes([
              'mafia32x32',
              roleinfo.revealed_icon,
            ])}
            style={{
              'transform': 'scale(2) translate(0px, 10%)',
              'vertical-align': 'middle',
            }} />
          <Box
            className={classes([
              'mafia32x32',
              roleinfo.hud_icon,
            ])}
            style={{
              'transform': 'scale(2) translate(-5px, -5px)',
              'vertical-align': 'middle',
            }} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MafiaListOfRoles = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    all_roles,
  } = data;
  return (
    <Section
      title="Roles and Notes"
      buttons={
        <>
          <Button
            color="transparent"
            icon="address-book"
            tooltipPosition="bottom-left"
            tooltip={multiline`
              The top section is the roles in the game. You can
              press the question mark to get a quick blurb
              about the role itself.`}
          />
          <Button
            color="transparent"
            icon="edit"
            tooltipPosition="bottom-left"
            tooltip={multiline`
              The bottom section are your notes. on some roles this
              will just be an empty box, but on others it records the
              actions of your abilities (so for example, your
              detective work revealing a changeling).`}
          />
        </>
      }>
      <Flex
        direction="column">
        {all_roles?.map(r => (
          <Flex.Item
            key={r}
            height="30px"
            className="Section__title candystripe">
            <Flex
              height="18px"
              align="center"
              justify="space-between">
              <Flex.Item>
                {r}
              </Flex.Item>
              <Flex.Item
                textAlign="right">
                <Button
                  color="transparent"
                  icon="question"
                  onClick={() => act('mf_lookup', {
                    atype: r.slice(0, -3),
                  })}
                />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const MafiaJudgement = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    judgement_phase,
  } = data;
  return (
    <Section
      title="Judgement"
      buttons={
        <Button
          color="transparent"
          icon="info"
          tooltipPosition="left"
          tooltip={multiline`
            When someone is on trial, you are in charge of their fate.
            Innocent winning means the person on trial can live to see
            another day... and in losing they do not. You can go back
            to abstaining with the middle button if you reconsider.
          `}
        />
      }>
      <Flex justify="space-around">
        <Button
          icon="smile-beam"
          content="INNOCENT!"
          color="good"
          disabled={!judgement_phase}
          onClick={() => act('vote_innocent')} />
        {!judgement_phase && (
          <Box>
            There is nobody on trial at the moment.
          </Box>
        )}
        {!!judgement_phase && (
          <Box>
            It is now time to vote, vote the accused innocent or guilty!
          </Box>
        )}
        <Button
          icon="angry"
          color="bad"
          disabled={!judgement_phase}
          onClick={() => act('vote_guilty')}>
          GUILTY!
        </Button>
      </Flex>
      <Flex justify="center">
        <Button
          icon="meh"
          color="white"
          disabled={!judgement_phase}
          onClick={() => act('vote_abstain')}>
          Abstain
        </Button>
      </Flex>
    </Section>
  );
};

const MafiaPlayers = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    players,
  } = data;
  return (
    <Section title="Players">
      <Flex direction="column">
        {!!players && players.map(player => (
          <Flex.Item
            height="30px"
            className="Section__title candystripe"
            key={player.ref}>
            <Flex
              height="18px"
              justify="space-between"
              align="center">
              <Flex.Item basis={16}>
                {!!player.alive && (
                  <Box>{player.name}</Box>
                )}
                {!player.alive && (
                  <Box color="red">{player.name}</Box>
                )}
              </Flex.Item>
              <Flex.Item>
                {!player.alive && (
                  <Box color="red">DEAD</Box>
                )}
              </Flex.Item>
              <Flex.Item>
                {player.votes !== undefined
                  && !!player.alive
                  && `Votes: ${player.votes}`}
              </Flex.Item>
              <Flex.Item grow={1} />
              <Flex.Item>
                {player.actions?.map(action => (
                  <Button
                    key={action}
                    onClick={() => act('mf_targ_action', {
                      atype: action,
                      target: player.ref,
                    })}>
                    {action}
                  </Button>
                ))}
              </Flex.Item>
            </Flex>
          </Flex.Item>)
        )}
      </Flex>
    </Section>
  );
};

const MafiaAdmin = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Collapsible
      title="ADMIN CONTROLS"
      color="red">
      <Section>
        <Collapsible
          title="A kind, coder warning"
          color="transparent">
          Almost all of these are all built to help me debug
          the game (ow, debugging a 12 player game!) So they are
          rudamentary and prone to breaking at the drop of a hat.
          Make sure you know what you&apos;re doing when you press one.
          Also because an admin did it: do not gib/delete/dust
          anyone! It will runtime the game to death
        </Collapsible>
        <Button
          icon="arrow-right"
          onClick={() => act('next_phase')}>
          Next Phase
        </Button>
        <Button
          icon="home"
          onClick={() => act('players_home')}>
          Send All Players Home
        </Button>
        <Button
          icon="sync-alt"
          onClick={() => act('new_game')}>
          New Game
        </Button>
        <Button
          icon="skull"
          onClick={() => act('nuke')}>
          Nuke
        </Button>
        <br />
        <Button
          icon="paint-brush"
          onClick={() => act('debug_setup')}>
          Create Custom Setup
        </Button>
        <Button
          icon="paint-roller"
          onClick={() => act('cancel_setup')}>
          Reset Custom Setup
        </Button>
      </Section>
    </Collapsible>
  );
};

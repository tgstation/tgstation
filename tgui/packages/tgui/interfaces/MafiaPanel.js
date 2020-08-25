import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, Flex, NoticeBox, Section, TimeDisplay, Tooltip } from '../components';
import { Window } from '../layouts';

export const MafiaPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lobbydata,
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
  const playerAddedHeight = roleinfo ? players.length * 30 : 7;
  const readyGhosts = lobbydata ? lobbydata.filter(
    player => player.status === "Ready") : null;
  return (
    <Window
      title="Mafia"
      theme={role_theme}
      width={650} // 414 or 415 / 444 or 445
      height={293 + playerAddedHeight}>
      <Window.Content scrollable={admin_controls}>
        {!roleinfo && (
          <Flex scrollable
            overflowY="scroll"
            direction="column"
            height="100%"
            grow={1}>
            <Section
              title="Lobby"
              mb={1}
              buttons={
                <LobbyDisplay
                  phase={phase}
                  timeleft={timeleft}
                  admin_controls={admin_controls} />
              }>
              <Box textAlign="center">
                <NoticeBox info>
                  The lobby currently has {readyGhosts.length}
                  /12 valid players signed up.
                </NoticeBox>
                <Flex
                  direction="column">
                  {!!lobbydata && lobbydata.map(lobbyist => (
                    <Flex.Item
                      key={lobbyist}
                      basis={2}
                      className="Section__title candystripe">
                      <Flex
                        height={2}
                        align="center"
                        justify="space-between">
                        <Flex.Item basis={0}>
                          {lobbyist.name}
                        </Flex.Item>
                        <Flex.Item>
                          STATUS:
                        </Flex.Item>
                        <Flex.Item width="30%">
                          <Section>
                            <Box
                              color={
                                lobbyist.status === "Ready" ? "green" : "red"
                              }
                              textAlign="center">
                              {lobbyist.status} {lobbyist.spectating}
                            </Box>
                          </Section>
                        </Flex.Item>
                      </Flex>
                    </Flex.Item>
                  ))}
                </Flex>
              </Box>
            </Section>
          </Flex>
        )}
        {!!roleinfo && (
          <Section
            title={phase}
            minHeight="100px"
            maxHeight="50px"
            buttons={
              <Box>
                {!!admin_controls && (
                  <Button
                    color="red"
                    icon="gavel"
                    tooltipPosition="bottom-left"
                    tooltip={multiline`
                    Hello admin! If it is the admin controls you seek,
                    please notice the extra scrollbar you have that players
                    do not!`}
                  />
                )} <TimeDisplay auto="down" value={timeleft} />
              </Box>
            }>
            <Flex
              justify="space-between">
              <Flex.Item
                align="center"
                textAlign="center"
                maxWidth="500px">
                <b>You are the {roleinfo.role}</b><br />
                <b>{roleinfo.desc}</b>
              </Flex.Item>
              <Flex.Item>
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
              </Flex.Item>
            </Flex>
          </Section>
        )}
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
        {!!roleinfo && (
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
                to abstaining with the middle button if you reconsider.`}
              />
            }>
            <Flex justify="space-around">
              <Button
                icon="smile-beam"
                content="INNOCENT!"
                color="good"
                disabled={!judgement_phase}
                onClick={() => act("vote_innocent")} />
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
                content="GUILTY!"
                color="bad"
                disabled={!judgement_phase}
                onClick={() => act("vote_guilty")} />
            </Flex>
            <Flex justify="center">
              <Button
                icon="meh"
                content="Abstain"
                color="white"
                disabled={!judgement_phase}
                onClick={() => act("vote_abstain")} />
            </Flex>
          </Section>
        )}
        {phase !== "No Game" &&(
          <Flex spacing={1}>
            <Flex.Item grow={2}>
              <Section title="Players"
                buttons={
                  <Button
                    color="transparent"
                    icon="info"
                    tooltip={multiline`
                    This is the list of all the players in
                    the game, during the day phase you may vote on them and,
                    depending on your role, select players
                    at certain phases to use your ability.`}
                  />
                }>
                <Flex
                  direction="column">
                  {!!players && players.map(player => (
                    <Flex.Item
                      height="30px"
                      className="Section__title candystripe"
                      key={player.ref}>
                      <Flex
                        height="18px"
                        justify="space-between"
                        align="center">
                        <Flex.Item basis={16} >
                          {!!player.alive && (<Box>{player.name}</Box>)}
                          {!player.alive && (
                            <Box color="red">{player.name}</Box>)}
                        </Flex.Item>
                        <Flex.Item>
                          {!player.alive && (<Box color="red">DEAD</Box>)}
                        </Flex.Item>
                        <Flex.Item>
                          {player.votes !== undefined && !!player.alive
                          && (<Fragment>Votes : {player.votes} </Fragment>)}
                        </Flex.Item>
                        <Flex.Item grow={1} />
                        <Flex.Item>
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
                        </Flex.Item>
                      </Flex>
                    </Flex.Item>)
                  )}
                </Flex>
              </Section>
            </Flex.Item>
            <Flex.Item grow={2}>
              <Flex
                direction="column"
                height="100%">
                <Section
                  title="Roles and Notes"
                  buttons={
                    <Fragment>
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
                    </Fragment>
                  }>
                  <Flex
                    direction="column">
                    {!!all_roles && all_roles.map(r => (
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
                              onClick={() => act("mf_lookup", {
                                atype: r.slice(0, -3),
                              })}
                            />
                          </Flex.Item>
                        </Flex>
                      </Flex.Item>
                    ))}
                  </Flex>
                </Section>
                {!!roleinfo && (
                  <Flex.Item height={0} grow={1}>
                    <Section scrollable
                      fill
                      overflowY="scroll">
                      {roleinfo !== undefined && !!roleinfo.action_log
                    && roleinfo.action_log.map(log_line => (
                      <Box key={log_line}>
                        {log_line}
                      </Box>
                    ))}
                    </Section>
                  </Flex.Item>
                )}
              </Flex>
            </Flex.Item>
          </Flex>
        )}
        <Flex mt={1} direction="column">
          <Flex.Item>
            {!!admin_controls && (
              <Section textAlign="center">
                <Collapsible
                  title="ADMIN CONTROLS"
                  color="red">
                  <Button
                    icon="exclamation-triangle"
                    color="black"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Almost all of these are all built to help me debug
                    the game (ow, debugging a 12 player game!) So they are
                    rudamentary and prone to breaking at the drop of a hat.
                    Make sure you know what you're doing when you press one.
                    Also because an admin did it: do not gib/delete/dust
                    anyone! It will runtime the game to death!`}
                    content="A Kind, Coder Warning"
                    onClick={() => act("next_phase")} /><br />
                  <Button
                    icon="arrow-right"
                    tooltipPosition="top"
                    tooltip={multiline`
                    This will advance the game to the next phase
                    (day talk > day voting, day voting > night/trial)
                    pretty fun to just spam this and freak people out,
                    try that roundend!`}
                    content="Next Phase"
                    onClick={() => act("next_phase")} />
                  <Button
                    icon="home"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Hopefully you won't use this button
                    often, it's a safety net just in case
                    mafia players somehow escape (nullspace
                    redirects to the error room then station)
                    Either way, VERY BAD IF THAT HAPPENS as
                    godmoded assistants will run free. Use
                    this to recollect them then make a bug report.`}
                    content="Send All Players Home"
                    onClick={() => act("players_home")} />
                  <Button
                    icon="sync-alt"
                    tooltipPosition="top"
                    tooltip={multiline`
                    This immediately ends the game, and attempts to start
                    another. Nothing will happen if another
                    game fails to start!`}
                    content="New Game"
                    onClick={() => act("new_game")} />
                  <Button
                    icon="skull"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Deletes the datum, clears all landmarks, makes mafia
                    as it was roundstart: nonexistant. Use this if you
                    really mess things up. You did mess things up, didn't you.`}
                    content="Nuke"
                    onClick={() => act("nuke")} />
                  <br />
                  <Button
                    icon="paint-brush"
                    tooltipPosition="top"
                    tooltip={multiline`
                    This is the custom game creator, it is... simple.
                    You put in roles and until you press CANCEL or FINISH
                    it will keep letting you add more roles. Assitants
                    on the bottom because of pathing stuff. Resets after
                    the round finishes back to 12 player random setups.`}
                    content="Create Custom Setup"
                    onClick={() => act("debug_setup")} />
                  <Button
                    icon="paint-roller"
                    tooltipPosition="top"
                    tooltip={multiline`
                    If you messed up and accidently didn't make it how
                    you wanted, simply just press this to reset it. The game
                    will auto reset after each game as well.`}
                    content="Reset Custom Setup"
                    onClick={() => act("cancel_setup")} />
                </Collapsible>
              </Section>
            )}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const LobbyDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    phase,
    timeleft,
    admin_controls,
  } = data;
  return (
    <Box>
      [Phase = {phase} | <TimeDisplay auto="down" value={timeleft} />]{' '}
      <Button
        icon="clipboard-check"
        tooltipPosition="bottom-left"
        tooltip={multiline`
        Signs you up for the next game. If there
        is an ongoing one, you will be signed up
        for the next.`}
        content="Sign Up"
        onClick={() => act("mf_signup")} />
      <Button
        icon="eye"
        tooltipPosition="bottom-left"
        tooltip={multiline`
        Spectates games until you turn it off.
        Automatically enabled when you die in game,
        because I assumed you would want to see the
        conclusion. You won't get messages if you
        rejoin SS13.`}
        content="Spectate"
        onClick={() => act("mf_spectate")} />
      {!!admin_controls && (
        <Button
          color="red"
          icon="gavel"
          tooltipPosition="bottom-left"
          tooltip={multiline`
          Hello admin! If it is the admin controls you seek,
          please notice the scrollbar you have that players
          do not!`}
        />
      )}
    </Box>
  );
};

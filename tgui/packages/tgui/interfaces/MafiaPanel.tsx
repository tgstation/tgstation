import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Flex,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  TextArea,
} from 'tgui-core/components';
import { formatTime } from 'tgui-core/format';
import { type BooleanLike, classes } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type RoleInfo = {
  role_theme: string;
  role: string;
  desc: string;
  hud_icon: string;
  revealed_icon: string;
  role_dead: string;
};

type PlayerInfo = {
  name: string;
  role_revealed: string;
  is_you: BooleanLike;
  ref: string;
  alive: string;
  possible_actions: ActionInfo[];
  votes: number;
};

type ActionInfo = {
  name: string;
  ref: string;
};

type LobbyData = {
  name: string;
  status: string;
};

type MessageData = {
  msg: string;
};

type MafiaData = {
  players: PlayerInfo[];
  lobbydata: LobbyData[];
  messages: MessageData[];
  user_notes: string;
  roleinfo: RoleInfo;
  phase: string;
  turn: number;
  timeleft: number;
  is_observer: boolean;
  all_roles: string[];
  admin_controls: boolean;
  person_voted_up_ref: string;
  player_voted_up: BooleanLike;
};

export const MafiaPanelData = (props) => {
  const { act, data } = useBackend<MafiaData>();
  const { phase, roleinfo, admin_controls, messages, player_voted_up } = data;
  const [mafia_tab, setMafiaMode] = useState('Role list');

  if (phase === 'No Game') {
    return (
      <Stack fill vertical>
        <MafiaLobby />
        {!!admin_controls && <MafiaAdmin />}
      </Stack>
    );
  }

  return (
    <Stack fill>
      {!!roleinfo && (
        <Stack.Item grow>
          <MafiaChat />
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Stack fill vertical>
          {!!roleinfo && (
            <>
              <Stack.Item>
                <MafiaRole />
              </Stack.Item>
              {phase === 'Judgment' && !player_voted_up && (
                <Stack.Item>
                  <MafiaJudgement />
                </Stack.Item>
              )}
            </>
          )}

          <Stack.Item>{!!admin_controls && <MafiaAdmin />}</Stack.Item>

          {phase !== 'No Game' && (
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  <MafiaPlayers />
                </Stack.Item>
                <Stack.Item grow>
                  <Stack.Item>
                    <Tabs fluid>
                      <Tabs.Tab
                        align="center"
                        selected={mafia_tab === 'Role list'}
                        onClick={() => setMafiaMode('Role list')}
                      >
                        Role list
                        <Button
                          color="transparent"
                          icon="address-book"
                          tooltipPosition="bottom-start"
                          tooltip={`
                            Это список ролей в игре.
                            Вы можетенажать на знак вопроса,
                            чтобы получить краткую информациюо самой роли.`}
                        />
                      </Tabs.Tab>
                      <Tabs.Tab
                        align="center"
                        selected={mafia_tab === 'Notes'}
                        onClick={() => setMafiaMode('Notes')}
                      >
                        Notes
                        <Button
                          color="transparent"
                          icon="pencil"
                          tooltipPosition="bottom-start"
                          tooltip={`
                            Это ваши заметки, все, что вы хотите написать
                            можно сохранить для дальнейшего использования. Вы можете
                            также отправить их в чат с помощью кнопки.`}
                        />
                      </Tabs.Tab>
                    </Tabs>
                  </Stack.Item>
                  {mafia_tab === 'Role list' && <MafiaListOfRoles />}
                  {mafia_tab === 'Notes' && <MafiaNotesTab />}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const MafiaPanel = (props) => {
  const { act, data } = useBackend<MafiaData>();
  const { roleinfo } = data;
  return (
    <Window title="Мафия" theme={roleinfo?.role_theme} width={900} height={600}>
      <Window.Content>
        <MafiaPanelData />
      </Window.Content>
    </Window>
  );
};

const MafiaChat = (props) => {
  const { act, data } = useBackend<MafiaData>();
  const { messages } = data;
  const [message_to_send, setMessagingBox] = useState('');
  return (
    <Stack vertical fill>
      {!!messages && (
        <>
          <Section fill scrollable title="Chat Logs">
            {messages.map((message) => (
              <Box key={message.msg}>{decodeHtmlEntities(message.msg)}</Box>
            ))}
          </Section>
          <TextArea
            fluid
            height="10%"
            maxLength={300}
            className="Section__title candystripe"
            onChange={setMessagingBox}
            placeholder="Type to chat"
            value={message_to_send}
          />
          <Button
            color="bad"
            fluid
            textAlign="center"
            tooltip="Отправляет ваше сообщение в чат."
            onClick={() => {
              setMessagingBox('');
              act('send_message_to_chat', { message: message_to_send });
            }}
          >
            Send to Chat
          </Button>
        </>
      )}
    </Stack>
  );
};

const MafiaLobby = (props) => {
  const { act, data } = useBackend<MafiaData>();
  const { lobbydata = [], is_observer } = data;
  const readyGhosts = lobbydata
    ? lobbydata.filter((player) => player.status === 'Ready')
    : null;
  return (
    <Section
      fill
      scrollable
      title="Лобби"
      buttons={
        <>
          <Button
            icon="clipboard-check"
            tooltipPosition="bottom-start"
            tooltip={`
            Записывает вас на следующую игру. Если
            игра продолжается, вы будете записаны
            на следующую.
            `}
            content="Присоеденится"
            onClick={() => act('mf_signup')}
          />
          <Button
            icon="arrow-right"
            tooltipPosition="bottom-start"
            tooltip={`
            Отправьте голос, чтобы начать игру раньше.
            Начинается, когда за начало проголосует половина из текущего списка участников.
            Требуется минимум шесть игроков.
            `}
            content="Начать сейчас!"
            onClick={() => act('vote_to_start')}
          />
        </>
      }
    >
      <NoticeBox info textAlign="center">
        В лобби сейчас {readyGhosts ? readyGhosts.length : '0'}/12
        Присоеденившихся игроков.
      </NoticeBox>
      {!!is_observer && (
        <NoticeBox color="green" textAlign="center">
          Игроки, которые присоединились к Мафии будучи мертвыми, будут
          возвращены в свои тела после окончания игры, что позволит вам временно
          выйти из игры, чтобы сыграть матч.
        </NoticeBox>
      )}
      {lobbydata.map((lobbyist) => (
        <Stack
          key={lobbyist.name}
          className="candystripe"
          p={1}
          align="baseline"
        >
          <Stack.Item grow>
            {!is_observer ? 'Unknown Player' : lobbyist.name}
          </Stack.Item>
          <Stack.Item>Status:</Stack.Item>
          <Stack.Item color={lobbyist.status === 'Ready' ? 'green' : 'red'}>
            {lobbyist.status}
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};

const MafiaRole = (props) => {
  const { act, data } = useBackend<MafiaData>();
  const { phase, turn, roleinfo, timeleft } = data;
  return (
    <Section
      fill
      title={phase + turn}
      minHeight="110px"
      maxHeight="50px"
      buttons={
        <Box
          lineHeight={1.5}
          fontFamily="Consolas, monospace"
          fontSize="14px"
          fontWeight="bold"
        >
          {formatTime(timeleft)}
        </Box>
      }
    >
      <Stack>
        <Stack.Item grow>
          <Box fontSize="16px">Вы {roleinfo.role}</Box>
          {!!roleinfo.role_dead && (
            <Box bold>
              Вы уже мертвы. Вы можете поговорить с Священником ночью, если он
              есть.
            </Box>
          )}
          {!roleinfo.role_dead && <Box italic>{roleinfo.desc}</Box>}
        </Stack.Item>
        <Stack.Item>
          <Box
            className={classes(['mafia32x32', roleinfo.revealed_icon])}
            style={{
              transform: 'scale(2) translate(0px, 10%)',
              verticalAlign: 'middle',
            }}
          />
          <Box
            className={classes(['mafia32x32', roleinfo.hud_icon])}
            style={{
              transform: 'scale(2) translate(-5px, -5px)',
              verticalAlign: 'middle',
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MafiaListOfRoles = (props) => {
  const { act, data } = useBackend<MafiaData>();
  const { all_roles } = data;
  return (
    <Section fill>
      <Flex direction="column">
        {all_roles?.map((r) => (
          <Flex.Item key={r} className="Section__title candystripe">
            <Flex align="center" justify="space-between">
              <Flex.Item>{r}</Flex.Item>
              <Flex.Item textAlign="right">
                <Button
                  color="transparent"
                  icon="question"
                  onClick={() =>
                    act('mf_lookup', {
                      role_name: r.slice(0, -3),
                    })
                  }
                />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const MafiaNotesTab = (props) => {
  const { act, data } = useBackend<MafiaData>();
  const { user_notes } = data;
  const [note_message, setNotesMessage] = useState(user_notes);
  return (
    <Section fill>
      <TextArea
        height="80%"
        maxLength={600}
        className="Section__title candystripe"
        onChange={setNotesMessage}
        placeholder="Вставить заметки..."
        value={note_message}
      />

      <Button
        color="good"
        fluid
        textAlign="center"
        onClick={() => act('change_notes', { new_notes: note_message })}
        tooltip="Сохраняет все написанное в блокноте. Этого нельзя сделать во время смерти."
      >
        Save
      </Button>
      <Button.Confirm
        color="bad"
        fluid
        content="Отправить в чат"
        textAlign="center"
        onClick={() => act('send_notes_to_chat')}
      />
    </Section>
  );
};

const MafiaJudgement = (props) => {
  const { act, data } = useBackend();
  return (
    <Section title="Приговор">
      <Flex>
        <Button
          icon="smile-beam"
          color="good"
          onClick={() => act('vote_innocent')}
        >
          Невинный
        </Button>
        <Box>
          Настало время проголосовать, голосуйте за невиновность или виновность
          обвиняемого!
        </Box>
        <Button icon="angry" color="bad" onClick={() => act('vote_guilty')}>
          Виновен
        </Button>
      </Flex>
      <Flex justify="center">
        <Button icon="meh" color="white" onClick={() => act('vote_abstain')}>
          Воздержался
        </Button>
      </Flex>
    </Section>
  );
};

const MafiaPlayers = (props) => {
  const { act, data } = useBackend<MafiaData>();
  const { players = [], person_voted_up_ref } = data;
  return (
    <Section fill scrollable title="Players">
      <Flex direction="column" fill justify="space-around">
        {players?.map((player) => (
          <Flex.Item className="Section__title candystripe" key={player.ref}>
            <Stack align="center">
              <Stack.Item
                grow
                color={!player.alive && 'red'}
                backgroundColor={
                  player.ref === person_voted_up_ref ? 'yellow' : null
                }
              >
                {player.name}
                {(!!player.is_you && ' (YOU)') ||
                  (!!player.role_revealed && ` - ${player.role_revealed}`)}
              </Stack.Item>
              <Stack.Item>
                {player.votes !== undefined &&
                  !!player.alive &&
                  `Голоса: ${player.votes}`}
              </Stack.Item>
              <Stack.Item minWidth="42px" textAlign="center">
                {player.possible_actions?.map((action) => (
                  <Button
                    key={action.name}
                    onClick={() =>
                      act('perform_action', {
                        action_ref: action.ref,
                        target: player.ref,
                      })
                    }
                  >
                    {action.name}
                  </Button>
                ))}
              </Stack.Item>
            </Stack>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const MafiaAdmin = (props) => {
  const { act, data } = useBackend();
  return (
    <Collapsible title="АДМИНСКИЙ КОНТРОЛЬ" color="red">
      <Section>
        <Collapsible title="Предупреждение от кодера" color="transparent">
          Почти все они созданы для того, чтобы помочь мне отладить игру. (вау,
          отладка игры для 12 игроков!) Поэтому они рудаментарны и склонны
          сломаться в любой момент. Убедитесь, что вы знаете, что делаете, когда
          нажимаете на кнопку. Также, поскольку это сделал администратор: не
          удаляйте никого! Это запустит игру до смерти.
        </Collapsible>
        <Button icon="arrow-right" onClick={() => act('next_phase')}>
          Следующая фаза
        </Button>
        <Button icon="home" onClick={() => act('players_home')}>
          Отправить всех игроков по домам
        </Button>
        <Button icon="sync-alt" onClick={() => act('new_game')}>
          Новая игра
        </Button>
        <Button icon="skull" onClick={() => act('nuke')}>
          Нюка
        </Button>
        <br />
        <Button icon="paint-brush" onClick={() => act('debug_setup')}>
          Создать пользовательскую настройку
        </Button>
        <Button icon="paint-roller" onClick={() => act('cancel_setup')}>
          Сброс пользовательских настроек
        </Button>
        <Button icon="magic" onClick={() => act('start_now')}>
          Начать сейчас!
        </Button>
      </Section>
    </Collapsible>
  );
};

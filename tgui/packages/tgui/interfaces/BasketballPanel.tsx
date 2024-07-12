import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type BasketballPanelData = {
  total_votes: number;
  players_min: number;
  players_max: number;
  lobbydata: {
    ckey: string;
    status: string;
  }[];
};

export const BasketballPanel = (props) => {
  const { act, data } = useBackend<BasketballPanelData>();

  return (
    <Window title="Basketball" width={650} height={580}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Lobby"
              buttons={
                <>
                  <Button
                    icon="clipboard-check"
                    tooltipPosition="bottom-start"
                    tooltip={`
                    Signs you up for the next game. If there
                    is an ongoing one, you will be signed up
                    for the next.
                  `}
                    content="Sign Up"
                    onClick={() => act('basketball_signup')}
                  />
                  <Button
                    icon="basketball"
                    disabled={data.total_votes < data.players_min}
                    onClick={() => act('basketball_start')}
                  >
                    Start
                  </Button>
                </>
              }
            >
              <NoticeBox info>
                The lobby has {data.total_votes} players signed up. The minigame
                is for {data.players_min} to {data.players_max} players.
              </NoticeBox>

              {data.lobbydata.map((lobbyist) => (
                <Stack
                  key={lobbyist.ckey}
                  className="candystripe"
                  p={1}
                  align="baseline"
                >
                  <Stack.Item grow>{lobbyist.ckey}</Stack.Item>
                  <Stack.Item>Status:</Stack.Item>
                  <Stack.Item
                    color={lobbyist.status === 'Ready' ? 'green' : 'red'}
                  >
                    {lobbyist.status}
                  </Stack.Item>
                </Stack>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item />
        </Stack>
      </Window.Content>
    </Window>
  );
};

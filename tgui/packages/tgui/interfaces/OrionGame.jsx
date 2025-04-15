import { Box, Button, Divider, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const buttonWidth = 2;

const goodstyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const partstyle = {
  color: 'yellow',
  fontWeight: 'bold',
};

const fuelstyle = {
  color: 'olive',
  fontWeight: 'bold',
};

const variousButtonIcons = {
  'Restore Hull': 'wrench',
  'Fix Engine': 'rocket',
  'Repair Electronics': 'server',
  Wait: 'clock',
  Continue: 'arrow-right',
  'Explore Ship': 'door-open',
  'Leave the Derelict': 'arrow-right',
  'Welcome aboard.': 'user-plus',
  'Where did you go?!': 'user-minus',
  'A good find.': 'box-open',
  'Continue travels.': 'arrow-right',
  'Keep Speed': 'tachometer-alt',
  'Slow Down': 'arrow-left',
  'Speed Past': 'tachometer-alt',
  'Go Around': 'redo',
  'Oh...': 'circle',
  Dock: 'dollar-sign',
};

const STATUS2COMPONENT = [
  { component: () => ORION_STATUS_START },
  { component: () => ORION_STATUS_INSTRUCTIONS },
  { component: () => ORION_STATUS_NORMAL },
  { component: () => ORION_STATUS_GAMEOVER },
  { component: () => ORION_STATUS_MARKET },
];

const locationInfo = [
  {
    title: 'Pluto',
    blurb:
      'Pluto, long since occupied with long-range sensors and scanners, stands ready to, and indeed continues to probe the far reaches of the galaxy.',
  },
  {
    title: 'Asteroid Belt',
    blurb:
      'At the edge of the Sol system lies a treacherous asteroid belt. Many have been crushed by stray asteroids and misguided judgement.',
  },
  {
    title: 'Proxima Centauri',
    blurb:
      'The nearest star system to Sol, in ages past it stood as a reminder of the boundaries of sub-light travel, now a low-population sanctuary for adventurers and traders.',
  },
  {
    title: 'Dead Space',
    blurb:
      'This region of space is particularly devoid of matter. Such low-density pockets are known to exist, but the vastness of it is astounding.',
  },
  {
    title: 'Rigel Prime',
    blurb:
      'Rigel Prime, the center of the Rigel system, burns hot, basking its planetary bodies in warmth and radiation.',
  },
  {
    title: 'Tau Ceti Beta',
    blurb:
      'Tau Ceti Beta has recently become a waypoint for colonists headed towards Orion. There are many ships and makeshift stations in the vicinity.',
  },
  {
    title: 'Space Bugs',
    blurb:
      "You see some space bugs out your window. They contort in various reality bending ways, and it makes you sick. You know it's Galactic Policy to report all sightings of space bugs.",
  },
  {
    title: 'Space Outpost Beta-9',
    blurb:
      "You have come into range of the first man-made structure in this region of space. It has been constructed not by travellers from Sol, but by colonists from Orion. It stands as a monument to the colonists' success.",
  },
  {
    title: 'Orion Prime',
    blurb:
      'You have made it to Orion! Congratulations! Your crew is one of the few to start a new foothold for mankind!',
  },
];

const AdventureStatus = (props) => {
  const { data, act } = useBackend();
  const {
    lings_suspected,
    eventname,
    settlers,
    settlermoods,
    hull,
    electronics,
    engine,
    food,
    fuel,
  } = data;
  return (
    <Section
      title="Adventure Status"
      fill
      buttons={
        !!lings_suspected && (
          <Button
            fluid
            color="black"
            textAlign="center"
            icon="skull"
            content="RANDOM KILL"
            disabled={eventname}
            onClick={() => act('random_kill')}
          />
        )
      }
    >
      <Stack fill g={0}>
        <Stack.Item grow>
          {settlers?.map((settler) => (
            <Stack key={settler} align="center">
              <Stack.Item grow>{settler}</Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  color="red"
                  textAlign="center"
                  icon="skull"
                  content="KILL"
                  disabled={lings_suspected || eventname}
                  onClick={() =>
                    act('target_kill', {
                      who: settler,
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item
                className={'moods32x32 mood' + (settlermoods[settler] + 1)}
              />
            </Stack>
          ))}
        </Stack.Item>
        <Divider vertical />
        <Stack.Item>
          <Stack vertical fill justify="center">
            <Stack.Item>
              <Button
                fluid
                icon="hamburger"
                content={'Food Left: ' + food}
                color="green"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon="gas-pump"
                content={'Fuel Left: ' + fuel}
                color="olive"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon="wrench"
                content={'Hull Parts: ' + hull}
                color="average"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon="server"
                content={'Electronics: ' + electronics}
                color="blue"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon="rocket"
                content={'Engine Parts: ' + engine}
                color="violet"
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ORION_STATUS_START = (props) => {
  const { data, act } = useBackend();
  const { gamename } = data;
  return (
    <Section fill>
      <Stack vertical textAlign="center" fill>
        <Stack.Item grow={1} />
        <Stack.Item fontSize="32px">{gamename}</Stack.Item>
        <Stack.Item grow fontSize="15px" color="label">
          {'"Experience the journey of your ancestors!"'}
        </Stack.Item>
        <Stack.Item fontSize="15px">
          <Button
            lineHeight={2}
            fluid
            icon="play"
            content="Begin Game"
            onClick={() => act('start_game')}
          />
        </Stack.Item>
        <Stack.Item fontSize="15px">
          <Button
            lineHeight={2}
            fluid
            icon="info"
            content="Instructions"
            onClick={() => act('instructions')}
          />
        </Stack.Item>
        <Stack.Item grow={3} />
      </Stack>
    </Section>
  );
};

const ORION_STATUS_INSTRUCTIONS = (props) => {
  const { act } = useBackend();
  const fake_settlers = ['John', 'William', 'Alice', 'Tom'];
  return (
    <>
      <Section
        color="label"
        title="Objective"
        buttons={
          <Button
            content="Back to Main Menu"
            onClick={() => act('back_to_menu')}
          />
        }
      >
        <Box fontSize="11px">
          In the 2200&apos;s, the Orion trail was established as a dangerous yet
          opportunistic trail through space for those willing to risk it. Many
          pioneers seeking new lives on the galactic frontier would find exactly
          what they were seeking... or lose their lives on the way.
        </Box>
      </Section>
      <Section title="Status Example">
        <Stack>
          <Stack.Item basis={70} grow align="center">
            {fake_settlers?.map((settler) => (
              <Stack key={settler} align="center">
                <Stack.Item grow>{settler}</Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    color="red"
                    textAlign="center"
                    icon="skull"
                    content="KILL"
                  />
                </Stack.Item>
                <Stack.Item className={'moods32x32 mood5'} />
              </Stack>
            ))}
          </Stack.Item>
          <Divider vertical />
          <Stack.Item>
            This is the status panel for your pioneers. Each one requires 1 food
            every time you continue towards <span style={goodstyle}>Orion</span>
            . You can find more crew on your journey, and lose them as fast as
            you found &apos;em.
            <br />
            <br />
            If you run out of food or crew, it&apos;s{' '}
            <span style={badstyle}>GAME OVER</span> for you!
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Resources">
        <Stack>
          <Stack.Item grow>
            If you want to make it to <span style={goodstyle}>Orion</span>,
            you&apos;ll need to manage your resources:
            <br />
            <span style={goodstyle}>Food</span>: Your crewmembers consume it.
            More crew means this goes down faster!
            <br />
            <span style={fuelstyle}>Fuel</span>: You use 5u of fuel with every
            movement. Don&apos;t let it run out.
            <br />
            <span style={partstyle}>Parts</span>: Used to repair breakdowns.
            Nobody likes wasting time on repairs!
          </Stack.Item>
          <Divider vertical />
          <Stack.Item>
            <Stack vertical fill justify="center">
              <Stack.Item>
                <Button
                  fluid
                  icon="hamburger"
                  content={'Food Left: 80'}
                  color="green"
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  icon="gas-pump"
                  content={'Fuel Left: 60'}
                  color="olive"
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  icon="wrench"
                  content={'Hull Parts: 1'}
                  color="average"
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  icon="server"
                  content={'Electronics: 1'}
                  color="blue"
                />
              </Stack.Item>
              <Stack.Item mb={-0.3}>
                <Button
                  fluid
                  icon="rocket"
                  content={'Engine Parts: 1'}
                  color="violet"
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
};

const ORION_STATUS_NORMAL = (props) => {
  const { data, act } = useBackend();
  const {
    settlers,
    settlermoods,
    hull,
    electronics,
    engine,
    food,
    fuel,
    turns,
    eventname,
    eventtext,
    buttons,
  } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section title={(!!eventname && 'Event') || 'Location'} fill>
          <Stack fill textAlign="center" vertical>
            <Stack.Item grow>
              <Box bold fontSize="15px">
                {(!!eventname && eventname) || locationInfo[turns - 1].title}
              </Box>
              <br />
              <Box fontSize="15px">
                {(!!eventtext && eventtext) || locationInfo[turns - 1].blurb}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {(!!buttons &&
                buttons.map((button) => (
                  <Stack.Item key={button}>
                    <Button
                      mb={1}
                      lineHeight={3}
                      width={16}
                      icon={variousButtonIcons[button]}
                      content={button}
                      onClick={() => act(button)}
                    />
                  </Stack.Item>
                ))) || (
                <Button
                  mb={1}
                  lineHeight={3}
                  width={16}
                  icon="arrow-right"
                  content="Continue"
                  onClick={() => act('continue')}
                />
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <AdventureStatus />
      </Stack.Item>
    </Stack>
  );
};

const ORION_STATUS_GAMEOVER = (props) => {
  const { data, act } = useBackend();
  const { reason } = data;
  return (
    <Section fill>
      <Stack vertical textAlign="center" fill>
        <Stack.Item grow={1} />
        <Stack.Item color="red" fontSize="32px">
          {'Game Over'}
        </Stack.Item>
        <Stack.Item grow fontSize="15px" color="label">
          {reason}
        </Stack.Item>
        <Stack.Item fontSize="15px">
          <Button
            lineHeight={2}
            fluid
            icon="arrow-left"
            content="Main Menu"
            onClick={() => act('back_to_menu')}
          />
        </Stack.Item>
        <Stack.Item grow={3} />
      </Stack>
    </Section>
  );
};

const marketButtonSpacing = 0.8;

const ORION_STATUS_MARKET = (props) => {
  const { data, act } = useBackend();
  const { turns, spaceport_raided } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section
          title="Market"
          fill
          buttons={
            <>
              <Button
                content="Raid"
                icon="skull"
                color="black"
                disabled={spaceport_raided}
                onClick={() => act('raid_spaceport')}
              />
              <Button
                content="Leave"
                icon="arrow-right"
                onClick={() => act('leave_spaceport')}
              />
            </>
          }
        >
          <Stack fill textAlign="center" vertical>
            <Stack.Item grow>
              <Box mb={-2} bold fontSize="15px">
                {(turns === 4 && 'Tau Ceti Beta') || 'Small Space Port'}
              </Box>
              <br />
              <Box fontSize="14px">
                {(spaceport_raided && (
                  <Box color="red">
                    You are lucky to have escaped with your life. Attempting to
                    dock again would be certain death.
                  </Box>
                )) ||
                  "Hello, Pioneer! We have supplies for you to help \
                  you reach Orion. They aren't free, though!"}
              </Box>
            </Stack.Item>
            {(spaceport_raided && (
              <>
                <Stack.Item>
                  The Port is under high security. Any possibility of purchasing
                  goods has long since sailed.
                </Stack.Item>
                <Stack.Item grow />
              </>
            )) || (
              <>
                <Stack.Item>General Markets:</Stack.Item>
                <Stack.Item>
                  <Stack mb={-1} fill>
                    <Stack.Item grow basis={0}>
                      <Stack vertical>
                        <Stack.Item>
                          <Button
                            fluid
                            icon="gas-pump"
                            content={'5 Food -> 5 Fuel'}
                            color="green"
                            onClick={() =>
                              act('trade', {
                                what: 2,
                              })
                            }
                          />
                        </Stack.Item>
                        <Divider />
                        <Stack.Item mt={0}>Port Hangar Bay:</Stack.Item>
                        <Stack.Item mb={marketButtonSpacing}>
                          <Button
                            fluid
                            icon="wrench"
                            content={'5 Fuel for Hull Plates'}
                            color="average"
                            onClick={() =>
                              act('buyparts', {
                                part: 2,
                              })
                            }
                          />
                        </Stack.Item>
                        <Stack.Item mb={marketButtonSpacing}>
                          <Button
                            fluid
                            icon="server"
                            content={'5 Fuel for Electronics'}
                            color="blue"
                            onClick={() =>
                              act('buyparts', {
                                part: 3,
                              })
                            }
                          />
                        </Stack.Item>
                        <Stack.Item mb={marketButtonSpacing}>
                          <Button
                            fluid
                            icon="rocket"
                            content={'5 Fuel for Engine Parts'}
                            color="violet"
                            onClick={() =>
                              act('buyparts', {
                                part: 1,
                              })
                            }
                          />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item grow basis={0}>
                      <Stack vertical>
                        <Stack.Item>
                          <Button
                            fluid
                            icon="hamburger"
                            content={'5 Fuel -> 5 Food'}
                            color="olive"
                            onClick={() =>
                              act('trade', {
                                what: 1,
                              })
                            }
                          />
                        </Stack.Item>
                        <Divider />
                        <Stack.Item mt={0}>Port Bar:</Stack.Item>
                        <Stack.Item mb={marketButtonSpacing}>
                          <Button
                            fluid
                            icon="user-plus"
                            content={'10 Food, 10 Fuel for Crew'}
                            color="white"
                            onClick={() => act('buycrew')}
                          />
                        </Stack.Item>
                        <Stack.Item mb={marketButtonSpacing}>
                          <Button
                            fluid
                            icon="user-minus"
                            content={'Crew for 7 Food, 7 Fuel'}
                            color="black"
                            onClick={() => act('sellcrew')}
                          />
                        </Stack.Item>
                        <Stack.Item mb={marketButtonSpacing}>
                          <Button
                            fluid
                            icon="meteor"
                            content={'Odd Crew (Same Price)'}
                            color="purple"
                            onClick={() =>
                              act('buycrew', {
                                odd: 1,
                              })
                            }
                          />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </>
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <AdventureStatus />
      </Stack.Item>
    </Stack>
  );
};

export const OrionGame = (props) => {
  const { act, data } = useBackend();
  const { gamestatus, gamename, eventname } = data;
  const GameStatusComponent = STATUS2COMPONENT[gamestatus].component();
  const MarketRaid = STATUS2COMPONENT[2].component();
  return (
    <Window title={gamename} width={420} height={535}>
      <Window.Content scrollable>
        {(eventname === 'Space Port Raid' && <MarketRaid />) || (
          <GameStatusComponent />
        )}
      </Window.Content>
    </Window>
  );
};

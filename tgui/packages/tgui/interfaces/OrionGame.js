
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Divider, Icon, NumberInput, Section, Stack } from '../components';
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
  "Restore Hull": "wrench",
  "Fix Engine": "rocket",
  "Repair Electronics": "server",
  "Wait": "clock",
  "Continue": "arrow-right",

};

const STATUS2COMPONENT = [
  {
    component: () => ORION_STATUS_START,
  },
  {
    component: () => ORION_STATUS_INSTRUCTIONS,
  },
  {
    component: () => ORION_STATUS_NORMAL,
  },
  {
    component: () => ORION_STATUS_GAMEOVER,
  },
];

const locationInfo = [
  {
    title: "Pluto",
    blurb: "Pluto, long since occupied with long-range sensors and scanners, stands ready to, and indeed continues to probe the far reaches of the galaxy.",
  },
  {
    title: "Asteroid Belt",
    blurb: "At the edge of the Sol system lies a treacherous asteroid belt. Many have been crushed by stray asteroids and misguided judgement.",
  },
  {
    title: "Proxima Centauri",
    blurb: "The nearest star system to Sol, in ages past it stood as a reminder of the boundaries of sub-light travel, now a low-population sanctuary for adventurers and traders.",
  },
  {
    title: "Dead Space",
    blurb: "This region of space is particularly devoid of matter. Such low-density pockets are known to exist, but the vastness of it is astounding.",
  },
  {
    title: "Rigel Prime",
    blurb: "Rigel Prime, the center of the Rigel system, burns hot, basking its planetary bodies in warmth and radiation.",
  },
  {
    title: "Tau Ceti Beta",
    blurb: "Tau Ceti Beta has recently become a waypoint for colonists headed towards Orion. There are many ships and makeshift stations in the vicinity.",
  },
  {
    title: "Black Hole",
    blurb: "Sensors indicate that a black hole's gravitational field is affecting the region of space we were headed through. We could stay of course, but risk of being overcome by its gravity, or we could change course to go around, which will take longer.",
  },
  {
    title: "Space Outpost Beta-9",
    blurb: "You have come into range of the first man-made structure in this region of space. It has been constructed not by travellers from Sol, but by colonists from Orion. It stands as a monument to the colonists' success.",
  },
  {
    title: "Orion Prime",
    blurb: "You have made it to Orion! Congratulations! Your crew is one of the few to start a new foothold for mankind!",
  },
];

const ORION_STATUS_START = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    gamename,
  } = data;
  return (
    <Section fill>
      <Stack vertical textAlign="center" fill>
        <Stack.Item grow={1}/>
        <Stack.Item fontSize="32px">
          {gamename}
        </Stack.Item>
        <Stack.Item grow fontSize="15px" color="label">
          {"\"Experience the journey of your ancestors!\""}
        </Stack.Item>
        <Stack.Item fontSize="15px">
          <Button
            lineHeight={2}
            fluid
            icon="play"
            content="Begin Game"
            onClick={() => act('start_game')} />
        </Stack.Item>
        <Stack.Item fontSize="15px">
          <Button
            lineHeight={2}
            fluid
            icon="info"
            content="Instructions"
            onClick={() => act('instructions')} />
        </Stack.Item>
        <Stack.Item grow={3}/>
      </Stack>
    </Section>
  );
};

const ORION_STATUS_INSTRUCTIONS = (props, context) => {
  const { act } = useBackend(context);
  const fake_settlers = ["John", "William", "Alice", "Tom"];
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section
          color="label"
          title="Objective"
          fill
          buttons={(
            <Button
              content="Back to Main Menu"
              onClick={() => act('back_to_menu')} />
          )}>
          <Box fontSize="11px">
            In the 2200&apos;s, the Orion trail was established as a dangerous
            yet opportunistic trail through space for those willing to risk it.
            Many pioneers seeking new lives on the galactic frontier would find
            exactly what they were seeking... or lose their lives on the way.
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Status Example" fill>
          <Stack mb={-1} fill>
            <Stack.Item basis={70} grow mb={-0.5}>
              {fake_settlers?.map(settler => (
                <Stack key={settler}>
                  <Stack.Item grow mt={0.9}>
                    {settler}
                  </Stack.Item>
                  <Stack.Item mt={0.9}>
                    <Button
                      fluid
                      color="red"
                      textAlign="center"
                      icon="skull"
                      content="KILL" />
                  </Stack.Item>
                  <Stack.Item mr={0}>
                    <Box className={'moods32x32 mood5'} />
                  </Stack.Item>
                </Stack>
              ))}
            </Stack.Item>
            <Divider vertical />
            <Stack.Item grow>
              This is the status panel for your pioneers. Each one requires
              1 food every time you continue
              towards <span style={goodstyle}>Orion</span>.
              You can find more crew on your journey, and lose them as
              fast as you found &apos;em.
              <br /><br />
              If you run out of food or crew,
              it&apos;s <span style={badstyle}>GAME OVER</span> for you!
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill title="Resources">
          <Stack fill>
            <Stack.Item grow>
              If you want to make it to <span style={goodstyle}>Orion</span>,
              you&apos;ll need to manage your resources:
              <br />
              <span style={goodstyle}>Food</span>: Your crewmembers consume
              it. More crew means this goes down faster!
              <br />
              <span style={fuelstyle}>Fuel</span>: You use 5u of fuel with
              every movement. Don&apos;t let it run out.
              <br />
              <span style={partstyle}>Parts</span>: Used to repair breakdowns.
              Nobody likes wasting time on repairs!
            </Stack.Item>
            <Divider vertical />
            <Stack.Item>
              <Stack vertical fill>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="hamburger"
                    content={"Food Left: 80"}
                    color="green" />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="gas-pump"
                    content={"Fuel Left: 60"}
                    color="olive" />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="wrench"
                    content={"Hull Parts: 1"}
                    color="average" />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="server"
                    content={"Electronics: 1"}
                    color="blue" />
                </Stack.Item>
                <Stack.Item mb={-0.3} grow>
                  <Button
                    fluid
                    icon="rocket"
                    content={"Engine Parts: 1"}
                    color="violet" />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ORION_STATUS_NORMAL = (props, context) => {
  const { data, act } = useBackend(context);
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
        <Section title={!!eventname && "Event" || "Location"} fill>
          <Stack fill textAlign="center" vertical>
            <Stack.Item grow >
              <Box bold fontSize="15px">
                {!!eventname && eventname || locationInfo[turns-1].title}
              </Box>
              <br />
              <Box fontSize="15px">
                {!!eventtext && eventtext || locationInfo[turns-1].blurb}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {!!buttons && (
                buttons.map(button => (
                  <Stack.Item key={button}>
                    <Button
                      mb={1}
                      lineHeight={3}
                      width={16}
                      icon={variousButtonIcons[button]}
                      content={button}
                      onClick={() => act(button)} />
                  </Stack.Item>
                ))
              ) || (
                <Button
                  mb={1}
                  lineHeight={3}
                  width={16}
                  icon="arrow-right"
                  content="Continue"
                  onClick={() => act('continue')} />
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          title="Adventure Status"
          fill >
          <Stack mb={-1} fill>
            <Stack.Item grow mb={-0.5}>
              {settlers?.map(settler => (
                <Stack key={settler}>
                  <Stack.Item grow mt={0.9}>
                    {settler}
                  </Stack.Item>
                  <Stack.Item mt={0.9}>
                    <Button
                      fluid
                      color="red"
                      textAlign="center"
                      icon="skull"
                      content="KILL"
                      onClick={() => act('start_game')} />
                  </Stack.Item>
                  <Stack.Item mr={0}>
                    <Box className={'moods32x32 mood' + (settlermoods[settler] + 1)} />
                  </Stack.Item>
                </Stack>
              ))}
            </Stack.Item>
            <Divider vertical />
            <Stack.Item>
              <Stack vertical fill>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="hamburger"
                    content={"Food Left: " + food}
                    color="green" />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="gas-pump"
                    content={"Fuel Left: " + fuel}
                    color="olive" />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="wrench"
                    content={"Hull Parts: "+hull}
                    color="average" />
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="server"
                    content={"Electronics: "+electronics}
                    color="blue" />
                </Stack.Item>
                <Stack.Item mb={-0.65} grow>
                  <Button
                    fluid
                    icon="rocket"
                    content={"Engine Parts: "+engine}
                    color="violet" />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ORION_STATUS_GAMEOVER = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    order_datums,
    total_cost,
  } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section fill>
          game over screen
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const OrionGame = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    gamestatus,
    gamename,
  } = data;
  const GameStatusComponent = STATUS2COMPONENT[gamestatus].component();
  return (
    <Window
      title={gamename}
      width={400}
      height={500}>
      <Window.Content>
        <GameStatusComponent />
      </Window.Content>
    </Window>
  );
};

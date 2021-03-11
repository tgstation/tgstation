
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Divider, Icon, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';

const buttonWidth = 2;

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
    total_cost,
    gamedesc,
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
  )
};

const ORION_STATUS_INSTRUCTIONS = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    order_datums,
    total_cost,
  } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section fill>
          instructions page
        </Section>
      </Stack.Item>
    </Stack>
  )
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
  } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section title="Location" fill>
          <Stack fill textAlign="center" vertical>
            <Stack.Item bold grow fontSize="15px">
              {locationInfo[turns].title}
            </Stack.Item>
            <Stack.Item mb={5} grow fontSize="15px">
              {locationInfo[turns].blurb}
            </Stack.Item>
            <Stack.Item grow={4}>
              <Button
                icon="arrow-right"
                content="Continue"
                onClick={() => act('continue')} />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          title="Adventure Status"
          fill
          buttons={(
            <>
              <Button
                icon="hamburger"
                content={"Food: " + food}
                color="green" />
              <Button
                icon="gas-pump"
                content={"Fuel: " + fuel}
                color="olive" />
              <Button
                icon="wrench"
                content={hull}
                tooltipPosition="bottom-left"
                tooltip="Hull Parts"
                color="yellow" />
              <Button
                icon="server"
                content={electronics}
                color="blue" />
              <Button
                icon="server"
                content={engine}
                color="black" />
            </>
          )}>
          {settlers?.map(settler => (
            <Stack key={settler}>
              <Stack.Item grow mt={0.9}>
                {settler}
              </Stack.Item>
              <Stack.Item grow mt={0.9}>
                <Button
                  fluid
                  textAlign="center"
                  icon="skull"
                  content={"Kill " + settler}
                  onClick={() => act('start_game')} />
              </Stack.Item>
              <Stack.Item mr={0}>
                <Box
                  className={'moods32x32 mood' + (settlers.length+1)}
                  style={{
                    'color': '#4b96c4',
                  }} />
              </Stack.Item>
            </Stack>
          ))}
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

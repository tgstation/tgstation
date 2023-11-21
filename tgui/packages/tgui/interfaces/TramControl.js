import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

const DEPARTMENT2COLOR = {
  // Station
  Arrivals: 'black',
  Service: 'olive',
  Command: 'blue',
  Security: 'red',
  Medical: 'teal',
  Engineering: 'yellow',
  Cargo: 'brown',
  Science: 'purple',
  Departures: 'white',
  // Hilbert Research Facility
  Reception: 'white',
  Botany: 'olive',
  Chemistry: 'teal',
  Processing: 'brown',
  Xenobiology: 'purple',
  Ordnance: 'yellow',
  Office: 'red',
  Dormitories: 'black',
};

const COLOR2BLURB = {
  blue: "This is the tram's current location.",
  green: 'This is the selected destination.',
  transparent: 'Click to set destination.',
};

const marginNormal = 1;
const marginDipped = 3;

const dipUnderCircle = (dest, dep) => {
  const index = Object.keys(dest.dest_icons).indexOf(dep);
  const dipped = index >= 1 && index <= 2;
  return dipped ? marginDipped : marginNormal;
};

const BrokenTramDimmer = () => {
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon ml={7} color="red" name="triangle-exclamation" size={10} />
        </Stack.Item>
        <Stack.Item fontSize="14px" color="red">
          Check Tram Controller!
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

export const TramControl = (props, context) => {
  const { act, data } = useBackend(context);
  const { broken, moving, destinations, tram_location } = data;

  const [transitIndex, setTransitIndex] = useLocalState(
    context,
    'transit-index',
    1
  );
  const MovingTramDimmer = () => {
    return (
      <Dimmer>
        <Stack vertical>
          <Stack.Item>
            <Icon ml={10} name="sync-alt" color="green" size={11} />
          </Stack.Item>
          <Stack.Item mt={5} fontSize="14px" color="green">
            The tram is travelling to {tram_location}!
          </Stack.Item>
        </Stack>
      </Dimmer>
    );
  };
  const Destination = (props) => {
    const { dest } = props;
    const getDestColor = (dest) => {
      if (!tram_location) return 'bad';
      const here = dest.name === tram_location;
      const selected = transitIndex === destinations.indexOf(dest);
      return here ? 'blue' : selected ? 'green' : 'transparent';
    };
    return (
      <Stack vertical>
        <Stack.Item ml={5}>
          <Button
            mr={4.38}
            color={getDestColor(dest)}
            circular
            compact
            height={4.9}
            width={4.9}
            tooltipPosition="top"
            tooltip={COLOR2BLURB[getDestColor(dest)]}
            onClick={() => setTransitIndex(destinations.indexOf(dest))}>
            <Icon ml={-2.1} fontSize="60px" name="circle-o" />
          </Button>
          {(destinations.length - 1 !== destinations.indexOf(dest) && (
            <Section title=" " mt={-7.3} ml={10} mr={-6.1} />
          )) || <Box mt={-2.3} />}
        </Stack.Item>
        {dest.dest_icons && (
          <Stack.Item>
            <Stack>
              {Object.keys(dest.dest_icons).map((dep) => (
                <Stack.Item key={dep} mt={dipUnderCircle(dest, dep)}>
                  <Button
                    color={DEPARTMENT2COLOR[dep]}
                    icon={dest.dest_icons[dep]}
                    tooltipPosition="bottom"
                    tooltip={dep}
                    style={{
                      'border-radius': '5em',
                      'border': '2px solid white',
                    }}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        )}
      </Stack>
    );
  };
  return (
    <Window title="Tram Controls" width={600} height={300}>
      <Window.Content>
        {(!!broken && <BrokenTramDimmer />) || (
          <Section fill>
            {!!moving && <MovingTramDimmer />}
            <Stack ml="-6px" vertical fill>
              <Stack.Item grow fontSize="16px" mt={1} mb={9} textAlign="center">
                Nanotrasen Transit System
              </Stack.Item>
              <Stack.Item mb={4}>
                <Stack fill>
                  <Stack.Item grow />
                  {destinations.map((dest) => (
                    <Stack.Item key={dest.name} grow={1}>
                      <Destination dest={dest} />
                    </Stack.Item>
                  ))}
                  <Stack.Item grow={1} />
                </Stack>
              </Stack.Item>
              <Stack.Item fontSize="16px" mt={1} mb={9} textAlign="center" grow>
                <Button
                  disabled={tram_location === destinations[transitIndex].name}
                  content="Send Tram"
                  onClick={() =>
                    act('send', {
                      destination: destinations[transitIndex].id,
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

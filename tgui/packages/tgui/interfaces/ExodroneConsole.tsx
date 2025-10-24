import {
  createContext,
  Fragment,
  type SetStateAction,
  useContext,
  useState,
} from 'react';
import nt_logo from 'tgui-core/assets/bg-nanotrasen.svg';
import {
  BlockQuote,
  Box,
  Button,
  Dimmer,
  Icon,
  Image,
  LabeledList,
  Modal,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { formatTime } from 'tgui-core/format';
import { capitalize } from 'tgui-core/string';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type ExplorationEventData = {
  name: string;
  ref: string;
};

type FullEventData = {
  image: string;
  description: string;
  action_enabled: boolean;
  action_text: string;
  skippable: boolean;
  ignore_text: string;
  ref: string;
};

type ChoiceData = {
  key: string;
  text: string;
};

type AdventureData = {
  description: string;
  image: string;
  raw_image: string;
  choices: Array<ChoiceData>;
};

type SiteData = {
  name: string;
  ref: string;
  description: string;
  coordinates: string;
  distance: number;
  band_info: Record<string, number>;
  revealed: boolean;
  point_scan_complete: boolean;
  deep_scan_complete: boolean;
  events: Array<ExplorationEventData>;
};

enum DroneStatusEnum {
  Idle = 'idle',
  Travel = 'travel',
  Exploration = 'exploration',
  Adventure = 'adventure',
  Busy = 'busy',
}

enum CargoType {
  Tool = 'tool',
  Cargo = 'cargo',
  Empty = 'empty',
}

type CargoData = {
  type: CargoType;
  name: string;
};

type DroneBasicData = {
  name: string;
  description: string;
  controlled: boolean;
  ref: string;
};

export type AdventureDataProvider = {
  adventure_data: AdventureData;
};

type DroneAdventure = AdventureDataProvider & {
  drone_status: DroneStatusEnum.Adventure;
};

type DroneData = {
  drone_name: string;
  drone_integrity: number;
  drone_max_integrity: number;
  drone_travel_coefficent: number;
  drone_log: Array<string>;
  configurable: boolean;
  cargo: Array<CargoData>;
  can_travel: boolean;
  travel_error: string;
};

type DroneBusy = {
  drone_status: DroneStatusEnum.Busy;
  wait_time_left: number;
  wait_message: string;
};

type DroneExploration = {
  drone_status: DroneStatusEnum.Exploration;
  sites: Array<SiteData>;
  site: SiteData;
  event?: FullEventData;
};

type DroneIdle = {
  drone_status: DroneStatusEnum.Idle;
  sites: Array<SiteData>;
  site: null;
};

type DroneTravel = {
  drone_status: DroneStatusEnum.Travel;
  travel_time: number;
  travel_time_left: number;
};

type ActiveDrone =
  | DroneAdventure
  | DroneBusy
  | DroneExploration
  | DroneIdle
  | DroneTravel;

type ExodroneConsoleData = {
  signal_lost: boolean;

  // ui_static_data
  all_tools: Record<string, ToolData>;
  all_bands: Record<string, string>;
} & (
  | (({
      drone: true;
    } & DroneData) &
      ActiveDrone)
  | {
      all_drones: Array<DroneBasicData>;
      drone: undefined;
    }
);

type ToolData = {
  description: string;
  icon: string;
};

const ToolContext = createContext<
  [boolean, React.Dispatch<SetStateAction<boolean>>]
>([false, (_) => {}]);

export const ExodroneConsole = (props) => {
  const { data } = useBackend<ExodroneConsoleData>();
  const { signal_lost } = data;

  const [choosingTools, setChoosingTools] = useState(false);

  return (
    <Window width={750} height={600}>
      <ToolContext.Provider value={[choosingTools, setChoosingTools]}>
        {!!signal_lost && <SignalLostModal />}
        {!!choosingTools && <ToolSelectionModal />}
        <Window.Content>
          <ExodroneConsoleContent />
        </Window.Content>
      </ToolContext.Provider>
    </Window>
  );
};

const SignalLostModal = (props) => {
  const { act } = useBackend();
  return (
    <Modal
      backgroundColor="red"
      textAlign="center"
      width={30}
      height={22}
      p={0}
      style={{ borderRadius: '5%' }}
    >
      <img src={nt_logo} width={64} height={64} />
      <Box
        backgroundColor="black"
        textColor="red"
        fontSize={2}
        style={{ borderRadius: '-10%' }}
      >
        CONNECTION LOST
      </Box>
      <Box p={2} italic>
        Connection to exploration drone interrupted. Please contact nearest
        Nanotrasen Exploration Division representative for further instructions.
      </Box>
      <Icon name="exclamation-triangle" textColor="black" size={5} />
      <Box>
        <Button color="orange" onClick={() => act('confirm_signal_lost')}>
          Confirm
        </Button>
      </Box>
    </Modal>
  );
};

const DroneSelectionSection = (props: {
  all_drones: Array<DroneBasicData>;
}) => {
  const { act } = useBackend<ExodroneConsoleData>();
  const { all_drones } = props;

  return (
    <Section fill scrollable title="Exploration Drone Listing">
      <Stack vertical>
        {all_drones.map((drone) => (
          <Fragment key={drone.ref}>
            <Stack.Item>
              <Stack fill>
                <Stack.Item basis={10} fontFamily="monospace" fontSize="18px">
                  {drone.name}
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item fontFamily="monospace" mt={0.8}>
                  {drone.description}
                </Stack.Item>
                <Stack.Item grow />
                <Stack.Divider mr={1} />
                <Stack.Item ml={0}>
                  {(drone.controlled && 'Controlled by another console.') || (
                    <Button
                      icon="plug"
                      onClick={() =>
                        act('select_drone', { drone_ref: drone.ref })
                      }
                    >
                      Assume Control
                    </Button>
                  )}
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Divider />
          </Fragment>
        ))}
      </Stack>
    </Section>
  );
};

const ToolSelectionModal = (props) => {
  const { act, data } = useBackend<ExodroneConsoleData>();
  const { all_tools = {} } = data;

  const [choosingTools, setChoosingTools] = useContext(ToolContext);

  const toolData = Object.keys(all_tools);
  return (
    <Modal style={{ padding: '8px' }}>
      <Section
        title="Tool Selection"
        buttons={
          <Button
            icon="xmark"
            color="transparent"
            onClick={() => {
              setChoosingTools(false);
            }}
          />
        }
      >
        <Stack textAlign="center">
          {(!!toolData &&
            toolData.map((tool_name) => (
              <Stack.Item key={tool_name}>
                <Stack vertical>
                  <Stack.Item>
                    {' '}
                    <Button
                      onClick={() => {
                        setChoosingTools(false);
                        act('add_tool', { tool_type: tool_name });
                      }}
                      height={6}
                      tooltip={all_tools[tool_name].description}
                      icon={all_tools[tool_name].icon}
                      iconSize={3}
                      style={{ paddingTop: '15px' }}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <span style={{ color: 'rgba(255, 255, 255, 0.5)' }}>
                      {capitalize(tool_name)}
                    </span>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))) || (
            <Stack.Item>
              <Button onClick={() => setChoosingTools(false)}>Back</Button>
            </Stack.Item>
          )}
        </Stack>
      </Section>
    </Modal>
  );
};

const EquipmentBox = (props: { cargo: CargoData; drone: DroneData }) => {
  const { act, data } = useBackend<ExodroneConsoleData>();
  const { all_tools = {} } = data;
  const { configurable } = props.drone;
  const cargo = props.cargo;
  const boxContents = (cargo) => {
    switch (cargo.type) {
      case 'tool': // Tool icon+Remove button if configurable
        return (
          <Stack fill>
            <Stack.Item>
              <Icon
                name={all_tools[cargo.name].icon}
                size={1.5}
                style={{ paddingTop: '4px' }}
                mr="5px"
                ml="5px"
                width="20px"
              />
            </Stack.Item>
            <Stack.Item grow>
              <span
                style={{ width: '100%', fontSize: '16px', lineHeight: '26px' }}
              >
                {capitalize(cargo.name)}
              </span>
            </Stack.Item>
            {!!configurable && (
              <Stack.Item>
                <Button
                  onClick={() => act('remove_tool', { tool_type: cargo.name })}
                  color="transparent"
                  icon="eject"
                  height={2.3}
                  tooltip="Eject"
                  style={{ paddingTop: '4px' }}
                />
              </Stack.Item>
            )}
          </Stack>
        );
      case 'cargo': // Jettison button.
        return (
          <Stack fill>
            <Stack.Item>
              <Icon
                name="box"
                size={1.5}
                style={{ paddingTop: '4px' }}
                mr="5px"
                ml="5px"
                width="20px"
              />
            </Stack.Item>
            <Stack.Item grow>
              <span
                style={{ width: '100%', fontSize: '16px', lineHeight: '26px' }}
              >
                {capitalize(cargo.name)}
              </span>
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() => act('jettison', { target_ref: cargo.ref })}
                color="transparent"
                icon="eject"
                height={2.3}
                tooltip={`Jettison ${cargo.name}`}
                style={{ paddingTop: '4px' }}
              />
            </Stack.Item>
          </Stack>
        );
      case 'empty':
        return '';
    }
  };
  return boxContents(cargo) ? (
    <Box
      width="100%"
      height={3}
      style={{
        backgroundColor: 'rgba(0, 0, 0, 0.3)',
        borderRadius: '5px',
        alignItems: 'center',
        padding: '5px',
      }}
    >
      {boxContents(cargo)}
    </Box>
  ) : (
    <Box
      width="100%"
      height={3}
      style={{
        backgroundColor: 'rgba(0, 0, 0, 0.3)',
        borderRadius: '5px',
        padding: '5px',
      }}
    >
      <Box
        width="100%"
        height="100%"
        style={{
          border: '1px rgba(255, 255, 255, 0.3) dashed',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          borderRadius: '3px',
        }}
      >
        <span
          style={{
            color: 'rgba(255, 255, 255, 0.2)',
          }}
        >
          Empty slot
        </span>
      </Box>
    </Box>
  );
};

const EquipmentGrid = (props: { drone: ActiveDrone & DroneData }) => {
  const { act } = useBackend<ExodroneConsoleData>();
  const { cargo, configurable } = props.drone;

  const [_, setChoosingTools] = useContext(ToolContext);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Master Controls" minWidth="200px">
          <Stack vertical textAlign="center">
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Drone ID">
                  {props.drone.drone_name}
                </LabeledList.Item>
                <LabeledList.Item label="Activity">
                  {capitalize(props.drone.drone_status)}
                </LabeledList.Item>
                <LabeledList.Item label="Integrity">
                  <Tooltip
                    content={
                      props.drone.drone_integrity +
                      '/' +
                      props.drone.drone_max_integrity
                    }
                  >
                    <ProgressBar
                      ranges={{
                        good: [
                          0.7 * props.drone.drone_max_integrity,
                          props.drone.drone_max_integrity,
                        ],
                        average: [
                          0.4 * props.drone.drone_max_integrity,
                          0.7 * props.drone.drone_max_integrity,
                        ],
                        bad: [-Infinity, 0.4 * props.drone.drone_max_integrity],
                      }}
                      value={props.drone.drone_integrity}
                      maxValue={props.drone.drone_max_integrity}
                    />
                  </Tooltip>
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <Button fluid icon="plug" onClick={() => act('end_control')}>
                Disconnect
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                fluid
                icon="bomb"
                color="bad"
                onClick={() => act('self_destruct')}
              >
                Self-Destruct
              </Button.Confirm>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          title="Equipment"
          buttons={
            !!configurable && (
              <Button
                fluid
                color="average"
                icon="wrench"
                onClick={() => setChoosingTools(true)}
              />
            )
          }
        >
          <Stack fill vertical>
            <Stack.Item>
              <Stack vertical>
                {cargo.map((cargo_element, index) => (
                  <EquipmentBox
                    drone={props.drone}
                    key={`cargo-${index}`}
                    cargo={cargo_element}
                  />
                ))}
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const NoSiteDimmer = () => {
  return (
    <Dimmer>
      <Stack textAlign="center" vertical>
        <Stack.Item>
          <Icon color="red" name="map" size={10} />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="red">
          No Destinations.
        </Stack.Item>
        <Stack.Item basis={0} color="red">
          (Use the Scanner Array Console to find new locations.)
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const TravelTargetSelectionScreen = (props: {
  drone: (DroneExploration | DroneIdle | DroneTravel) & DroneData;
  showCancelButton?: boolean;
  onSelectionDone: () => void;
}) => {
  // List of sites and eta travel times to each
  const { act, data } = useBackend<ExodroneConsoleData>();
  const { drone } = props;
  const { all_bands } = data;
  const { can_travel, travel_error, drone_travel_coefficent } = drone;

  const site = 'site' in drone ? drone.site : null;
  const sites = 'sites' in drone ? drone.sites : null;

  const travel_cost = (target_site) => {
    if (site) {
      return (
        Math.max(Math.abs(site.distance - target_site.distance), 1) *
        drone_travel_coefficent
      );
    } else {
      return target_site.distance * drone_travel_coefficent;
    }
  };
  const [choosingTools, _] = useContext(ToolContext);

  const travel_to = (ref) => {
    props.onSelectionDone();
    act('start_travel', { target_site: ref });
  };

  const non_empty_bands = (dest: SiteData) => {
    const band_check = (s: string) =>
      dest.band_info[s] !== undefined && dest.band_info[s] !== 0;
    return Object.keys(all_bands).filter(band_check);
  };
  const valid_destinations = sites?.filter(
    (destination) => !site || destination.ref !== site.ref,
  );
  return (
    (drone.drone_status === DroneStatusEnum.Travel && (
      <TravelDimmer drone={drone} />
    )) || (
      <Section
        title="Travel Destinations"
        fill
        scrollable
        buttons={
          <>
            {props.showCancelButton && (
              <Button ml={5} mr={0} onClick={() => props.onSelectionDone()}>
                Cancel
              </Button>
            )}
            <Box mt={props.showCancelButton && -3.5} />
          </>
        }
      >
        {sites && !sites.length && !choosingTools && <NoSiteDimmer />}
        {site && (
          <Section
            mt={1}
            title="Home"
            buttons={
              <Box>
                ETA:{' '}
                {formatTime(site.distance * drone_travel_coefficent, 'short')}
                <Button
                  ml={1}
                  onClick={() => travel_to(null)}
                  disabled={!can_travel}
                  icon={can_travel ? 'rocket' : 'triangle-exclamation'}
                >
                  {can_travel ? 'Launch' : travel_error}
                </Button>
              </Box>
            }
          />
        )}
        {valid_destinations?.map((destination) => (
          <Section
            key={destination.ref}
            title={destination.name}
            buttons={
              <>
                ETA: {formatTime(travel_cost(destination), 'short')}
                <Button
                  ml={1}
                  onClick={() => travel_to(destination.ref)}
                  disabled={!can_travel}
                  icon={can_travel ? 'rocket' : 'triangle-exclamation'}
                >
                  {can_travel ? 'Launch' : travel_error}
                </Button>
              </>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Location">
                {destination.coordinates}
              </LabeledList.Item>
              <LabeledList.Item label="Description">
                {destination.description}
              </LabeledList.Item>
              <LabeledList.Divider />
              {non_empty_bands(destination).map((band) => (
                <LabeledList.Item key={band} label={band}>
                  {destination.band_info[band]}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        ))}
      </Section>
    )
  );
};

const TravelDimmer = (props: { drone: DroneTravel }) => {
  const { travel_time_left } = props.drone;
  return (
    <Section fill>
      <Dimmer>
        <Stack textAlign="center" vertical>
          <Stack.Item>
            <Icon color="yellow" name="route" size={10} />
          </Stack.Item>
          <Stack.Item fontSize="18px" color="yellow">
            Travel Time: {formatTime(travel_time_left)}
          </Stack.Item>
        </Stack>
      </Dimmer>
    </Section>
  );
};

const TimeoutScreen = (props: { drone: DroneBusy }) => {
  const { wait_time_left, wait_message } = props.drone;

  return (
    <Section fill>
      <Dimmer>
        <Stack textAlign="center" vertical>
          <Stack.Item>
            <Icon color="green" name="cog" size={10} />
          </Stack.Item>
          <Stack.Item fontSize="18px" color="green">
            {wait_message} ({formatTime(wait_time_left)})
          </Stack.Item>
        </Stack>
      </Dimmer>
    </Section>
  );
};

const ExplorationScreen = (props: { drone: DroneExploration & DroneData }) => {
  const { act } = useBackend();
  const { drone } = props;
  const { site } = drone;

  const [TravelDimmerShown, setTravelDimmerShown] = useState(false);

  if (TravelDimmerShown) {
    return (
      <TravelTargetSelectionScreen
        onSelectionDone={() => setTravelDimmerShown(false)}
        drone={drone}
        showCancelButton
      />
    );
  }
  return (
    <Section fill title="Exploration">
      <Stack vertical fill>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Site">{site.name}</LabeledList.Item>
            <LabeledList.Item label="Location">
              {site.coordinates}
            </LabeledList.Item>
            <LabeledList.Item label="Description">
              {site.description}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item align="center">
          <Button
            lineHeight="3"
            width="75px"
            textAlign="center"
            onClick={() => act('explore')}
          >
            Explore
          </Button>
        </Stack.Item>
        {site.events.map((e) => (
          <Stack.Item align="center" key={site.ref} grow>
            <Button
              lineHeight="3"
              minWidth="75px"
              textAlign="center"
              onClick={() => act('explore_event', { target_event: e.ref })}
            >
              {capitalize(e.name)}
            </Button>
          </Stack.Item>
        ))}
        <Stack.Item align="center" grow>
          <Button
            lineHeight="3"
            width="75px"
            textAlign="center"
            onClick={() => setTravelDimmerShown(true)}
          >
            Travel
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EventScreen = (props: { drone: DroneData; event: FullEventData }) => {
  const { act } = useBackend();
  const { drone, event } = props;

  return (
    <Section fill title="Exploration">
      <Stack vertical fill textAlign="center">
        <Stack.Item>
          <Stack fill>
            <Stack.Item>
              <Image
                src={resolveAsset(event.image)}
                height="125px"
                width="250px"
              />
            </Stack.Item>
            <Stack.Item>
              <BlockQuote preserveWhitespace textAlign="start">
                {event.description}
              </BlockQuote>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Stack vertical fill>
            <Stack.Item grow />
            <Stack.Item grow>
              <Button
                disabled={!event.action_enabled}
                onClick={() => act('start_event')}
              >
                {event.action_text}
              </Button>
            </Stack.Item>
            {!!event.skippable && (
              <Stack.Item mt={2}>
                <Button onClick={() => act('skip_event')}>
                  {event.ignore_text}
                </Button>
              </Stack.Item>
            )}
            <Stack.Item grow />
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AdventureScreen = (props: {
  adventure_data: AdventureData;
  drone_integrity: number;
  drone_max_integrity: number;
  hide_status?: boolean;
}) => {
  const { act } = useBackend();
  const { adventure_data, drone_integrity, drone_max_integrity } = props;
  const rawData = adventure_data.raw_image;
  const imgSource = rawData ? rawData : resolveAsset(adventure_data.image);
  return (
    <Section fill title="Exploration">
      <Stack>
        <Stack.Item>
          <BlockQuote preserveWhitespace>
            {adventure_data.description}
          </BlockQuote>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Image src={imgSource} height="100px" width="200px" />
          <Stack vertical>
            <Stack.Divider />
            <Stack.Item grow />
            {!!adventure_data.choices &&
              adventure_data.choices.map((choice) => (
                <Stack.Item key={choice.key}>
                  <Button
                    fluid
                    textAlign="center"
                    onClick={() =>
                      act('adventure_choice', { choice: choice.key })
                    }
                  >
                    {choice.text}
                  </Button>
                </Stack.Item>
              ))}
            <Stack.Item grow />
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const DroneScreen = (props: { drone: ActiveDrone & DroneData }) => {
  const { drone } = props;

  switch (drone.drone_status) {
    case DroneStatusEnum.Busy:
      return <TimeoutScreen drone={drone} />;
    case DroneStatusEnum.Idle:
    case DroneStatusEnum.Travel:
      return (
        <TravelTargetSelectionScreen drone={drone} onSelectionDone={() => {}} />
      );
    case DroneStatusEnum.Adventure:
      return (
        <AdventureScreen
          adventure_data={drone.adventure_data}
          drone_integrity={drone.drone_integrity}
          drone_max_integrity={drone.drone_max_integrity}
        />
      );
    case DroneStatusEnum.Exploration:
      if (drone.event) {
        return <EventScreen drone={drone} event={drone.event} />;
      } else {
        return <ExplorationScreen drone={drone} />;
      }
  }
};

const ExodroneConsoleContent = (props) => {
  const { data } = useBackend<ExodroneConsoleData>();

  if (!data.drone) {
    return <DroneSelectionSection all_drones={data.all_drones} />;
  }

  const { drone_log } = data;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <EquipmentGrid drone={data} />
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack vertical fill>
              <Stack.Item grow>
                <DroneScreen drone={data} />
              </Stack.Item>
              <Stack.Item grow>
                <Section title="Drone Log" fill scrollable>
                  <LabeledList>
                    {drone_log.map((log_line, ix) => (
                      <LabeledList.Item key={`log-${ix}`} label={`#${ix + 1}`}>
                        {log_line}
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

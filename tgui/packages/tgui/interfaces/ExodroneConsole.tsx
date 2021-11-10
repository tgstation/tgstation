import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, Dimmer, Icon, LabeledList, Modal, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import { formatTime } from '../format';
import { capitalize } from 'common/string';
import nt_logo from '../assets/bg-nanotrasen.svg';
import { Fragment } from 'inferno';

type ExplorationEventData = {
  name: string,
  ref: string
}

type FullEventData = {
  image: string,
  description: string,
  action_enabled: boolean,
  action_text: string,
  skippable: boolean,
  ignore_text: string,
  ref: string
}

type ChoiceData = {
  key: string,
  text: string
}

type AdventureData = {
  description: string,
  image: string,
  raw_image: string,
  choices: Array<ChoiceData>
}

type SiteData = {
  name: string,
  ref: string,
  description: string,
  coordinates: string,
  distance: number,
  band_info: Record<string, number>,
  revealed: boolean,
  point_scan_complete: boolean,
  deep_scan_complete: boolean,
  events: Array<ExplorationEventData>
}


enum DroneStatusEnum {
  Idle = "idle",
  Travel = "travel",
  Exploration = "exploration",
  Adventure = "adventure",
  Busy = "busy"
}

enum CargoType {
  Tool = "tool",
  Cargo = "cargo",
  Empty = "empty"
}

type CargoData = {
  type: CargoType,
  name: string
}

type DroneBasicData = {
  name: string,
  description: string,
  controlled: boolean,
  ref: string,
}

export type AdventureDataProvider = {
  adventure_data: AdventureData,
}

type DroneAdventure = AdventureDataProvider & {
  drone_status: DroneStatusEnum.Adventure,
};

type DroneData = {
  drone_name: string,
  drone_integrity: number,
  drone_max_integrity: number,
  drone_travel_coefficent: number,
  drone_log: Array<string>,
  configurable: boolean,
  cargo: Array<CargoData>,
  can_travel: boolean,
  travel_error: string,
};

type DroneBusy = {
  drone_status: DroneStatusEnum.Busy,
  wait_time_left: number,
  wait_message: string,
};

type DroneExploration = {
  drone_status: DroneStatusEnum.Exploration,
  sites: Array<SiteData>,
  site: SiteData,
  event?: FullEventData,
};

type DroneIdle = {
  drone_status: DroneStatusEnum.Idle,
  sites: Array<SiteData>,
  site: null,
};

type DroneTravel = {
  drone_status: DroneStatusEnum.Travel,
  travel_time: number,
  travel_time_left: number,
};

type ActiveDrone = DroneAdventure
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
  description: string,
  icon: string
}

export const ExodroneConsole = (props, context) => {
  const { data } = useBackend<ExodroneConsoleData>(context);
  const {
    signal_lost,
  } = data;

  const [
    choosingTools,
    setChoosingTools,
  ] = useLocalState(context, 'choosingTools', false);

  return (
    <Window width={650} height={500}>
      {!!signal_lost && <SignalLostModal />}
      {!!choosingTools && <ToolSelectionModal />}
      <Window.Content>
        <ExodroneConsoleContent />
      </Window.Content>
    </Window>
  );
};

const SignalLostModal = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Modal
      backgroundColor="red"
      textAlign="center"
      width={30}
      height={22}
      p={0}
      style={{ "border-radius": "5%" }}>
      <img src={nt_logo} width={64} height={64} />
      <Box
        backgroundColor="black"
        textColor="red"
        fontSize={2}
        style={{ "border-radius": "-10%" }}>
        CONNECTION LOST
      </Box>
      <Box p={2} italic>
        Connection to exploration drone interrupted.
        Please contact nearest Nanotrasen Exploration Division
        representative for further instructions.
      </Box>
      <Icon
        name="exclamation-triangle"
        textColor="black"
        size={5} />
      <Box>
        <Button
          content="Confirm"
          color="danger"
          style={{ "border": "1px solid black" }}
          onClick={() => act("confirm_signal_lost")} />
      </Box>
    </Modal>
  );
};

const DroneSelectionSection = (props: {
  all_drones: Array<DroneBasicData>,
}, context) => {
  const { act } = useBackend<ExodroneConsoleData>(context);
  const { all_drones } = props;

  return (
    <Section scrollable fill title="Exploration Drone Listing">
      <Stack vertical>
        {all_drones.map(drone => (
          <Fragment key={drone.ref}>
            <Stack.Item grow>
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
                  {drone.controlled && (
                    "Controlled by another console."
                  ) || (
                    <Button
                      content="Assume Control"
                      icon="plug"
                      onClick={() => act("select_drone", { "drone_ref": drone.ref })} />
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


const ToolSelectionModal = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    all_tools = {},
  } = data;

  const [
    choosingTools,
    setChoosingTools,
  ] = useLocalState(context, 'choosingTools', false);

  const toolData = Object.keys(all_tools);
  return (
    <Modal>
      <Stack fill vertical pr={2}>
        <Stack.Item>
          Select Tool:
        </Stack.Item>
        <Stack.Item>
          <Stack textAlign="center">
            {!!toolData && toolData.map(tool_name => (
              <Stack.Item key={tool_name}>
                <Button
                  onClick={() => {
                    setChoosingTools(false);
                    act("add_tool", { tool_type: tool_name });
                  }}
                  width={6}
                  height={6}
                  tooltip={all_tools[tool_name].description}>
                  <Stack vertical>
                    <Stack.Item>
                      {capitalize(tool_name)}
                    </Stack.Item>
                    <Stack.Item ml={2.5}>
                      <Icon name={all_tools[tool_name].icon} size={3} />
                    </Stack.Item>
                  </Stack>
                </Button>
              </Stack.Item>
            )) || (
              <Stack.Item>
                <Button
                  content="Back" />
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

const EquipmentBox = (props: {
  cargo: CargoData,
  drone: DroneData,
}, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const { all_tools = {} } = data;
  const { configurable } = props.drone;
  const cargo = props.cargo;
  const boxContents = cargo => {
    switch (cargo.type) {
      case "tool": // Tool icon+Remove button if configurable
        return (
          <Stack direction="column">
            <Stack.Item grow>
              <Button
                height={4.7}
                width={4.7}
                tooltip={capitalize(cargo.name)}
                tooltipPosition="right"
                color="transparent">
                <Icon
                  color="white"
                  name={all_tools[cargo.name].icon}
                  size={3}
                  pl={1.5}
                  pt={2} />
              </Button>
            </Stack.Item>
            {!!configurable && (
              <Stack.Item mt={-9.4} textAlign="right">
                <Button
                  onClick={() => act("remove_tool", { tool_type: cargo.name })}
                  color="danger"
                  icon="minus"
                  tooltipPosition="right"
                  tooltip="Remove Tool" />
              </Stack.Item>
            )}
          </Stack>
        );
      case "cargo":// Jettison button.
        return (
          <Stack direction="column">
            <Stack.Item>
              <Button
                mt={0}
                height={4.7}
                width={4.7}
                tooltip={capitalize(cargo.name)}
                tooltipPosition="right"
                color="transparent">
                <Icon
                  color="white"
                  name="box"
                  size={3}
                  pl={2.2}
                  pt={2} />
              </Button>
            </Stack.Item>
            <Stack.Item mt={-9.4} textAlign="right">
              <Button
                onClick={() => act("jettison", { target_ref: cargo.ref })}
                color="danger"
                icon="minus"
                tooltipPosition="right"
                tooltip={`Jettison ${cargo.name}`} />
            </Stack.Item>
          </Stack>
        );
      case "empty":
        return "";
    }
  };
  return (
    <Box
      width={5}
      height={5}
      style={{ border: '2px solid black' }}
      textAlign="center">
      {boxContents(cargo)}
    </Box>
  );
};

const EquipmentGrid = (props: {
  drone: ActiveDrone & DroneData,
}, context) => {
  const { act } = useBackend<ExodroneConsoleData>(context);
  const {
    cargo,
    configurable,
  } = props.drone;
  const [
    choosingTools,
    setChoosingTools,
  ] = useLocalState(context, 'choosingTools', false);
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section fill title="Controls">
          <Stack vertical textAlign="center">
            <Stack.Item>
              <Button
                fluid
                icon="plug"
                content="Disconnect"
                onClick={() => act('end_control')} />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Button.Confirm
                fluid
                icon="bomb"
                content="Self-Destruct"
                color="bad"
                onClick={() => act('self_destruct')} />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Cargo">
          <Stack.Item>
            {!!configurable && (
              <Button
                fluid
                color="average"
                icon="wrench"
                content="Install Tool"
                onClick={() => setChoosingTools(true)} />
            )}
          </Stack.Item>
          <Stack.Item>
            <Stack wrap="wrap" width={10}>
              {cargo.map(cargo_element => (
                <EquipmentBox
                  drone={props.drone}
                  key={cargo_element.name}
                  cargo={cargo_element} />
              ))}
            </Stack>
          </Stack.Item>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DroneStatus = (props: {
  drone_integrity: number,
  drone_max_integrity: number,
}, context) => {
  const {
    drone_integrity,
    drone_max_integrity,
  } = props;

  return (
    <Stack ml={-40}>
      <Stack.Item color="label" mt={0.2}>
        Integrity:
      </Stack.Item>
      <Stack.Item grow>
        <ProgressBar
          width="200px"
          ranges={{
            good: [0.7 * drone_max_integrity, drone_max_integrity],
            average: [0.4 * drone_max_integrity, 0.7 * drone_max_integrity],
            bad: [-Infinity, 0.4 * drone_max_integrity],
          }}
          value={drone_integrity}
          maxValue={drone_max_integrity} />
      </Stack.Item>
    </Stack>
  );
};

const NoSiteDimmer = () => {
  return (
    <Dimmer>
      <Stack textAlign="center" vertical>
        <Stack.Item>
          <Icon
            color="red"
            name="map"
            size={10}
          />
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
  drone: (DroneExploration | DroneIdle | DroneTravel) & DroneData,
  showCancelButton?: boolean,
}, context) => {
  // List of sites and eta travel times to each
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const { drone } = props;
  const { all_bands } = data;
  const {
    can_travel,
    travel_error,
    drone_travel_coefficent,
  } = drone;

  const site = ("site" in drone) ? drone.site : null;
  const sites = ("sites" in drone) ? drone.sites : null;

  const travel_cost = target_site => {
    if (site) {
      return Math.max(Math.abs(site.distance - target_site.distance), 1)
        * drone_travel_coefficent;
    }
    else {
      return target_site.distance * drone_travel_coefficent;
    }
  };
  const [
    choosingTools,
    setChoosingTools,
  ] = useLocalState(context, 'choosingTools', false);
  const [
    TravelDimmerShown,
    setTravelDimmerShown,
  ] = useLocalState(context, 'TravelDimmerShown', false);

  const travel_to = ref => {
    setTravelDimmerShown(false);
    act("start_travel", { "target_site": ref });
  };

  const non_empty_bands = (dest : SiteData) => {
    const band_check = (s: string) => dest.band_info[s] !== undefined
      && dest.band_info[s] !== 0;
    return Object.keys(all_bands).filter(band_check);
  };
  const valid_destinations = sites && sites.filter(destination => (
    !site || destination.ref !== site.ref
  ));
  return (
    drone.drone_status === DroneStatusEnum.Travel && (
      <TravelDimmer drone={drone} />
    ) || (
      <Section
        title="Travel Destinations"
        fill
        scrollable
        buttons={
          <>
            {props.showCancelButton && (
              <Button
                ml={5}
                mr={0}
                content="Cancel"
                onClick={() => setTravelDimmerShown(false)} />
            )}
            <Box mt={props.showCancelButton && -3.5}>
              <DroneStatus
                drone_integrity={drone.drone_integrity}
                drone_max_integrity={drone.drone_max_integrity}
              />
            </Box>
          </>
        }>
        {((sites && !sites.length) && !choosingTools) && (
          <NoSiteDimmer />
        )}
        {site && (
          <Section
            mt={1}
            title="Home"
            buttons={
              <Box>
                ETA: {formatTime(site.distance * drone_travel_coefficent, "short")}
                <Button
                  ml={1}
                  content={can_travel ? "Launch!" : travel_error}
                  onClick={() => travel_to(null)}
                  disabled={!can_travel} />
              </Box>
            }
          />
        )}
        {valid_destinations?.map(destination => (
          <Section
            key={destination.ref}
            title={destination.name}
            buttons={
              <>
                ETA: {formatTime(travel_cost(destination), "short")}
                <Button
                  ml={1}
                  content={can_travel ? "Launch!" : travel_error}
                  onClick={() => travel_to(destination.ref)}
                  disabled={!can_travel} />
              </>
            }>
            <LabeledList>
              <LabeledList.Item label="Location">
                {destination.coordinates}
              </LabeledList.Item>
              <LabeledList.Item label="Description">
                {destination.description}
              </LabeledList.Item>
              <LabeledList.Divider />
              {non_empty_bands(destination).map(band => (
                <LabeledList.Item
                  key={band}
                  label={band}>
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

const TravelDimmer = (props: {
  drone: DroneTravel,
}, context) => {
  const { travel_time_left } = props.drone;
  return (
    <Section fill>
      <Dimmer>
        <Stack textAlign="center" vertical>
          <Stack.Item>
            <Icon
              color="yellow"
              name="route"
              size={10}
            />
          </Stack.Item>
          <Stack.Item fontSize="18px" color="yellow">
            Travel Time: {formatTime(travel_time_left)}
          </Stack.Item>
        </Stack>
      </Dimmer>
    </Section>
  );
};

const TimeoutScreen = (props: {
  drone: DroneBusy,
}) => {
  const {
    wait_time_left,
    wait_message,
  } = props.drone;

  return (
    <Section fill>
      <Dimmer>
        <Stack textAlign="center" vertical>
          <Stack.Item>
            <Icon
              color="green"
              name="cog"
              size={10}
            />
          </Stack.Item>
          <Stack.Item fontSize="18px" color="green">
            {wait_message} ({formatTime(wait_time_left)})
          </Stack.Item>
        </Stack>
      </Dimmer>
    </Section>
  );
};

const ExplorationScreen = (props: {
  drone: DroneExploration & DroneData,
}, context) => {
  const { act } = useBackend(context);
  const { drone } = props;
  const { site } = drone;

  const [
    TravelDimmerShown,
    setTravelDimmerShown,
  ] = useLocalState(context, 'TravelDimmerShown', false);

  if (TravelDimmerShown) {
    return (<TravelTargetSelectionScreen
      drone={drone}
      showCancelButton
    />);
  }
  return (
    <Section
      fill
      title="Exploration"
      buttons={
        <DroneStatus
          drone_integrity={drone.drone_integrity}
          drone_max_integrity={drone.drone_max_integrity}
        />
      }>
      <Stack vertical fill>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Site">{site.name}</LabeledList.Item>
            <LabeledList.Item label="Location">{site.coordinates}</LabeledList.Item>
            <LabeledList.Item label="Description">{site.description}</LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item align="center" grow>
          <Button
            content="Explore!"
            onClick={() => act("explore")} />
        </Stack.Item>
        {site.events.map(e => (
          <Stack.Item
            align="center"
            key={site.ref}
            grow>
            <Button
              content={capitalize(e.name)}
              onClick={() => act("explore_event", { target_event: e.ref })} />
          </Stack.Item>))}
        <Stack.Item align="center" grow>
          <Button
            content="Travel"
            onClick={() => setTravelDimmerShown(true)} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EventScreen = (props: {
  drone: DroneData,
  event: FullEventData,
}, context) => {
  const { act } = useBackend(context);
  const { drone, event } = props;

  return (
    <Section
      fill
      title="Exploration"
      buttons={
        <DroneStatus
          drone_integrity={drone.drone_integrity}
          drone_max_integrity={drone.drone_max_integrity}
        />
      }>
      <Stack vertical fill textAlign="center">
        <Stack.Item>
          <Stack fill>
            <Stack.Item>
              <img src={resolveAsset(event.image)}
                height="125px"
                width="250px"
                style={{
                  '-ms-interpolation-mode': 'nearest-neighbor',
                }} />
            </Stack.Item>
            <Stack.Item >
              <BlockQuote preserveWhitespace>
                {event.description}
              </BlockQuote>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Stack vertical fill >
            <Stack.Item grow />
            <Stack.Item grow>
              <Button
                content={event.action_text}
                disabled={!event.action_enabled}
                onClick={() => act("start_event")} />
            </Stack.Item>
            {!!event.skippable && (
              <Stack.Item mt={2}>
                <Button
                  content={event.ignore_text}
                  onClick={() => act("skip_event")} />
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
  adventure_data: AdventureData,
  drone_integrity: number,
  drone_max_integrity: number,
  hide_status?: boolean,
}, context) => {
  const { act } = useBackend(context);
  const {
    adventure_data,
    drone_integrity,
    drone_max_integrity,
  } = props;
  const rawData = adventure_data.raw_image;
  const imgSource = rawData ? rawData : resolveAsset(adventure_data.image);
  return (
    <Section
      fill
      title="Exploration"
      buttons={!props.hide_status && <DroneStatus
        drone_integrity={drone_integrity}
        drone_max_integrity={drone_max_integrity}
      />}>
      <Stack>
        <Stack.Item>
          <BlockQuote preserveWhitespace>
            {adventure_data.description}
          </BlockQuote>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <img
            src={imgSource}
            height="100px"
            width="200px"
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
            }} />
          <Stack vertical>
            <Stack.Divider />
            <Stack.Item grow />
            {!!adventure_data.choices && adventure_data.choices.map(choice => (
              <Stack.Item key={choice.key}>
                <Button
                  fluid
                  content={choice.text}
                  textAlign="center"
                  onClick={() => act('adventure_choice', { choice: choice.key })} />
              </Stack.Item>
            ))}
            <Stack.Item grow />
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const DroneScreen = (props: {
  drone: ActiveDrone & DroneData,
}) => {
  const { drone } = props;

  switch (drone.drone_status) {
    case DroneStatusEnum.Busy:
      return <TimeoutScreen drone={drone} />;
    case DroneStatusEnum.Idle:
    case DroneStatusEnum.Travel:
      return <TravelTargetSelectionScreen drone={drone} />;
    case DroneStatusEnum.Adventure:
      return (<AdventureScreen
        adventure_data={drone.adventure_data}
        drone_integrity={drone.drone_integrity}
        drone_max_integrity={drone.drone_max_integrity}
      />);
    case DroneStatusEnum.Exploration:
      if (drone.event) {
        return <EventScreen drone={drone} event={drone.event} />;
      }
      else {
        return <ExplorationScreen drone={drone} />;
      }
  }
};

const ExodroneConsoleContent = (props, context) => {
  const { data } = useBackend<ExodroneConsoleData>(context);

  if (!data.drone) {
    return <DroneSelectionSection all_drones={data.all_drones} />;
  }

  const { drone_log } = data;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack vertical fill grow={2}>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item>
                <EquipmentGrid drone={data} />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <DroneScreen drone={data} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item height={10}>
        <Section title="Drone Log" fill scrollable>
          <LabeledList>
            {drone_log.map((log_line, ix) => (
              <LabeledList.Item key={log_line} label={`Entry ${ix + 1}`}>
                {log_line}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

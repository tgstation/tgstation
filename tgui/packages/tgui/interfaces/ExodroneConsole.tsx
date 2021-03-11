/* eslint-disable max-len */
import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, Flex, Icon, LabeledList, Modal, NoticeBox, ProgressBar, Section, Stack, Tooltip } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import { formatTime } from '../format';
import { map, toKeyedArray } from '../../common/collections';
import { IconStack } from '../components/Icon';
import nt_logo from '../assets/bg-nanotrasen.svg';
import { MiningVendor } from './MiningVendor';


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

type ExodroneConsoleData = {
  signal_lost: boolean,
  drone: boolean,
  all_drones?: Array<DroneBasicData>
  drone_status?: DroneStatusEnum,
  drone_name?: string,
  drone_integrity?: number,
  drone_max_integrity?: number,
  drone_travel_coefficent?: number,
  drone_log?: Array<string>,
  configurable?: boolean,
  cargo?: Array<CargoData>,
  can_travel?: boolean,
  sites?: Array<SiteData>,
  site?: SiteData,
  travel_time?: number,
  travel_time_left?: number,
  wait_time_left?: number,
  wait_message?: string,
  event?: FullEventData,
  adventure_data?: AdventureData,
  // ui_static_data
  all_tools: Record<string, string>,
  all_bands: Record<string, string>
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
    <Modal backgroundColor="red" textAlign="center" width={30} height={22} p={0} style={{ "border-radius": "5%" }}>
      <img src={nt_logo} width={64} height={64} />
      <Box backgroundColor="black" textColor="red" fontSize={2} style={{ "border-radius": "-10%" }}>CONNECTION LOST</Box>
      <Box p={2} italic>
        Connection to exploration drone interrupted.
        Please contact nearest Nanotrasen Exploration Division
        representative for further instructions.
      </Box>
      <Icon name="exclamation-triangle" textColor="black" size={5} />
      <Box><Button color="danger" style={{ "border": "1px solid black" }} onClick={() => act("confirm_signal_lost")}>Confirm</Button></Box>
    </Modal>);
};

const DroneSelectionSection = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    all_drones,
  } = data;

  return (
    <Section title="Exploration Drone Listing">
      <Stack vertical>
        {all_drones.map(drone => (
          <Stack.Item key={drone.ref}>
            <Section title={drone.name}>
              <Stack vertical>
                <Stack.Item>
                  {drone.description}
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  {drone.controlled ? "Controlled by another console." : <Button onClick={() => act("select_drone", { "drone_ref": drone.ref })}>Assume Control</Button>}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        ))}
      </Stack>
    </Section>);
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

  return (
    <Modal>
      <Stack vertical pr={2}>
        <Stack.Item>
          Select Tool:
        </Stack.Item>
        <Stack.Item>
          <Stack textAlign="center">
            {Object.keys(all_tools).map(tool_name => (
              <Stack.Item key={tool_name}>
                <Button onClick={() => {
                  setChoosingTools(false);
                  act("add_tool", { tool_type: tool_name });
                }} width={6} height={6}>
                  <Stack vertical>
                    <Stack.Item>
                      {tool_name}
                    </Stack.Item>
                    <Stack.Item textAlign="right">
                      <Icon name={all_tools[tool_name]} size={3} />
                    </Stack.Item>
                  </Stack>
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
      </Stack>
    </Modal>);
};

const EquipmentBox = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    configurable,
    all_tools = {},
  } = data;
  const cargo = props.cargo;
  const boxContents = cargo => {
    switch (cargo.type) {
      case "tool": // Tool icon+Remove button if configurable
        return (
          <Flex direction="column">
            {!!configurable && (
              <Flex.Item textAlign="right">
                <Button onClick={() => act("remove_tool", { tool_type: cargo.name })} color="danger" tooltip="Remove Tool">-</Button>
              </Flex.Item>)}
            <Flex.Item grow>
              <Icon
                name={all_tools[cargo.name]}
                size={3}
                pt={configurable ? 0 : 2} />
            </Flex.Item>
          </Flex>);
      case "cargo":// Jettison button.
        return (
          <Flex direction="column">
            <Flex.Item textAlign="right">
              <Button onClick={() => act("jettison", { target_ref: cargo.ref })} color="danger" tooltip={`Jettison ${cargo.name}`}>-</Button>
            </Flex.Item>
            <Flex.Item>
              <Icon name="box" size={3} />
            </Flex.Item>
          </Flex>);
      case "empty":
        return "";
    }
  };
  return (<Box width={5} height={5} style={{ border: '2px solid black' }} textAlign="center">{boxContents(cargo)}</Box>);
};


const EquipementGrid = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    cargo,
    configurable,
  } = data;
  const [
    choosingTools,
    setChoosingTools,
  ] = useLocalState(context, 'choosingTools', false);
  return (
    <Section title="Cargo">
      <Stack.Item>
        {!!configurable && (
          <Button onClick={() => { setChoosingTools(true); }} fluid>
            Install Tool
          </Button>)}
      </Stack.Item>
      <Stack.Item>
        <Flex wrap="wrap" width={10}>
          {cargo.map(cargo_element =>
            (<EquipmentBox key={cargo_element.name} cargo={cargo_element} />))}
        </Flex>
      </Stack.Item>
    </Section>
  );
};

const DroneStatus = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    drone_integrity,
    drone_max_integrity,
  } = data;

  return (
    <Stack>
      <Stack.Item>Integrity:</Stack.Item>
      <Stack.Item grow><ProgressBar
        ranges={{
          good: [0.7 * drone_max_integrity, drone_max_integrity],
          average: [0.4 * drone_max_integrity, 0.7 * drone_max_integrity],
          bad: [-Infinity, 0.4 * drone_max_integrity],
        }}
        value={drone_integrity}
        maxValue={drone_max_integrity} />
      </Stack.Item>
    </Stack>);
};

const TravelTargetSelectionScreen = (props, context) => {
  // List of sites and eta travel times to each
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    sites,
    site,
    can_travel,
    drone_travel_coefficent,
    all_bands,
  } = data;

  const travel_cost = target_site => {
    if (site) {
      return Math.max(Math.abs(site.distance - target_site.distance), 1) * drone_travel_coefficent;
    }
    else {
      return target_site.distance * drone_travel_coefficent;
    }
  };

  const [
    travelScreenShown,
    setTravelScreenShown,
  ] = useLocalState(context, 'travelScreenShown', false);

  const travel_to = ref => {
    setTravelScreenShown(false);
    act("start_travel", { "target_site": ref });
  };

  return (
    <Section title="Travel Destinations" fill scrollable buttons={props.showCancelButton ? (<Button onClick={() => setTravelScreenShown(false)}>Cancel</Button>) : ""}>
      {site && (<Section title="Home" buttons={
        <Box><Button onClick={() => travel_to(null)} disabled={!can_travel}>Launch!</Button> ETA: {formatTime(site.distance * drone_travel_coefficent, "short")}</Box>
      } />)}
      {sites.filter(destination => !site || destination.ref !== site.ref).map(destination => (
        <Section key={destination.ref} title={destination.name} buttons={
          <Box><Button onClick={() => travel_to(destination.ref)} disabled={!can_travel}>Launch!</Button> ETA: {formatTime(travel_cost(destination), "short")}</Box>
        }>
          <LabeledList>
            <LabeledList.Item label="Description">{destination.description}</LabeledList.Item>
            <LabeledList.Divider />
            {Object.keys(all_bands).filter(band => (destination.band_info[band] !== undefined && destination.band_info[band] !== 0)).map(band => (<LabeledList.Item key={band} label={band}>{destination.band_info[band]}</LabeledList.Item>))}
          </LabeledList>
        </Section>
      ))}
    </Section>
  );
};

const TravelScreen = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    travel_time,
    travel_time_left,
  } = data;
  return (
    <Section fill title="Travel">
      <Stack vertical fill textAlign="center" justify="center">
        <Stack.Item>Traveling</Stack.Item>
        <Stack.Item>ETA: {formatTime(travel_time_left)}</Stack.Item>
      </Stack>
    </Section>);
};

const TimeoutScreen = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    wait_time_left,
    wait_message,
  } = data;
  return (
    <Section fill title="Exploration">
      <Stack vertical fill justify="center" textAlign="center">
        <Stack.Item>{wait_message}</Stack.Item>
        <Stack.Item>ETA: {formatTime(wait_time_left)}</Stack.Item>
      </Stack>
    </Section>);
};

const ExplorationScreen = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    site,
    event,
    sites,
  } = data;

  const [
    travelScreenShown,
    setTravelScreenShown,
  ] = useLocalState(context, 'travelScreenShown', false);

  if (travelScreenShown)
  { return (<TravelTargetSelectionScreen showCancelButton />); }
  // List of repeatables, Explore button. Last found event popup and continue exploring. Return home button.
  return (
    <Section fill title="Exploration">
      <Stack vertical fill>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Site">{site.name}</LabeledList.Item>
            <LabeledList.Item label="Description">{site.description}</LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act("explore")}>Explore!</Button>
        </Stack.Item>
        {site.events.map(e => (
          <Stack.Item key={site.ref}>
            <Button onClick={() => act("explore_event", { target_event: e.ref })}>{e.name}</Button>
          </Stack.Item>))}
        <Stack.Item>
          <Button onClick={() => setTravelScreenShown(true)}>Travel</Button>
        </Stack.Item>
      </Stack>
    </Section>);
};

const EventScreen = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    event,
  } = data;
  return (
    <Section fill title="Exploration">
      <Stack vertical fill textAlign="center">
        <Stack.Item>
          <img src={resolveAsset(event.image)}
            height="100px"
            width="200px"
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
            }} />
        </Stack.Item>
        <Stack.Item>
          <BlockQuote style={{ "white-space": "pre-wrap" }}>{event.description}</BlockQuote>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Button disabled={!event.action_enabled} onClick={() => act("start_event")}>{event.action_text}</Button>
            </Stack.Item>
            {!!event.skippable && (<Stack.Item><Button onClick={() => act("skip_event")}>{event.ignore_text}</Button></Stack.Item>)}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>);
};

const AdventureScreen = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    adventure_data,
  } = data;
  return (
    <Section fill title="Exploration">
      <Stack vertical fill textAlign="center">
        <Stack.Item>
          <img src={adventure_data.raw_image ? adventure_data.raw_image : resolveAsset(adventure_data.image)}
            height="100px"
            width="200px"
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
            }} />
        </Stack.Item>
        <Stack.Item>
          <BlockQuote style={{ "white-space": "pre-wrap" }}>{adventure_data.description}</BlockQuote>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            <Stack.Divider />
            {!!adventure_data.choices && adventure_data.choices.map(choice => (
              <Stack.Item key={choice.key}><Button
                content={choice.text}
                textAlign="center"
                onClick={() => act('adventure_choice', { choice: choice.key })}
              />
              </Stack.Item>))}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>);
};

const DroneScreen = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    drone_status,
    event,
  } = data;
  switch (drone_status) {
    case "idle":
      return (<TravelTargetSelectionScreen />);
    case "travel":
      return (<TravelScreen />);
    case "adventure":
      return (<AdventureScreen />);
    case "exploration":
      if (event)
      { return (<EventScreen />); }
      else
      { return (<ExplorationScreen />); }
    case "busy":
      return (<TimeoutScreen />);
  }
};

const ExodroneConsoleContent = (props, context) => {
  const { act, data } = useBackend<ExodroneConsoleData>(context);
  const {
    drone,
    drone_name,
    drone_log,
  } = data;

  if (!drone)
  { return (<DroneSelectionSection />); }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section fill title={`${drone_name} Feed`} buttons={
          <Stack>
            <Stack.Item>
              <Button.Confirm
                icon="bomb"
                content="Self-Destruct"
                color="bad"
                onClick={() => act('self_destruct')} />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="plug"
                content="Disconnect"
                onClick={() => act('end_control')} />
            </Stack.Item>
          </Stack>
        }>
          <DroneStatus />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack vertical fill grow={2}>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item>
                <EquipementGrid />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <DroneScreen />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow={1}>
        <Section title="Drone Log" fill scrollable>
          <LabeledList>
            {drone_log.map((log_line, ix) => (
              <LabeledList.Item key={log_line} label={`Entry ${ix+1 }`}>
                {log_line}
              </LabeledList.Item>))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

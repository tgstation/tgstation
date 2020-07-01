import { useBackend, useSharedState } from '../backend';
import { Icon, ProgressBar, Tabs } from '../components';
import { Window } from '../layouts';

const directionToIcon = {
  "north": 0,
  "northeast": 45,
  "east": 90,
  "southeast": 135,
  "south": 180,
  "southwest": 225,
  "west": 270,
  "northwest": 315,
};

export const BluespaceLocator = (props, context) => {
  const [tab, setTab] = useSharedState(context, "tab", "beacon");
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tab === "implant"}
            onClick={() => setTab("implant")}>
            Implants
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === "beacon"}
            onClick={() => setTab("beacon")}>
            Teleporter Beacons
          </Tabs.Tab>
        </Tabs>
        {tab === "beacon" && (
          <TeleporterBeacons />
        )
        || tab === "implant" && (
          <TrackingImplants />
        )}
      </Window.Content>
    </Window>
  );
};

const TeleporterBeacons = (props, context) => {
  const { data } = useBackend(context);

  const { telebeacons } = data;

  return (
    telebeacons.map(beacon => (
      <SignalLocator
        key={beacon.name}
        name={beacon.name}
        distance={beacon.distance}
        direction={directionToIcon[beacon.direction]} />
    ))
  );
};

const TrackingImplants = (props, context) => {
  const { data } = useBackend(context);

  const { trackimplants } = data;

  return (
    trackimplants.map(implant => (
      <SignalLocator
        key={implant.name}
        name={implant.name}
        distance={implant.distance}
        direction={directionToIcon[implant.direction]} />
    ))
  );
};

const SignalLocator = (props, context) => {
  const {
    name,
    direction,
    distance,
  } = props;
  if (distance >= 20) {
    return;
  }
  return (
    <ProgressBar
      mb={1}
      value={20 - distance}
      minValue={0}
      maxValue={20}
      ranges={{
        red: [0, 5],
        yellow: [5, 15],
        green: [15, 20],
      }}>
      {name}
      <Icon
        ml={2}
        name="arrow-up"
        rotation={direction} />
    </ProgressBar>
  );
};

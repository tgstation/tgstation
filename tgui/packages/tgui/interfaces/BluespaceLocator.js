import { useBackend, useSharedState } from '../backend';
import { Icon, ProgressBar, Tabs } from '../components';
import { Window } from '../layouts';

const directionToIcon = {
  north: 0,
  northeast: 45,
  east: 90,
  southeast: 135,
  south: 180,
  southwest: 225,
  west: 270,
  northwest: 315,
};

export const BluespaceLocator = (props, context) => {
  const [tab, setTab] = useSharedState(context, 'tab', 'implant');
  return (
    <Window width={300} height={300}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tab === 'implant'}
            onClick={() => setTab('implant')}>
            Implants
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 'beacon'}
            onClick={() => setTab('beacon')}>
            Teleporter Beacons
          </Tabs.Tab>
        </Tabs>
        {(tab === 'beacon' && <TeleporterBeacons />) ||
          (tab === 'implant' && <TrackingImplants />)}
      </Window.Content>
    </Window>
  );
};

const TeleporterBeacons = (props, context) => {
  const { data } = useBackend(context);
  const { telebeacons } = data;
  return telebeacons.map((beacon) => (
    <SignalLocator
      key={beacon.name}
      name={beacon.name}
      distance={beacon.distance}
      direction={directionToIcon[beacon.direction]}
    />
  ));
};

const TrackingImplants = (props, context) => {
  const { data } = useBackend(context);
  const { trackimplants } = data;
  return trackimplants.map((implant) => (
    <SignalLocator
      key={implant.name}
      name={implant.name}
      distance={implant.distance}
      direction={directionToIcon[implant.direction]}
    />
  ));
};

const SignalLocator = (props, context) => {
  const { data } = useBackend(context);
  const { trackingrange } = data;
  const { name, direction, distance } = props;
  return (
    <ProgressBar
      mb={1}
      value={trackingrange - distance}
      minValue={0}
      maxValue={trackingrange}
      ranges={{
        red: [0, trackingrange / 3],
        yellow: [trackingrange / 3, 2 * (trackingrange / 3)],
        green: [2 * (trackingrange / 3), trackingrange],
      }}>
      {name}
      <Icon ml={2} name="arrow-up" rotation={direction} />
    </ProgressBar>
  );
};

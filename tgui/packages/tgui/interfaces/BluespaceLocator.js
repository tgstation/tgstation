import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Section, Divider, Collapsible, Icon } from '../components';
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
  return (
    <Window resizable>
      <Window.Content scrollable>
        <TeleporterBeacons />
        <Divider />
        <TrackingImplants />
      </Window.Content>
    </Window>
  );
};

const TeleporterBeacons = (props, context) => {
  const { data } = useBackend(context);

  const { telebeacons } = data;

  return (
    <Section title="Teleporter Beacons">
      {telebeacons.map(beacon => (
        <SignalLocator
          key={beacon.name}
          name={beacon.name}
          distance={beacon.distance}
          direction={directionToIcon[beacon.direction]} />
      )
      )}
    </Section>
  );
};

const TrackingImplants = (props, context) => {
  const { data } = useBackend(context);

  const { trackimplants } = data;

  return (
    <Section title="Tracking Implants">
      {trackimplants.map(implant => (
        <SignalLocator
          key={implant.name}
          name={implant.name}
          distance={implant.distance}
          direction={directionToIcon[implant.direction]} />
      )
      )}
    </Section>
  );
};

const SignalLocator = (props, context) => {
  const {
    name,
    direction,
    distance,
  } = props;
  return (
    <Collapsible
      key={name}
      title={name}>
      Direction :
      <Icon
        name="arrow-up"
        rotation={direction} />
      , {distance}
    </Collapsible>
  );
};

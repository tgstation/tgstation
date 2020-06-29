import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Section, Divider, Collapsible, Icon, ProgressBar } from '../components';
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
  var {
    name,
    direction,
    distance,
  } = props;
  if (distance >= 20){
    return
  }
  return (
    <Collapsible
      key={name}
      title={name}>
      <ProgressBar
        value={20 - distance}
        minValue={0}
        maxValue={20}
        children={
          <Icon
          name="arrow-up"
          rotation={direction}
         />
        }
        ranges={{
          red: [0,5],
          yellow: [5,15],
          green: [15,20],
        }
}
      />
    </Collapsible>
  );
};

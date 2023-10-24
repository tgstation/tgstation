import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Section, LabeledList } from '../components';
import { Window } from '../layouts';

type Data = {
  sensorStatus: BooleanLike;
  operatingStatus: number;
  inboundPlatform: number;
  outboundPlatform: number;
};

type Props = {
  context: any;
};

export const CrossingSignal = (props, context) => {
  const { act, data } = useBackend<Data>(context);

  const { sensorStatus, operatingStatus, inboundPlatform, outboundPlatform } =
    data;

  return (
    <Window title="Crossing Signal" width={400} height={175} theme="dark">
      <Window.Content>
        <Section title="System Status">
          <LabeledList>
            <LabeledList.Item
              label="Operating Status"
              color={operatingStatus ? 'bad' : 'good'}>
              {operatingStatus ? 'Degraded' : 'Normal'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Sensor Status"
              color={sensorStatus ? 'good' : 'bad'}>
              {sensorStatus ? 'Connected' : 'Error'}
            </LabeledList.Item>
            <LabeledList.Item label="Inbound Platform">
              {inboundPlatform}
            </LabeledList.Item>
            <LabeledList.Item label="Outbound Platform">
              {outboundPlatform}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

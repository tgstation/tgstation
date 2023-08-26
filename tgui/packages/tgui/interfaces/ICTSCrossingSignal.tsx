import { useBackend } from '../backend';
import { Section, LabeledList, Flex } from '../components';
import { Window } from '../layouts';

type ICTSData = {
  sensorStatus: boolean;
  operatingStatus: number;
  inboundPlatform: number;
  outboundPlatform: number;
};

type Props = {
  context: any;
};

export const ICTSCrossingSignal = (props, context) => {
  const { act, data } = useBackend<ICTSData>(context);

  const { sensorStatus, operatingStatus, inboundPlatform, outboundPlatform } =
    data;

  return (
    <Window title="ICTS Crossing Signal" width={400} height={175} theme="dark">
      <Window.Content>
        <Flex direction="row">
          <Flex.Item>
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
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

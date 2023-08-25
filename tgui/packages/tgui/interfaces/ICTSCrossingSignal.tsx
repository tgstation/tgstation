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
    <Window title="ICTS Crossing Signal" width={830} height={430} theme="dark">
      <Window.Content>
        <Flex direction="row">
          <Flex.Item width={350} px={0.5}>
            <Section title="System Status">
              <LabeledList>
                <LabeledList.Item
                  label="Operating Status"
                  color={operatingStatus ? 'good' : 'bad'}>
                  {operatingStatus ? 'Normal' : 'Degraded'}
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

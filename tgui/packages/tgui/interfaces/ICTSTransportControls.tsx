import { useBackend } from '../backend';
import { BooleanLike } from 'common/react';
import { Section, NoticeBox, LabeledList, ProgressBar } from '../components';
import { toFixed } from 'common/math';
import { Window } from '../layouts';

type ICTSData = {
  transportId: string;
  controllerActive: number;
  controllerOperational: BooleanLike;
  travelDirection: number;
  destinationPlatform: string;
  idlePlatform: string;
  recoveryMode: BooleanLike;
  currentSpeed: number;
  currentLoad: number;
};

type Props = {
  context: any;
};

export const ICTSTransportControls = (props, context) => {
  const { act, data } = useBackend<ICTSData>(context);

  const {
    transportId,
    controllerActive,
    controllerOperational,
    travelDirection,
    destinationPlatform,
    idlePlatform,
    recoveryMode,
    currentSpeed,
    currentLoad,
  } = data;

  return (
    <Window
      title="ICTS Transport Controller"
      width={480}
      height={430}
      theme="dark">
      <Window.Content>
        <Section title="System Status">
          <LabeledList>
            <LabeledList.Item label="System ID">{transportId}</LabeledList.Item>
            <LabeledList.Item
              label="Controller Queue"
              color={controllerActive ? 'blue' : 'good'}>
              {controllerActive ? 'Processing' : 'Ready'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Mechanical Status"
              color={controllerOperational ? 'good' : 'bad'}>
              {controllerOperational ? 'Normal' : 'Fault'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Processor Status"
              color={recoveryMode ? 'average' : 'good'}>
              {recoveryMode ? 'Overload' : 'Normal'}
            </LabeledList.Item>
            <LabeledList.Item label="Processor Load">
              <ProgressBar
                value={currentLoad}
                minValue={0}
                maxValue={15}
                ranges={{
                  good: [-Infinity, 5],
                  average: [5, 7.5],
                  bad: [7.5, Infinity],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Current Speed">
              <ProgressBar
                value={currentSpeed}
                minValue={0}
                maxValue={32}
                ranges={{
                  good: [28, Infinity],
                  average: [24, 28],
                  bad: [0.1, 24],
                  white: [-Infinity, 0],
                }}>
                {toFixed(currentSpeed * 2.25, 0) + ' km/h'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Trip Control">
          <LabeledList>
            <LabeledList.Item label="Direction">
              {travelDirection === 4 ? 'Outbound' : 'Inbound'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Idle Platform"
              color={controllerActive ? '' : 'blue'}>
              {idlePlatform}
            </LabeledList.Item>
            <LabeledList.Item
              label="Destination Platform"
              color={controllerActive ? 'blue' : ''}>
              {destinationPlatform}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Configuration">
          <NoticeBox>Coming soon: make all your dreams come true.</NoticeBox>
        </Section>
      </Window.Content>
    </Window>
  );
};

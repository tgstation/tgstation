import { useBackend, useLocalState } from '../backend';
import { BooleanLike } from 'common/react';
import { Section, NoticeBox, Dropdown, LabeledList, ProgressBar, Flex, Button } from '../components';
import { toFixed } from 'common/math';
import { Window } from '../layouts';

type TransportData = {
  transportId: string;
  controllerActive: number;
  controllerOperational: BooleanLike;
  travelDirection: number;
  destinationPlatform: string;
  idlePlatform: string;
  recoveryMode: BooleanLike;
  currentSpeed: number;
  currentLoad: number;
  bypassSensors: boolean;
  destinations: TramDestination[];
};

type Props = {
  context: any;
};

type TramDestination = {
  name: string;
  dest_icons: string[];
  id: number;
};

export const TramController = (props, context) => {
  const { act, data } = useBackend<TransportData>(context);

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
    bypassSensors,
    destinations = [],
  } = data;

  const [tripDestination, setTripDestination] = useLocalState(
    context,
    'TramDestination',
    ''
  );

  return (
    <Window title="Tram Controller" width={695} height={330} theme="dark">
      <Window.Content>
        <Flex direction="row">
          <Flex.Item width={350} px={0.5}>
            <Section title="System Status">
              <LabeledList>
                <LabeledList.Item label="System ID">
                  {transportId}
                </LabeledList.Item>
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
            <Section title="Location Data">
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
          </Flex.Item>
          <Flex.Item width={480} px={0.5}>
            <Section title="Controls">
              <NoticeBox>
                Nanotrasen is not responsible for any injuries or fatalities
                caused by usage of the tram.
              </NoticeBox>
              <Button
                icon="square"
                color="bad"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="E-Stop"
                onClick={() => act('estop', {})}
              />
              <Button
                icon="pause"
                color="yellow"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="Reset"
                onClick={() => act('reset', {})}
              />
              <Button
                icon="play"
                color="green"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="Automatic"
                onClick={() =>
                  act('dispatch', {
                    'tripDestination': tripDestination,
                  })
                }
              />
              <Button
                icon="location-dot"
                color="blue"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="Manual: Destination"
                onClick={() =>
                  act('dispatch', {
                    'tripDestination': tripDestination,
                  })
                }
              />
              <Dropdown
                width="99%"
                options={destinations.map((id) => id.name)}
                selected={tripDestination}
                displayText={tripDestination || 'Pick a Destination'}
                onSelected={(value) => setTripDestination(value)}
              />
            </Section>
            <Section title="Operational">
              <NoticeBox>
                You can&apos;t cut back on Engineering. YOU WILL REGRET THIS!
              </NoticeBox>
              <Button
                icon="bars"
                color="blue"
                my={1}
                lineHeight={2}
                minWidth={10}
                minHeight={2}
                textAlign="center"
                content="Open Doors"
                onClick={() => act('dopen', {})}
              />
              <Button
                icon="bars"
                color="blue"
                my={1}
                lineHeight={2}
                minWidth={10}
                minHeight={2}
                textAlign="center"
                content="Close Doors"
                onClick={() => act('dclose', {})}
              />
              <Button
                icon="bars"
                color={bypassSensors ? 'good' : 'bad'}
                my={1}
                lineHeight={2}
                minWidth={11}
                minHeight={2}
                textAlign="center"
                content="Door Sensors"
                onClick={() => act('togglesensors', {})}
              />
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

import { useBackend, useLocalState } from '../backend';
import { BooleanLike } from 'common/react';
import { Section, NoticeBox, Dropdown, LabeledList, ProgressBar, Flex, Button } from '../components';
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
    destinations = [],
  } = data;

  const [tripDestination, setTripDestination] = useLocalState(
    context,
    'TramDestination',
    ''
  );

  return (
    <Window
      title="ICTS Transport Controller"
      width={830}
      height={430}
      theme="dark">
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
            <Section title="Configuration">
              <NoticeBox>
                You can&apos;t cut back on Engineering. YOU WILL REGRET THIS!
              </NoticeBox>
            </Section>
            <Section title="Controls">
              <Button
                icon="square"
                color="bad"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="E-Stop"
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
              />
              <Button
                icon="play"
                color="blue"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="Start: Automatic"
              />
              <Button
                icon="location-dot"
                color="blue"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="Start: Destination"
                onClick={() =>
                  act('dispatch', {
                    'tripDestination': tripDestination,
                  })
                }
              />
              <Dropdown
                width="100%"
                options={destinations.map((id) => id.name)}
                selected={tripDestination}
                displayText={tripDestination || 'Pick a Destination'}
                onSelected={(value) => setTripDestination(value)}
              />
            </Section>
            <Section title="Operational">
              <NoticeBox>
                Nanotrasen is not responsible for any injuries or fatalities
                caused by usage of the tram.
              </NoticeBox>
              <Button
                icon="person"
                color="green"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="Stop for Humans"
              />
              <Button
                icon="cat"
                color="red"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="Stop for Felinids"
              />
              <Button
                icon="bars"
                color="blue"
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="Toggle Doors"
              />
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

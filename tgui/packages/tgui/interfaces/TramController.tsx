import { useBackend, useLocalState } from '../backend';
import { BooleanLike } from 'common/react';
import { Section, NoticeBox, Dropdown, LabeledList, ProgressBar, Flex, Button } from '../components';
import { toFixed } from 'common/math';
import { Window } from '../layouts';

type Data = {
  transportId: string;
  controllerActive: number;
  controllerOperational: BooleanLike;
  travelDirection: number;
  destinationPlatform: string;
  idlePlatform: string;
  recoveryMode: BooleanLike;
  currentSpeed: number;
  currentLoad: number;
  statusSF: BooleanLike;
  statusCE: BooleanLike;
  statusES: BooleanLike;
  statusPD: BooleanLike;
  statusDR: BooleanLike;
  statusCL: BooleanLike;
  statusBS: BooleanLike;
  destinations: TramDestination[];
};

type TramDestination = {
  name: string;
  dest_icons: string[];
  id: number;
};

export const TramController = (props, context) => {
  const { act, data } = useBackend<Data>(context);

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
    statusSF,
    statusCE,
    statusES,
    statusPD,
    statusDR,
    statusCL,
    statusBS,
    destinations = [],
  } = data;

  const [tripDestination, setTripDestination] = useLocalState(
    context,
    'TramDestination',
    ''
  );

  return (
    <Window title="Tram Controller" width={800} height={325} theme="dark">
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
                minWidth={7}
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
                minWidth={7}
                minHeight={2}
                textAlign="center"
                content="Reset"
                onClick={() => act('reset', {})}
              />
              <Button
                icon="play"
                color="green"
                disabled={statusES || statusSF}
                my={1}
                lineHeight={2}
                minWidth={21}
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
                width="97%"
                options={destinations.map((id) => id.name)}
                selected={tripDestination}
                displayText={tripDestination || 'Pick a Destination'}
                onSelected={(value) => setTripDestination(value)}
              />
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
                color={statusBS ? 'good' : 'bad'}
                my={1}
                lineHeight={2}
                minWidth={15}
                minHeight={2}
                textAlign="center"
                content="Bypass Door Sensors"
                onClick={() => act('togglesensors', {})}
              />
            </Section>
            <Section title="Operational">
              <Button
                color={statusES ? 'red' : 'transparent'}
                my={1}
                lineHeight={2}
                minWidth={6}
                minHeight={2}
                textAlign="center"
                content="ESTOP"
              />
              <Button
                color={statusSF ? 'yellow' : 'transparent'}
                my={1}
                lineHeight={2}
                minWidth={6}
                minHeight={2}
                textAlign="center"
                content="FAULT"
              />
              <Button
                color={statusCE ? 'teal' : 'transparent'}
                my={1}
                lineHeight={2}
                minWidth={6}
                minHeight={2}
                textAlign="center"
                content="COMMS"
              />
              <Button
                color={statusPD ? 'blue' : 'transparent'}
                my={1}
                lineHeight={2}
                minWidth={5}
                minHeight={2}
                textAlign="center"
                content="RQST"
              />
              <Button
                color={statusDR ? 'transparent' : 'blue'}
                my={1}
                lineHeight={2}
                minWidth={6}
                minHeight={2}
                textAlign="center"
                content="DOORS"
              />
              <Button
                color={statusCL ? 'blue' : 'transparent'}
                my={1}
                lineHeight={2}
                minWidth={6}
                minHeight={2}
                textAlign="center"
                content="BUSY"
              />
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

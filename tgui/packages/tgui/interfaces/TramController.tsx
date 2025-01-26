import { useState } from 'react';
import {
  Button,
  Dropdown,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
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

export const TramController = (props) => {
  const { act, data } = useBackend<Data>();

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

  const [tripDestination, setTripDestination] = useState('');

  return (
    <Window title="Tram Controller" width={778} height={327} theme="dark">
      <Window.Content>
        <Stack>
          <Stack.Item grow={4}>
            <Section title="System Status">
              <LabeledList>
                <LabeledList.Item label="System ID">
                  {transportId}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Controller Queue"
                  color={controllerActive ? 'blue' : 'good'}
                >
                  {controllerActive ? 'Processing' : 'Ready'}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Mechanical Status"
                  color={controllerOperational ? 'good' : 'bad'}
                >
                  {controllerOperational ? 'Normal' : 'Fault'}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Processor Status"
                  color={recoveryMode ? 'average' : 'good'}
                >
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
                    }}
                  >
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
                  color={controllerActive ? '' : 'blue'}
                >
                  {idlePlatform}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Destination Platform"
                  color={controllerActive ? 'blue' : ''}
                >
                  {destinationPlatform}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow={6}>
            <Section title="Controls">
              <NoticeBox>
                Nanotrasen is not responsible for any injuries or fatalities
                caused by usage of the tram.
              </NoticeBox>
              <Button
                icon="arrows-rotate"
                color="yellow"
                my={1}
                lineHeight={2}
                width="28%"
                minHeight={2}
                textAlign="center"
                onClick={() => act('reset', {})}
              >
                Reset/Enable
              </Button>
              <Button
                icon="square"
                color="bad"
                my={1}
                lineHeight={2}
                width="28%"
                minHeight={2}
                textAlign="center"
                onClick={() => act('estop', {})}
              >
                E-Stop/Disable
              </Button>
              <Button
                icon="play"
                color="green"
                disabled={statusES || statusSF}
                my={1}
                lineHeight={2}
                width="42%"
                minHeight={2}
                textAlign="center"
                onClick={() =>
                  act('dispatch', {
                    tripDestination: tripDestination,
                  })
                }
              >
                Start: Destination
              </Button>
              <Dropdown
                width="98.5%"
                options={destinations.map((id) => id.name)}
                selected={tripDestination}
                placeholder="Pick a Destination"
                onSelected={(value) => setTripDestination(value)}
              />
              <Button
                icon="bars"
                color="blue"
                my={1}
                lineHeight={2}
                width="25%"
                minHeight={2}
                textAlign="center"
                onClick={() => act('dopen', {})}
              >
                Open Doors
              </Button>
              <Button
                icon="bars"
                color="blue"
                my={1}
                lineHeight={2}
                width="25%"
                minHeight={2}
                textAlign="center"
                onClick={() => act('dclose', {})}
              >
                Close Doors
              </Button>
              <Button
                icon="bars"
                color={statusBS ? 'good' : 'bad'}
                my={1}
                lineHeight={2}
                width="48%"
                minHeight={2}
                textAlign="center"
                onClick={() => act('togglesensors', {})}
              >
                Bypass Door Sensors
              </Button>
            </Section>
            <Section title="Operational">
              <Button
                color={statusES ? 'red' : 'transparent'}
                my={1}
                lineHeight={2}
                width="16%"
                minHeight={2}
                textAlign="center"
              >
                ESTOP
              </Button>
              <Button
                color={statusSF ? 'yellow' : 'transparent'}
                my={1}
                lineHeight={2}
                width="16%"
                minHeight={2}
                textAlign="center"
              >
                FAULT
              </Button>
              <Button
                color={statusCE ? 'teal' : 'transparent'}
                my={1}
                lineHeight={2}
                width="16%"
                minHeight={2}
                textAlign="center"
              >
                COMMS
              </Button>
              <Button
                color={statusPD ? 'blue' : 'transparent'}
                my={1}
                lineHeight={2}
                width="16%"
                minHeight={2}
                textAlign="center"
              >
                RQST
              </Button>
              <Button
                color={statusDR ? 'transparent' : 'blue'}
                my={1}
                lineHeight={2}
                width="16%"
                minHeight={2}
                textAlign="center"
              >
                DOORS
              </Button>
              <Button
                color={statusCL ? 'blue' : 'transparent'}
                my={1}
                lineHeight={2}
                width="16%"
                minHeight={2}
                textAlign="center"
              >
                BUSY
              </Button>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

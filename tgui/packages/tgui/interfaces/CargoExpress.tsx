import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { CargoCatalog } from './Cargo/CargoCatalog';

type Data = {
  locked: BooleanLike;
  points: number;
  using_beacon: BooleanLike;
  beaconzone: string;
  beaconName: string;
  beaconError: BooleanLike;
  canBuyBeacon: BooleanLike;
  hasBeacon: BooleanLike;
  canBeacon: BooleanLike;
  printMsg: string;
  message: string;
};

export function CargoExpress(props) {
  const { data } = useBackend<Data>();
  const { beaconError, canBeacon, message, locked } = data;

  return (
    <Window width={600} height={700}>
      <Window.Content>
        {locked ? (
          <Section fill>
            <Stack fill vertical textAlign={'center'} justify={'center'}>
              <Stack.Item bold color={'red'}>
                <Icon mb={3} name={'lock'} size={7.5} />
                <br />
                {`Swipe a Cargo Technician-level ID card to unlock this interface.`}
              </Stack.Item>
            </Stack>
          </Section>
        ) : (
          <Stack fill vertical g={0}>
            <NoticeBox color={beaconError || !canBeacon ? 'red' : 'blue'}>
              {message}
            </NoticeBox>
            <Stack.Item grow>
              <CargoExpressContent />
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
}

function CargoExpressContent(props) {
  const { act, data } = useBackend<Data>();
  const {
    hasBeacon,
    points,
    using_beacon,
    beaconzone,
    beaconName,
    canBuyBeacon,
    printMsg,
  } = data;

  return (
    <Stack fill vertical g={0}>
      <Stack.Item>
        <Section
          title="Cargo Express"
          buttons={
            <Box inline bold verticalAlign={'middle'}>
              <AnimatedNumber value={Math.round(points)} />
              {' credits'}
            </Box>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Landing Location">
              <Button selected={!using_beacon} onClick={() => act('LZCargo')}>
                Cargo Bay
              </Button>
              <Button
                selected={using_beacon}
                disabled={!hasBeacon}
                tooltip={beaconzone}
                onClick={() => act('LZBeacon')}
              >
                {beaconName}
              </Button>
              <Button
                disabled={!canBuyBeacon}
                onClick={() => act('printBeacon')}
              >
                {printMsg}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <CargoCatalog express />
      </Stack.Item>
    </Stack>
  );
}

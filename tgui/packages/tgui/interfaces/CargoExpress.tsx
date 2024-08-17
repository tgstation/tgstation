import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { CargoCatalog } from './Cargo/CargoCatalog';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type Data = {
  locked: BooleanLike;
  points: number;
  usingBeacon: BooleanLike;
  beaconzone: string;
  beaconName: string;
  canBuyBeacon: BooleanLike;
  hasBeacon: BooleanLike;
  printMsg: string;
  message: string;
};

export function CargoExpress(props) {
  const { data } = useBackend<Data>();
  const { locked } = data;

  return (
    <Window width={600} height={700}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox accessText="a Cargo Technician-level ID card" />
        {!locked && <CargoExpressContent />}
      </Window.Content>
    </Window>
  );
}

function CargoExpressContent(props) {
  const { act, data } = useBackend<Data>();
  const {
    hasBeacon,
    message,
    points,
    usingBeacon,
    beaconzone,
    beaconName,
    canBuyBeacon,
    printMsg,
  } = data;

  return (
    <>
      <Section
        title="Cargo Express"
        buttons={
          <Box inline bold>
            <AnimatedNumber value={Math.round(points)} />
            {' credits'}
          </Box>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Landing Location">
            <Button selected={!usingBeacon} onClick={() => act('LZCargo')}>
              Cargo Bay
            </Button>
            <Button
              selected={usingBeacon}
              disabled={!hasBeacon}
              onClick={() => act('LZBeacon')}
            >
              {beaconzone} ({beaconName})
            </Button>
            <Button disabled={!canBuyBeacon} onClick={() => act('printBeacon')}>
              {printMsg}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Notice">{message}</LabeledList.Item>
        </LabeledList>
      </Section>
      <CargoCatalog express />
    </>
  );
}

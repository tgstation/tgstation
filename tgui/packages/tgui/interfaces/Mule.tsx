import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Button,
  Dropdown,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type Data = {
  powerStatus: BooleanLike;
  cellPercent: number | null;
  load: BooleanLike;
  locked: BooleanLike;
  siliconUser: BooleanLike;
  mode: string;
  modeStatus: string;
  autoReturn: BooleanLike;
  autoPickup: BooleanLike;
  reportDelivery: BooleanLike;
  destination: string | null;
  destinationsList: string[];
  homeDestination: string | null;
  botId: string;
  allowPossession: BooleanLike;
  possessionEnabled: BooleanLike;
  paiInserted: BooleanLike;
};

const MuleControls = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    load,
    autoReturn,
    autoPickup,
    reportDelivery,
    destination,
    homeDestination,
    botId,
    allowPossession,
    possessionEnabled,
    paiInserted,
    destinationsList = [],
  } = data;

  return (
    <>
      <Section
        title="Controls"
        buttons={
          <>
            {!!load && (
              <Button icon="eject" onClick={() => act('unload')}>
                Unload
              </Button>
            )}
            {!!paiInserted && (
              <Button icon="eject" onClick={() => act('eject_pai')}>
                Eject PAI
              </Button>
            )}
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="ID">
            <Button onClick={() => act('setid')}>{botId}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Home">
            <Button onClick={() => act('sethome')}>{homeDestination}</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Destination">
            <Dropdown
              over
              selected={destination || 'None'}
              options={destinationsList}
              width="188px"
              onSelected={(value) => act('destination', { value })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Settings">
        <Button.Checkbox checked={autoReturn} onClick={() => act('autored')}>
          Auto-Return
        </Button.Checkbox>
        <br />
        <Button.Checkbox checked={autoPickup} onClick={() => act('autopick')}>
          Auto-Pickup
        </Button.Checkbox>
        <br />
        <Button.Checkbox checked={reportDelivery} onClick={() => act('report')}>
          Report-Delivery
        </Button.Checkbox>
        <br />
        {!!allowPossession && (
          <Button.Checkbox
            checked={possessionEnabled}
            onClick={() => act('toggle_personality')}
          >
            Download Personality
          </Button.Checkbox>
        )}
      </Section>
      <Section title="Actions">
        <Stack style={{ padding: '0px 30px' }}>
          <Stack.Item grow>
            <Button
              width="60px"
              icon="stop"
              color="bad"
              onClick={() => act('stop')}
            >
              Stop
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              width="60px"
              icon="play"
              color="average"
              onClick={() => act('go')}
            >
              Go
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button width="60px" icon="home" onClick={() => act('home')}>
              Home
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
};

export const Mule = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    powerStatus,
    cellPercent,
    load,
    mode,
    modeStatus,
    locked,
    siliconUser,
  } = data;

  const mulebotLocked = locked && !siliconUser;

  return (
    <Window width={350} height={500}>
      <Window.Content>
        <InterfaceLockNoticeBox />
        <Section
          title="Status"
          buttons={
            <>
              <Button icon="fa-poll-h" onClick={() => act('rename')}>
                Rename
              </Button>
              {!mulebotLocked && (
                <Button
                  icon={powerStatus ? 'power-off' : 'times'}
                  selected={powerStatus}
                  onClick={() => act('on')}
                >
                  {powerStatus ? 'On' : 'Off'}
                </Button>
              )}
            </>
          }
        >
          <ProgressBar
            value={cellPercent ? cellPercent / 100 : 0}
            color={cellPercent ? 'good' : 'bad'}
          />
          <Stack mt={1}>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Mode" color={modeStatus}>
                  {mode}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow ml="40%">
              <LabeledList>
                <LabeledList.Item
                  label="Load"
                  color={load ? 'good' : 'average'}
                >
                  {load || 'None'}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        {!mulebotLocked && <MuleControls />}
      </Window.Content>
    </Window>
  );
};

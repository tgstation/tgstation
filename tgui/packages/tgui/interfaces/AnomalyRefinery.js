import { useBackend, useSharedState } from '../backend';
import {
  Button,
  Icon,
  Modal,
  Section,
  Stack,
  LabeledList,
  Box,
} from '../components';
import { Window } from '../layouts';
import { GasmixParser } from './common/GasmixParser';

export const AnomalyRefinery = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window title="Anomaly Refinery" width={550} height={350}>
      <Window.Content>
        <AnomalyRefineryContent />
      </Window.Content>
    </Window>
  );
};


const AnomalyRefineryContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [currentTab, changeTab] = useSharedState(context, 'exploderTab', 1);
  const { core, valvePresent, active } = data;
  return (
    <Stack vertical fill>
      {currentTab === 1 && <CoreCompressorContent />}
      {currentTab === 2 && <BombProcessorContent />}
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="eject"
              disabled={!core || active}
              onClick={() => act('eject_core')}>
              {'Eject Core'}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon={currentTab === 1 ? 'server' : 'compress-arrows-alt'}
              onClick={() => changeTab(currentTab === 1 ? 2 : 1)}>
              {currentTab === 1 ? 'Run Simulations' : 'Implosion Control'}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="eject"
              disabled={!valvePresent || active}
              onClick={() => act('eject_bomb')}>
              {'Eject Bomb'}
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const CoreCompressorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { core, requiredRadius, gasList, valveReady, active, valvePresent }
    = data;
  return (
    <>
      <Stack.Item grow>
        <Section
          fill
          title="Inserted Core"
          buttons={
            <Button
              icon="compress-arrows-alt"
              backgroundColor="red"
              onClick={() => act('start_implosion')}
              disabled={active || !valveReady || !core}>
              {'Implode Core'}
            </Button>
          }>
          {!core && <Modal textAlign="center">{'No Core Inserted!'}</Modal>}
          <LabeledList>
            <LabeledList.Item label={'Name'}>{core ? core : '-'}</LabeledList.Item>
            <LabeledList.Item label={'Required Radius'}>
              {requiredRadius
                ? requiredRadius + ' tiles'
                : 'Implosion not possible.'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          title="Inserted Bomb"
          buttons={
            <Button
              disabled={!valveReady}
              icon="exchange-alt"
              onClick={() => act('swap')}>
              {'Swap Merging Order'}
            </Button>
          }>
          {!valvePresent && <Modal textAlign="center">{'No Bomb Inserted!'}</Modal>}
          <Stack align="center">
            <Stack.Item grow textAlign="center">
              <Box height={2} width="100%" bold>
                {'Giver Tank ('
              + (gasList[1].name ? gasList[1].name : 'Not Available')
              + ')'}
              </Box>
              <Box height={2} width="100%">
                {(gasList[1].total_moles
                  ? String(gasList[0].total_moles.toFixed(2))
                  : '-')
              + ' moles at '
              + (gasList[1].total_moles
                ? String(gasList[1].temperature.toFixed(2))
                : '-')
              + ' Kelvin'}
              </Box>
              <Box height={2} width="100%">
                {(gasList[1].total_moles
                  ? String(gasList[1].pressure.toFixed(2))
                  : '-') + ' kPa'}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Icon size={2} name="arrow-right" />
            </Stack.Item>
            <Stack.Item grow textAlign="center">
              <Box height={2} width="100%" bold>
                {'Target Tank ('
              + (gasList[0].name ? gasList[0].name : 'Not Available')
              + ')'}
              </Box>
              <Box height={2} width="100%">
                {(gasList[0].total_moles
                  ? String(gasList[0].total_moles.toFixed(2))
                  : '-')
              + ' moles at '
              + (gasList[0].total_moles
                ? String(gasList[0].temperature.toFixed(2))
                : '-')
              + ' Kelvin'}
              </Box>
              <Box height={2} width="100%">
                {(gasList[1].total_moles
                  ? String(gasList[0].pressure.toFixed(2))
                  : '-') + ' kPa'}
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </>
  );
};
const BombProcessorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { gasList, reactionIncrement } = data;
  return (
    <>
      <Stack.Item grow>
        <Section
          fill
          title={gasList[2].name}
          scrollable
          buttons={
            <Button
              tooltip={
                reactionIncrement === 0
                  ? 'Valve status: Closed'
                  : 'Valve status: Open. Current reaction count:'
                + (reactionIncrement)
              }
              icon="vial"
              tooltipPosition="left"
              onClick={() => act('react')}
              textAlign="center"
              disabled={!gasList[0].total_moles || !gasList[1].total_moles}
              content={reactionIncrement === 0 ? 'Open Valve' : 'React'} />
          }>
          {!gasList[2].total_moles && (
            <Modal textAlign="center">{'No Gas Present'}</Modal>
          )}
          <GasmixParser {...gasList[2]} />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          {[gasList[0], gasList[1]].map((individualGasmix) => (
            <Stack.Item grow key={individualGasmix.ref}>
              <Section
                fill
                scrollable
                title={
                  individualGasmix.name ? individualGasmix.name : 'Not Available'
                }>
                {!individualGasmix.total_moles && (
                  <Modal textAlign="center">{'No Gas Present'}</Modal>
                )}
                <GasmixParser {...individualGasmix} />
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
    </>
  );
};

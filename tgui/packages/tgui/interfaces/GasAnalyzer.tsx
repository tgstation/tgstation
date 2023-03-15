import { useBackend } from '../backend';
import { GasmixParser } from './common/GasmixParser';
import type { Gasmix } from './common/GasmixParser';
import { Button, Flex, LabeledList, Section, Stack, Box } from '../components';
import { AtmosHandbookContent, atmosHandbookHooks } from './common/AtmosHandbook';
import { Window } from '../layouts';
import { BooleanLike } from '../../common/react';

type GasmixHistory = {
  allGasmixes: Gasmix[];
};

export type GasAnalyzerData = {
  gasmixes: Gasmix[];
  autoUpdating: boolean;
};

export type GasAnalyzerHistoryData = {
  historyGasmixes: GasmixHistory[];
  historyViewMode: string;
  historyIndex: number;
  targetMode: BooleanLike;
};

export const GasAnalyzerContent = (props, context) => {
  const { act, data } = useBackend<GasAnalyzerData>(context);
  const { gasmixes, autoUpdating } = data;
  const [setActiveGasId, setActiveReactionId] = atmosHandbookHooks(context);
  return (
    <>
      {gasmixes.map((gasmix) => (
        <Section
          title={gasmix.name}
          key={gasmix.reference}
          buttons={
            <Button
              icon={autoUpdating ? 'sync-alt' : 'lock'}
              onClick={() => act('autoscantoggle')}
              tooltip={
                autoUpdating ? 'Auto-Update Enabled' : 'Auto-Update Disabled'
              }
              fluid
              textAlign="center"
              selected={autoUpdating}
            />
          }>
          <GasmixParser
            gasmix={gasmix}
            gasesOnClick={setActiveGasId}
            reactionOnClick={setActiveReactionId}
          />
        </Section>
      ))}
      <AtmosHandbookContent vertical />
    </>
  );
};

export const GasAnalyzerHistory = (props, context) => {
  const { act, data } = useBackend<GasAnalyzerHistoryData>(context);
  const { historyGasmixes, historyViewMode, historyIndex } = data;
  return (
    <Section
      fill
      title="Scan History"
      buttons={
        <Button
          icon={'trash'}
          tooltip="Clear History"
          onClick={() => act('clearhistory')}
          textAlign="center"
          disabled={historyGasmixes.length === 0}
        />
      }>
      <LabeledList.Item label="Mode">
        <Flex inline width="50%">
          <Flex.Item>
            <Button
              content={'kPa'}
              onClick={() => act('modekpa')}
              textAlign="center"
              selected={historyViewMode === 'kpa'}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              content={'mol'}
              onClick={() => act('modemol')}
              textAlign="center"
              selected={historyViewMode === 'mol'}
            />
          </Flex.Item>
        </Flex>
      </LabeledList.Item>
      <LabeledList>
        {historyGasmixes.map((allGasmixes, index) => (
          <Box key={allGasmixes[0]}>
            <Button
              content={
                index +
                1 +
                '. ' +
                (historyViewMode === 'mol'
                  ? allGasmixes[0].total_moles
                  : allGasmixes[0].pressure
                ).toFixed(2)
              }
              onClick={() => act('input', { target: index + 1 })}
              textAlign="left"
              selected={index + 1 === historyIndex}
              fluid
            />
          </Box>
        ))}
      </LabeledList>
    </Section>
  );
};

export const GasAnalyzer = (props, context) => {
  return (
    <Window width={500} height={450}>
      <Window.Content scrollable>
        <Stack>
          {/* Left Column */}
          <Stack.Item grow>
            <GasAnalyzerContent />
          </Stack.Item>
          {/* Right Column */}
          <Stack.Item width={'150px'}>
            <GasAnalyzerHistory />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

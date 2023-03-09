import { useBackend } from '../backend';
import { GasmixParser } from './common/GasmixParser';
import type { Gasmix } from './common/GasmixParser';
import { Box, Button } from '../components';
import { AtmosHandbookContent, atmosHandbookHooks } from './common/AtmosHandbook';
import { Window } from '../layouts';
import { Section } from '../components';

export type GasAnalyzerData = {
  gasmixes: Gasmix[];
  autoUpdating: boolean;
};

export const GasAnalyzerContent = (props, context) => {
  const { act, data } = useBackend<GasAnalyzerData>(context);
  const { gasmixes } = data;
  const [setActiveGasId, setActiveReactionId] = atmosHandbookHooks(context);
  return (
    <>
      {gasmixes.map((gasmix) => (
        <Section title={gasmix.name} key={gasmix.reference}>
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

export const GasAnalyzer = (props, context) => {
  const { act, data } = useBackend<GasAnalyzerData>(context);
  const { autoUpdating } = data;
  return (
    <Window width={500} height={450}>
      <Window.Content scrollable>
        <Button
          icon={autoUpdating ? 'sync-alt' : 'times'}
          content={
            autoUpdating
              ? 'Auto-updating is enabled. Click to switch.'
              : 'Auto-updating is disabled. Click to switch.'
          }
          onClick={() => act('autoscantoggle')}
          fluid
          textAlign="center"
          selected={autoUpdating}
        />
        <Box color="bad" />
        <GasAnalyzerContent />
      </Window.Content>
    </Window>
  );
};

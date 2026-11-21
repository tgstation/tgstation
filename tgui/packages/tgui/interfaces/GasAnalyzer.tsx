import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  AtmosHandbookContent,
  atmosHandbookHooks,
} from './common/AtmosHandbook';
import type { Gasmix } from './common/GasmixParser';
import { GasmixParser } from './common/GasmixParser';

export type GasAnalyzerData = {
  gasmixes: Gasmix[] | null;
};

export const GasAnalyzerContent = () => {
  const { data } = useBackend<GasAnalyzerData>();
  const { gasmixes } = data;
  const [setActiveGasId, setActiveReactionId] = atmosHandbookHooks();
  return (
    <Stack vertical fill>
      <Stack.Item>
        {gasmixes?.map((gasmix) => (
          <Section title={gasmix.name} key={gasmix.reference}>
            <GasmixParser
              gasmix={gasmix}
              gasesOnClick={setActiveGasId}
              reactionOnClick={setActiveReactionId}
            />
          </Section>
        ))}
      </Stack.Item>
      <Stack.Item grow>
        <AtmosHandbookContent />
      </Stack.Item>
    </Stack>
  );
};

export const GasAnalyzer = () => {
  return (
    <Window width={500} height={500}>
      <Window.Content>
        <GasAnalyzerContent />
      </Window.Content>
    </Window>
  );
};

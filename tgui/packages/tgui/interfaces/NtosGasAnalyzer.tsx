import { useBackend } from '../backend';
import { Stack } from '../components';
import { NtosWindow } from '../layouts';
import { GasAnalyzerContent, GasAnalyzerData, GasAnalyzerHistory } from './GasAnalyzer';

export const NtosGasAnalyzer = (props, context) => {
  const { act, data } = useBackend<GasAnalyzerData>(context);
  return (
    <NtosWindow width={500} height={450}>
      <NtosWindow.Content scrollable>
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
      </NtosWindow.Content>
    </NtosWindow>
  );
};

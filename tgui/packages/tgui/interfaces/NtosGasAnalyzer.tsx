import { useBackend } from '../backend';
import { Button } from '../components';
import { NtosWindow } from '../layouts';
import { GasAnalyzerContent, GasAnalyzerData } from './GasAnalyzer';

type NtosGasAnalyzerData = GasAnalyzerData & {
  atmozphereMode: "click" | "env";
};

export const NtosGasAnalyzer = (props, context) => {
  const { act, data } = useBackend<NtosGasAnalyzerData>(context);
  return (
    <NtosWindow width={500} height={450}>
      <NtosWindow.Content scrollable>
        <Button
          title={
            data.atmozphereMode === "click"
              ? 'Scanning tapped objects. Click to switch.'
              : 'Scanning current location. Click to switch.'
          }
          icon={"sync"}
          onClick={() => act('scantoggle')}
          fluid
        />
        <GasAnalyzerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

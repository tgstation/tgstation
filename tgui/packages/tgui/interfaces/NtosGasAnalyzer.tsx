import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button } from '../components';
import { NtosWindow } from '../layouts';
import { GasAnalyzerContent, GasAnalyzerData } from './GasAnalyzer';

type NtosGasAnalyzerData = GasAnalyzerData & {
  atmozphereMode: 'click' | 'env';
  clickAtmozphereCompatible: BooleanLike;
};

export const NtosGasAnalyzer = (props, context) => {
  const { act, data } = useBackend<NtosGasAnalyzerData>(context);
  const { atmozphereMode, clickAtmozphereCompatible } = data;
  return (
    <NtosWindow width={500} height={450}>
      <NtosWindow.Content scrollable>
        {!!clickAtmozphereCompatible && (
          <Button
            icon={'sync'}
            onClick={() => act('scantoggle')}
            fluid
            textAlign="center"
            tooltip={
              atmozphereMode === 'click'
                ? 'Right-click on objects while holding the tablet to scan them. Right-click on the tablet to scan the current location.'
                : "The app will update it's gas mixture reading automatically."
            }
            tooltipPosition="bottom">
            {atmozphereMode === 'click'
              ? 'Scanning tapped objects. Click to switch.'
              : 'Scanning current location. Click to switch.'}
          </Button>
        )}
        <GasAnalyzerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

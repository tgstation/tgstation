import { Button } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { GasAnalyzerContent, type GasAnalyzerData } from './GasAnalyzer';

type NtosGasAnalyzerData = GasAnalyzerData & {
  atmozphereMode: 'click' | 'env';
  clickAtmozphereCompatible: BooleanLike;
};

export const NtosGasAnalyzer = (props) => {
  const { act, data } = useBackend<NtosGasAnalyzerData>();
  const { atmozphereMode, clickAtmozphereCompatible } = data;
  return (
    <NtosWindow width={560} height={450}>
      <NtosWindow.Content scrollable>
        {!!clickAtmozphereCompatible && (
          <Button
            icon={'sync'}
            onClick={() => act('scantoggle')}
            fluid
            textAlign="center"
            tooltip={
              atmozphereMode === 'click'
                ? 'ПКМ на объектах, удерживая планшет, чтобы отсканировать их. ПКМ на планшете, чтобы отсканировать текущее местоположение.'
                : 'Приложение будет автоматически обновлять показания газовой смеси.'
            }
            tooltipPosition="bottom"
          >
            {atmozphereMode === 'click'
              ? 'Сканирование объектов. Нажмите, чтобы переключиться.'
              : 'Сканирование текущего местоположения. Нажмите, чтобы переключиться.'}
          </Button>
        )}
        <GasAnalyzerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

import { Button, Dropdown, NumberInput } from 'tgui-core/components';

import type { Feature, FeatureNumericData, FeatureValueProps } from '../base';

type FpsServerData = FeatureNumericData & {
  recommended_fps: number;
};

function FpsInput(props: FeatureValueProps<number, number, FpsServerData>) {
  const { handleSetValue, serverData } = props;

  let recommened = `Recommended`;
  if (serverData) {
    recommened += ` (${serverData.recommended_fps})`;
  }

  return props.value === -1 ? (
    <Dropdown
      options={[recommened, 'Custom']}
      selected={props.value === -1 ? recommened : 'Custom'}
      onSelected={(value) => {
        if (value === 'Custom') {
          handleSetValue(serverData?.recommended_fps || 60);
        }
      }}
    />
  ) : (
    serverData && (
      <>
        <NumberInput
          step={1}
          minValue={1}
          value={props.value}
          maxValue={serverData.maximum}
          onChange={(value) => {
            props.handleSetValue(value);
          }}
        />
        <Button
          icon="undo"
          tooltip="Reset"
          onClick={() => handleSetValue(-1)}
        />
      </>
    )
  );
}

export const clientfps: Feature<number, number, FpsServerData> = {
  name: 'FPS',
  category: 'Геймплей',
  component: FpsInput,
};

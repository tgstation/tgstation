import { Dropdown, NumberInput, Stack } from "../../../../../components";
import { Feature, FeatureNumericData, FeatureValueProps } from "../base";

type FpsServerData = FeatureNumericData & {
  recommended_fps: number;
}

const FpsInput = (
  props: FeatureValueProps<number, number, FpsServerData>
) => {
  const { handleSetValue, serverData } = props;

  let recommened = `Recommended`;
  if (serverData) {
    recommened += ` (${serverData.recommended_fps})`;
  }

  return (
    <Stack fill>
      <Stack.Item basis="70%">
        <Dropdown
          selected={props.value === -1 ? recommened : "Custom"}
          onSelected={(value) => {
            if (value === recommened) {
              handleSetValue(-1);
            } else {
              handleSetValue(serverData?.recommended_fps || 60);
            }
          }}
          width="100%"
          options={[
            recommened,
            "Custom",
          ]}
        />
      </Stack.Item>

      <Stack.Item>
        {serverData && props.value !== -1 && (<NumberInput
          onChange={(e, value) => {
            props.handleSetValue(value);
          }}
          minValue={1}
          maxValue={serverData.maximum}
          value={props.value}
        />)}
      </Stack.Item>
    </Stack>
  );
};

export const clientfps: Feature<number, number, FpsServerData> = {
  name: "FPS",
  category: "GAMEPLAY",
  component: FpsInput,
};

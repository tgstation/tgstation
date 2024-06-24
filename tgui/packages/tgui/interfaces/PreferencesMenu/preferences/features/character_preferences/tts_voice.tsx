import { Button, Stack } from '../../../../../components';
import {
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureNumeric,
  FeatureSliderInput,
  FeatureValueProps,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

const FeatureTTSDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) => {
  return (
    <Stack>
      <Stack.Item grow>
        <FeatureDropdownInput {...props} />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            props.act('play_voice');
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            props.act('play_voice_robot');
          }}
          icon="robot"
          width="100%"
          height="100%"
        />
      </Stack.Item>
    </Stack>
  );
};

export const tts_voice: FeatureChoiced = {
  name: 'Voice',
  component: FeatureTTSDropdownInput,
};

export const tts_voice_pitch: FeatureNumeric = {
  name: 'Voice Pitch Adjustment',
  component: FeatureSliderInput,
};

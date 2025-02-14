import { useBackend } from 'tgui/backend';
import { Button, Stack } from 'tgui-core/components';

import {
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureNumeric,
  FeatureSliderInput,
  FeatureValueProps,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

function FeatureTTSDropdownInput(
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) {
  const { act } = useBackend();

  return (
    <Stack>
      <Stack.Item grow>
        <FeatureDropdownInput {...props} />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            act('play_voice');
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            act('play_voice_robot');
          }}
          icon="robot"
          width="100%"
          height="100%"
        />
      </Stack.Item>
    </Stack>
  );
}

export const tts_voice: FeatureChoiced = {
  name: 'Voice',
  component: FeatureTTSDropdownInput,
};

export const tts_voice_pitch: FeatureNumeric = {
  name: 'Voice Pitch Adjustment',
  component: FeatureSliderInput,
};

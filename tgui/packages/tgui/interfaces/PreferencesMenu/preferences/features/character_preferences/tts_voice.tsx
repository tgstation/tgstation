import { FeatureChoiced, FeatureChoicedServerData, FeatureDropdownInput, FeatureValueProps, FeatureNumeric, FeatureSliderInput } from '../base';
import { Stack, Button } from '../../../../../components';

const FeatureTTSDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>
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
  description: 'The voice of your character, used in TTS.',
  component: FeatureTTSDropdownInput,
};

export const tts_voice_pitch: FeatureNumeric = {
  name: 'Voice Pitch Adjustment',
  description:
    'When your character speaks in TTS, pitch will be adjusted by this much.',
  component: FeatureSliderInput,
};

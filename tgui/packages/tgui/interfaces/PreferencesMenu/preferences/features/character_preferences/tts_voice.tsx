import { FeatureChoiced, FeatureChoicedServerData, FeatureDropdownInput, FeatureValueProps } from '../base';
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
    </Stack>
  );
};

export const tts_voice: FeatureChoiced = {
  name: 'Voice',
  component: FeatureTTSDropdownInput,
};

import { Button, Stack } from '../../../../../../components';
import { FeatureChoiced, FeatureValueProps } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

const FeatureBoopDropdownInput = (props: FeatureValueProps<string>) => {
  return (
    <Stack>
      <Stack.Item grow>
        <FeatureDropdownInput {...props} />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            props.act('play_boop_voice');
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
    </Stack>
  );
};

export const voice_type: FeatureChoiced = {
  name: 'Voice type',
  component: FeatureBoopDropdownInput,
};

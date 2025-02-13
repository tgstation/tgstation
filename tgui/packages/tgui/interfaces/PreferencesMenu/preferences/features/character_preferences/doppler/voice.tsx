import { useBackend } from 'tgui/backend';
import { Button, Stack } from 'tgui-core/components';

import { FeatureChoiced, FeatureValueProps } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

function FeatureBoopDropdownInput(props: FeatureValueProps<string>) {
  const { act } = useBackend();
  return (
    <Stack>
      <Stack.Item grow>
        <FeatureDropdownInput {...props} />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            act('play_boop_voice');
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
    </Stack>
  );
}

export const voice_type: FeatureChoiced = {
  name: 'Voice type',
  component: FeatureBoopDropdownInput,
};

import { Button, Stack } from '../../../../../components';
import { Feature, FeatureValueProps } from '../base';

export const limb_list: Feature<undefined, undefined> = {
  name: 'Access Limbs',
  component: (props: FeatureValueProps<undefined, undefined>) => {
    const { act } = props;

    return (
      <Stack>
        <Stack.Item>
          <Button content="Open" onClick={() => act('open_limbs')} />
        </Stack.Item>
      </Stack>
    );
  },
};

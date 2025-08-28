import {
  Button,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const SentienceFunBalloon = (props) => {
  const { act, data } = useBackend();
  const { group_name, range, antag } = data;
  return (
    <Window title={'Sentience Fun Balloon'} width={400} height={200}>
      <Window.Content>
        <Stack vertical>
          <Section title="Configure balloon effect:">
            <LabeledList>
              <LabeledList.Item label="Group name">
                <Input
                  fluid
                  value={group_name}
                  onBlur={(value) =>
                    act('group_name', {
                      updated_name: value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Effect range">
                <NumberInput
                  width="84px"
                  value={range}
                  minValue={1}
                  maxValue={100}
                  step={1}
                  stepPixelSize={15}
                  onDrag={(value) =>
                    act('effect_range', {
                      updated_range: value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Make group into antagonists?">
                <Button.Checkbox
                  icon={data.antag ? 'user-secret' : 'times'}
                  content={data.antag ? 'Yes' : 'No'}
                  selected={data.antag}
                  onClick={() => act('select_antag')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
          <Section>
            <Button.Confirm
              fluid
              icon="magic"
              color="good"
              textAlign="center"
              content="Pop Balloon"
              onClick={() => act('pop')}
            />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

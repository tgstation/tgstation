import { useBackend } from '../backend';
import { Button, NumberInput, Section, Stack, Input, LabeledList } from '../components';
import { Window } from '../layouts';

export const SentienceFunBalloon = (props, context) => {
  const { act, data } = useBackend(context);
  const { group_name, range } = data;
  return (
    <Window title={'Sentience Fun Balloon'} width={400} height={175}>
      <Window.Content>
        <Stack vertical>
          <Section title="Configure balloon effect:">
            <LabeledList>
              <LabeledList.Item label="Group name">
                <Input
                  fluid
                  value={group_name}
                  onChange={(e, value) =>
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
                  stepPixelSize={15}
                  onDrag={(e, value) =>
                    act('effect_range', {
                      updated_range: value,
                    })
                  }
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

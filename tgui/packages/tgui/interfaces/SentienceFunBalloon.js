import { useBackend } from "../backend";
import { Button, NumberInput, Section, Stack, TextArea, LabeledList } from '../components';
import { Window } from "../layouts";

export const SentienceFunBalloon = (props, context) => {
  const { act, data } = useBackend(context);
  const { group_name, pop_sound, range } = data;
  return (
    <Window
      title={"Sentience Fun Balloon"}
      width={400}
      height={200}
    >
      <Window.Content>
          <Stack vertical>
            <Section title="Configure balloon effect:">
              <LabeledList>
                <LabeledList.Item label="Group name">
                  <TextArea
                    //height="20px"
                    mb={1}
                    value={group_name}
                    onChange={(e, value) => act("group_name", {
                    updated_name: value,
                    })} />
                </LabeledList.Item>
                <LabeledList.Item label="Effect range">
                  <NumberInput
                    height="20px"
                    value={range}
                    minValue={1}
                    maxValue={100}
                    stepPixelSize={1}
                    onDrag={(e, value) => act('effect_range', {
                    updated_range: value,
                    })} />
                </LabeledList.Item>
                <LabeledList.Item label="Pop sound effect">
                  <Button
                    fluid
                    icon="bullhorn"
                    textAlign="center"
                    content="party_horn.ogg"
                    onClick={() => act("pop_sound")} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          <Stack.Item>
            <Button.Confirm
              fluid
              icon="magic"
              color="good"
              textAlign="center"
              content="Pop Balloon"
              onClick={() => act("pop")} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

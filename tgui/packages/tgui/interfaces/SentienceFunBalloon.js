import { useBackend } from "../backend";
import { Button, Dropdown, Input, Section, Stack, TextArea } from '../components';
import { Window } from "../layouts";

export const SentienceFunBalloon = (props, context) => {
  const { act, data } = useBackend(context);
  const { group_name, pop_sound, range, mob_type } = data;
  return (
    <Window
      title={"Sentience Fun Balloon"}
      width={400}
      height={500}
    >
      <Window.Content>
      <Stack vertical>
          <Stack.Item>
            <Section title="Set group name:" textAlign="center">
              <TextArea
                  height="20px"
                  mb={1}
                  value={"a bunch of giant spiders"}
                  onChange={(e, value) => act("group_name", {
                    updated_name: value,
                  })} />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Set effect range:" textAlign="center">
              <TextArea
                  height="20px"
                  mb={1}
                  value={"3"}
                  onChange={(e, value) => act("effect_range", {
                    updated_range: value,
                  })} />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Set mob type:" textAlign="center">
              <TextArea
                  height="20px"
                  mb={1}
                  value={"Any"}
                  onChange={(e, value) => act("mob_type", {
                    updated_mob_type: value,
                  })} />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Set pop sound:" textAlign="center">
              <Sounds />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                <Button.Confirm
                  fluid
                  icon="check"
                  color="good"
                  textAlign="center"
                  content="Pop Balloon"
                  onClick={() => act("pop")} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Sounds = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Button
      content={'sound/items/party_horn.ogg'}
      selected={data["pop_sound"]}
      onClick={() => act("pop_sound")} />
  );
};

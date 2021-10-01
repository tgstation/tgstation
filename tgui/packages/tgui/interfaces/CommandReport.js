import { useBackend } from '../backend';
import { Button, Dropdown, Input, Section, Stack, TextArea } from '../components';
import { Window } from '../layouts';

export const CommandReport = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    command_name,
    custom_name,
    command_name_presets = [],
    command_report_content,
    played_sound,
    announcer_sounds = [],
    announce_contents,
  } = data;
  return (
    <Window
      title="Create Command Report"
      width={325}
      height={525}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Section title="Set Central Command name:" textAlign="center">
              <Dropdown
                width="100%"
                selected={command_name}
                options={command_name_presets}
                onSelected={value => act('update_command_name', {
                  updated_name: value,
                })} />
              {!!custom_name && (
                <Input
                  width="100%"
                  mt={1}
                  value={command_name}
                  placeholder={command_name}
                  onChange={(e, value) => act("update_command_name", {
                    updated_name: value,
                  })} />
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Set announcement sound:" textAlign="center">
              <Dropdown
                width="100%"
                displayText={played_sound}
                options={announcer_sounds}
                onSelected={value => act('set_report_sound', {
                  picked_sound: value,
                })} />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Set report text:" textAlign="center">
              <TextArea
                height="200px"
                mb={1}
                value={command_report_content}
                onChange={(e, value) => act("update_report_contents", {
                  updated_contents: value,
                })} />
              <Stack vertical>
                <Stack.Item>
                  <Button.Checkbox
                    fluid
                    checked={announce_contents}
                    onClick={() => act("toggle_announce")}>
                    Announce Contents
                  </Button.Checkbox>
                </Stack.Item>
                <Stack.Item>
                  <Button.Confirm
                    fluid
                    icon="check"
                    color="good"
                    textAlign="center"
                    content="Submit Report"
                    onClick={() => act("submit_report")} />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

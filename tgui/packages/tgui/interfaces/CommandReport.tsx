import { useBackend, useLocalState } from '../backend';
import { Button, Dropdown, Input, Section, Stack, TextArea } from '../components';
import { Window } from '../layouts';

type Data = {
  announce_contents: string;
  announcer_sounds: string[];
  command_name: string;
  command_name_presets: string[];
  command_report_content: string;
  custom_name: string;
  played_sound: string;
};

export const CommandReport = () => {
  return (
    <Window
      title="Create Command Report"
      width={325}
      height={525}
      theme="admin">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <CentComName />
          </Stack.Item>
          <Stack.Item>
            <AnnouncementSound />
          </Stack.Item>
          <Stack.Item>
            <ReportText />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Allows the user to set the "sender" of the message via dropdown */
const CentComName = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { command_name, command_name_presets = [], custom_name } = data;

  return (
    <Section title="Set Central Command name" textAlign="center">
      <Dropdown
        width="100%"
        selected={command_name}
        options={command_name_presets}
        onSelected={(value) =>
          act('update_command_name', {
            updated_name: value,
          })
        }
      />
      {!!custom_name && (
        <Input
          width="100%"
          mt={1}
          value={command_name}
          placeholder={command_name}
          onChange={(_, value) =>
            act('update_command_name', {
              updated_name: value,
            })
          }
        />
      )}
    </Section>
  );
};

/** Features a section with dropdown for sounds. */
const AnnouncementSound = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { announcer_sounds = [], played_sound } = data;

  return (
    <Section title="Set announcement sound" textAlign="center">
      <Dropdown
        width="100%"
        displayText={played_sound}
        options={announcer_sounds}
        onSelected={(value) =>
          act('set_report_sound', {
            picked_sound: value,
          })
        }
      />
    </Section>
  );
};

/** Creates the report textarea with a submit button. */
const ReportText = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { announce_contents, command_report_content } = data;
  const [commandReport, setCommandReport] = useLocalState<string>(
    context,
    'textArea',
    command_report_content
  );

  return (
    <Section title="Set report text" textAlign="center">
      <TextArea
        height="200px"
        mb={1}
        onInput={(_, value) => setCommandReport(value)}
        value={commandReport}
      />
      <Stack vertical>
        <Stack.Item>
          <Button.Checkbox
            fluid
            checked={announce_contents}
            onClick={() => act('toggle_announce')}>
            Announce Contents
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            fluid
            icon="check"
            textAlign="center"
            content="Submit Report"
            onClick={() => act('submit_report', { report: commandReport })}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Input, Section, Stack, TextArea } from '../components';
import { Window } from '../layouts';

type Data = {
  announce_contents: string;
  announcer_sounds: string[];
  command_name: string;
  command_name_presets: string[];
  command_report_content: string;
  announcement_color: string;
  announcement_colors: string[];
  subheader: string;
  custom_name: string;
  played_sound: string;
  print_report: string;
};

export const CommandReport = () => {
  return (
    <Window
      title="Create Command Report"
      width={325}
      height={685}
      theme="admin">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <CentComName />
            <AnnouncementColor />
            <AnnouncementSound />
          </Stack.Item>
          <Stack.Item>
            <SubHeader />
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

/** Allows the user to set the "sender" of the message via dropdown */
const SubHeader = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { subheader } = data;

  return (
    <Section title="Set report subheader" textAlign="center">
      <Box>Keep blank to not include a subheader</Box>
      <Input
        width="100%"
        mt={1}
        value={subheader}
        placeholder={subheader}
        onChange={(_, value) =>
          act('set_subheader', {
            new_subheader: value,
          })
        }
      />
    </Section>
  );
};

/** Features a section with dropdown for the announcement colour. */
const AnnouncementColor = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { announcement_colors = [], announcement_color } = data;

  return (
    <Section title="Set announcement color" textAlign="center">
      <Dropdown
        width="100%"
        displayText={announcement_color}
        options={announcement_colors}
        onSelected={(value) =>
          act('update_announcement_color', {
            updated_announcement_color: value,
          })
        }
      />
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
  const { announce_contents, print_report, command_report_content } = data;
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
          <Button.Checkbox
            fluid
            checked={print_report || !announce_contents}
            disabled={!announce_contents}
            onClick={() => act('toggle_printing')}
            tooltip={
              !announce_contents &&
              "Printing the report is required since we aren't announcing its contents."
            }
            tooltipPosition="top">
            Print Report
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

import { useBackend } from '../backend';
import { Box, Button, Input, TextArea, Section, Flex } from '../components';
import { Window } from '../layouts';

export const CommandReport = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    command_name,
    global_command_name,
    command_report_content,
    announce_contents,
  } = data;
  return (
    <Window
      title="Create Command Report"
      width={325}
      height={400}>
      <Section>
        <Flex mb={1}>
          <Box textAlign="center">
            Input a name for central command.
            Command's name is currently: {global_command_name}.
          </Box>
        </Flex>
        <Flex grow={1}>
          <Input
            value={command_name}
            placeholder={command_name}
            width="150px"
            onChange={(e, value) => act("update_command_name", {
              updated_name: value,
            })} />
          <Button
            content="Set to CC"
            height="20px"
            onClick={() => act("update_command_name", {
              updated_name: "Central Command"
            })} />
          <Button
            content="Set to Syndicate"
            height="20px"
            onClick={() => act("update_command_name", {
              updated_name: "The Syndicate"
            })} />
        </Flex>
      </Section>
      <Section>
        <Box textAlign="center" mb={1}>
          Input the text to appear in the report.
        </Box>
        <Flex mb={1}>
          <TextArea
            width="100%"
            height="200px"
            value={command_report_content}
            onChange={(e, value) => act("update_report_contents", {
              updated_contents: value,
            })} />
        </Flex>
        <Flex grow={1}>
          <Button.Checkbox
            width="160px"
            height="20px"
            checked={announce_contents}
            content="Announce Contents"
            onClick={() => act("toggle_announce")} />
          <Button.Confirm
            width="180px"
            height="20px"
            color="good"
            content="Submit Command Report"
            onClick={() => act("submit_report")}
            />
        </Flex>
      </Section>
    </Window>
  );
};

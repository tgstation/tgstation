import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Section, Box } from '../components';
import { sanitizeText } from '../sanitize';

export const NtosPhysScanner = (props, context) => {
  const { act, data } = useBackend(context);
  const { set_mode, last_record, available_modes = [] } = data;
  const textHtml = {
    __html: sanitizeText(last_record),
  };
  return (
    <NtosWindow width={600} height={350}>
      <NtosWindow.Content scrollable>
        <Section>
          Tap something (right-click) with your tablet to use the physical
          scanner.
        </Section>
        <Section>
          <Box bold>
            LAST SAVED RESULT
            <br />
            <br />
          </Box>
          <Box
            style={{ 'white-space': 'pre-line' }}
            dangerouslySetInnerHTML={textHtml}
          />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

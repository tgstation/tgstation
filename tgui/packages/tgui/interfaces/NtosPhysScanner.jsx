import { Box, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { sanitizeText } from '../sanitize';

export const NtosPhysScanner = (props) => {
  const { act, data } = useBackend();
  const { last_record } = data;
  const textHtml = {
    __html: sanitizeText(last_record),
  };
  return (
    <NtosWindow width={600} height={350}>
      <NtosWindow.Content scrollable>
        <Section>
          Нажмите на что-нибудь (ПКМ) с помощью планшета, чтобы использовать
          сканер.
        </Section>
        <Section>
          <Box bold>
            ПОСЛЕДНИЕ ДАННЫЕ
            <br />
            <br />
          </Box>
          <Box
            style={{ whiteSpace: 'pre-line' }}
            dangerouslySetInnerHTML={textHtml}
          />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

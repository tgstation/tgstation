/* eslint-disable max-len */
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Section, Box, Dropdown } from '../components';
import { sanitizeText } from '../sanitize';

let decodeHtml = function (html) {
  let txt = document.createElement("textarea");
  txt.innerHTML = html;
  return txt.value;
};

export const NtosPhysScanner = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    set_mode,
    last_record,
    available_modes = [],
  } = data;
  const textHtml = {
    __html: sanitizeText(last_record),
  };
  return (
    <NtosWindow
      width={600}
      height={350}>
      <NtosWindow.Content scrollable>
        <Section>
          Tap something (right-click) with your tablet to use the physical scanner.
        </Section>
        <Section>
          <Box bold>SELECTED MODE <br /> <br /></Box>
          <Dropdown
            options={available_modes}
            selected={set_mode}
            onSelected={(value) => act('selectMode', {
              newMode: value,
            })}
          />
        </Section>
        <Section>
          <Box bold>
            LAST SAVED RESULT
            <br />
            <br />
          </Box>
          <Box style={{ "white-space": "pre-line" }} dangerouslySetInnerHTML={textHtml} />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

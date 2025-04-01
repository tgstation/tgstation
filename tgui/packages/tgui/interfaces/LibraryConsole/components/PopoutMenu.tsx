import { useBackend } from 'tgui/backend';
import { Button, Section, Stack } from 'tgui-core/components';

import { LibraryConsoleData } from '../types';

export function PopoutMenu(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { display_lore, screen_state, show_dropdown } = data;

  return (
    <Section fill maxWidth={show_dropdown ? '150px' : '36px'}>
      <Stack vertical fill>
        <Stack.Item>
          <Button
            fluid
            fontSize="13px"
            onClick={() => act('toggle_dropdown')}
            icon={show_dropdown === 1 ? 'chevron-left' : 'chevron-right'}
            tooltip={!show_dropdown && 'Expand'}
          >
            {!!show_dropdown && 'Collapse'}
          </Button>
        </Stack.Item>
        <PopoutEntry id={1} icon="list" text="Inventory" />
        <PopoutEntry id={2} icon="calendar" text="Checkout" />
        <PopoutEntry id={3} icon="server" text="Archive" />
        <PopoutEntry id={4} icon="upload" text="Upload" />
        <PopoutEntry id={5} icon="print" text="Print" />
        {!!display_lore && (
          <PopoutEntry
            id={6}
            icon="question"
            text={screen_state === 6 ? 'Gur Fbeprere' : 'Forbidden Lore'}
            color="black"
            font="copperplate"
          />
        )}
      </Stack>
    </Section>
  );
}

export function PopoutEntry(props) {
  const { act, data } = useBackend<LibraryConsoleData>();

  const { id, text, icon, color, font } = props;
  const { screen_state, show_dropdown } = data;

  const selected_color = color || 'good';
  const deselected_color = color || '';

  return (
    <Stack.Item>
      <Button
        fluid
        fontSize="13px"
        onClick={() =>
          act('set_screen', {
            screen_index: id,
          })
        }
        color={id === screen_state ? selected_color : deselected_color}
        fontFamily={font}
        icon={icon}
        tooltip={!show_dropdown && text}
      >
        {!!show_dropdown && text}
      </Button>
    </Stack.Item>
  );
}

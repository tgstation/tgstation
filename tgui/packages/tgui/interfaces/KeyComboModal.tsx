import { useState } from 'react';
import { Autofocus, Box, Button, Section, Stack } from 'tgui-core/components';
import { isEscape, KEY } from 'tgui-core/keys';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type KeyInputData = {
  init_value: string;
  large_buttons: BooleanLike;
  message: string;
  timeout: number;
  title: string;
};

function isStandardKey(event: React.KeyboardEvent<HTMLDivElement>): boolean {
  return (
    event.key !== KEY.Alt &&
    event.key !== KEY.Control &&
    event.key !== KEY.Shift &&
    !isEscape(event.key)
  );
}

const KEY_CODE_TO_BYOND: Record<string, string> = {
  DEL: 'Delete',
  DOWN: 'South',
  END: 'Southwest',
  HOME: 'Northwest',
  INSERT: 'Insert',
  LEFT: 'West',
  PAGEDOWN: 'Southeast',
  PAGEUP: 'Northeast',
  RIGHT: 'East',
  ' ': 'Space',
  UP: 'North',
};

const DOM_KEY_LOCATION_NUMPAD = 3;

function formatKeyboardEvent(
  event: React.KeyboardEvent<HTMLDivElement>,
): string {
  let text = '';

  if (event.altKey) {
    text += 'Alt';
  }

  if (event.ctrlKey) {
    text += 'Ctrl';
  }

  if (event.shiftKey) {
    text += 'Shift';
  }

  if (event.location === DOM_KEY_LOCATION_NUMPAD) {
    text += 'Numpad';
  }

  if (isStandardKey(event)) {
    const key = event.key.toUpperCase();
    text += KEY_CODE_TO_BYOND[key] || key;
  }

  return text;
}

export function KeyComboModal(props) {
  const { act, data } = useBackend<KeyInputData>();
  const { init_value, large_buttons, message = '', title, timeout } = data;
  const [input, setInput] = useState(init_value);
  const [binding, setBinding] = useState(true);

  function handleKeyDown(event: React.KeyboardEvent<HTMLDivElement>) {
    if (!binding) {
      if (event.key === KEY.Enter) {
        act('submit', { entry: input });
      }
      if (isEscape(event.key)) {
        act('cancel');
      }
      return;
    }

    event.preventDefault();

    if (isStandardKey(event)) {
      setValue(formatKeyboardEvent(event));
      setBinding(false);
      return;
    } else if (isEscape(event.key)) {
      setValue(init_value);
      setBinding(false);
      return;
    }
  }

  function setValue(value: string) {
    if (value === input) {
      return;
    }
    setInput(value);
  }

  // Dynamically changes the window height based on the message.
  const windowHeight =
    130 +
    (message.length > 30 ? Math.ceil(message.length / 3) : 0) +
    (message.length && large_buttons ? 5 : 0);

  return (
    <Window title={title} width={240} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content onKeyDown={handleKeyDown}>
        <Section fill>
          <Autofocus />
          <Stack fill vertical>
            <Stack.Item grow>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                disabled={binding}
                fluid
                textAlign="center"
                onClick={() => {
                  setValue(init_value);
                  setBinding(true);
                }}
              >
                {binding ? 'Awaiting input...' : '' + input}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <InputButtons input={input} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
}

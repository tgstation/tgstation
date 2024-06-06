import { isEscape, KEY } from 'common/keys';
import { useState } from 'react';

import { useBackend, useLocalState } from '../backend';
import { Autofocus, Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type KeyInputData = {
  init_value: string;
  large_buttons: boolean;
  message: string;
  timeout: number;
  title: string;
};

const isStandardKey = (event: React.KeyboardEvent<HTMLDivElement>): boolean => {
  return (
    event.key !== KEY.Alt &&
    event.key !== KEY.Control &&
    event.key !== KEY.Shift &&
    !isEscape(event.key)
  );
};

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
  SPACEBAR: 'Space',
  UP: 'North',
};

const DOM_KEY_LOCATION_NUMPAD = 3;

const formatKeyboardEvent = (
  event: React.KeyboardEvent<HTMLDivElement>,
): string => {
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
};

export const KeyComboModal = (props) => {
  const { act, data } = useBackend<KeyInputData>();
  const { init_value, large_buttons, message = '', title, timeout } = data;
  const [input, setInput] = useState(init_value);
  const [binding, setBinding] = useLocalState('binding', true);

  const setValue = (value: string) => {
    if (value === input) {
      return;
    }
    setInput(value);
  };

  // Dynamically changes the window height based on the message.
  const windowHeight =
    130 +
    (message.length > 30 ? Math.ceil(message.length / 3) : 0) +
    (message.length && large_buttons ? 5 : 0);

  return (
    <Window title={title} width={240} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
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
        }}
      >
        <Section fill>
          <Autofocus />
          <Stack fill vertical>
            <Stack.Item grow>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                disabled={binding}
                content={
                  binding && binding !== null ? 'Awaiting input...' : '' + input
                }
                width="100%"
                textAlign="center"
                onClick={() => {
                  setValue(init_value);
                  setBinding(true);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <InputButtons input={input} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

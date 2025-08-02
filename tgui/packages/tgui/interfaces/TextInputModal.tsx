import { useState } from 'react';
import { Box, Section, Stack, TextArea } from 'tgui-core/components';
import { isEscape } from 'tgui-core/keys';
import { KEY } from 'tgui-core/keys';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type TextInputData = {
  large_buttons: boolean;
  max_length: number;
  message: string;
  multiline: boolean;
  placeholder: string;
  timeout: number;
  title: string;
};

export const sanitizeMultiline = (toSanitize: string) => {
  return toSanitize.replace(/(\n|\r\n){3,}/, '\n\n');
};

export const removeAllSkiplines = (toSanitize: string) => {
  return toSanitize.replace(/[\r\n]+/, '');
};

export const TextInputModal = (props) => {
  const { act, data } = useBackend<TextInputData>();
  const {
    large_buttons,
    max_length,
    message = '',
    multiline,
    placeholder = '',
    timeout,
    title,
  } = data;

  const [input, setInput] = useState(placeholder || '');

  const onType = (value: string) => {
    if (value === input) {
      return;
    }
    const sanitizedInput = multiline
      ? sanitizeMultiline(value)
      : removeAllSkiplines(value);
    setInput(sanitizedInput);
  };

  const visualMultiline = multiline || input.length >= 30;
  // Dynamically changes the window height based on the message.
  const windowHeight =
    135 +
    (message.length > 30 ? Math.ceil(message.length / 4) : 0) +
    (visualMultiline ? 75 : 0) +
    (message.length && large_buttons ? 5 : 0);

  function handleKeyDown(event: React.KeyboardEvent<HTMLDivElement>) {
    if (event.key === KEY.Enter && (!visualMultiline || !event.shiftKey)) {
      act('submit', { entry: input });
    }
    if (isEscape(event.key)) {
      act('cancel');
    }
  }
  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content onKeyDown={handleKeyDown}>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item grow>
              <TextArea
                autoFocus
                autoSelect
                fluid
                height={multiline || input.length >= 30 ? '100%' : '1.8rem'}
                maxLength={max_length}
                onEscape={() => act('cancel')}
                onChange={onType}
                placeholder="Type something..."
                value={input}
              />
            </Stack.Item>
            <Stack.Item>
              <InputButtons
                input={input}
                message={`${input.length}/${max_length || '∞'}`}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

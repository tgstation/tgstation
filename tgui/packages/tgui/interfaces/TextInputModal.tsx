import { Loader } from './common/Loader';
import { InputButtons, Preferences } from './common/InputButtons';
import { useBackend, useLocalState } from '../backend';
import { KEY_ENTER, KEY_ESCAPE } from '../../common/keycodes';
import { Box, Section, Stack, TextArea } from '../components';
import { Window } from '../layouts';

type TextInputData = {
  max_length: number;
  message: string;
  multiline: boolean;
  placeholder: string;
  preferences: Preferences;
  timeout: number;
  title: string;
};

export const TextInputModal = (_, context) => {
  const { act, data } = useBackend<TextInputData>(context);
  const {
    max_length,
    message,
    multiline,
    placeholder,
    preferences,
    timeout,
    title,
  } = data;
  const { large_buttons } = preferences;
  const [input, setInput] = useLocalState<string>(
    context,
    'input',
    placeholder || ''
  );
  const onType = (value: string) => {
    if (value === input) {
      return;
    }
    setInput(value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight
    = 125
    + Math.ceil(message.length / 3)
    + (multiline || input.length >= 30 ? 75 : 0)
    + (message.length && large_buttons ? 5 : 0);

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER) {
            act('submit', { entry: input });
          }
          if (keyCode === KEY_ESCAPE) {
            act('cancel');
          }
        }}>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item grow>
              <InputArea input={input} onType={onType} />
            </Stack.Item>
            <Stack.Item pl={!large_buttons && 5} pr={!large_buttons && 5}>
              <InputButtons
                input={input}
                message={`${input.length}/${max_length}`}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { act, data } = useBackend<TextInputData>(context);
  const { max_length, multiline } = data;
  const { input, onType } = props;

  return (
    <TextArea
      autoFocus
      autoSelect
      height={multiline || input.length >= 30 ? "100%" : "1.8rem"}
      maxLength={max_length}
      onKeyDown={(event) => {
        const keyCode = window.event ? event.which : event.keyCode;
        if (keyCode === KEY_ENTER) {
          act('submit', { entry: input });
        }
        if (keyCode === KEY_ESCAPE) {
          act('cancel');
        }
      }}
      onInput={(_, value) => onType(value)}
      placeholder="Type something..."
      value={input}
    />
  );
};

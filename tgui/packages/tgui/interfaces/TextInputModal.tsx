import { Loader } from './common/Loader';
import { InputButtons, Preferences, Validator } from './common/InputButtons';
import { useBackend, useLocalState } from '../backend';
import { KEY_ENTER } from 'common/keycodes';
import { Box, Input, Section, Stack, TextArea } from '../components';
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
  const [inputIsValid, setInputIsValid] = useLocalState<Validator>(
    context,
    'inputIsValid',
    { isValid: !!placeholder, error: null }
  );
  const onType = (value: string) => {
    setInputIsValid(validateInput(value, max_length));
    setInput(value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight
    = 125
    + Math.ceil(message?.length / 3)
    + (multiline ? 75 : 0)
    + (large_buttons ? 5 : 0);

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER && inputIsValid.isValid) {
            act('submit', { entry: input });
          }
        }}>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <InputArea
              input={input}
              inputIsValid={inputIsValid}
              onType={onType}
            />
            <Stack.Item pl={!large_buttons && 5} pr={!large_buttons && 5}>
              <InputButtons input={input} inputIsValid={inputIsValid} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { data } = useBackend<TextInputData>(context);
  const { multiline } = data;
  const { input, onType } = props;

  if (!multiline) {
    return (
      <Stack.Item>
        <Input
          autoFocus
          fluid
          onInput={(_, value) => onType(value)}
          placeholder="Type something..."
          value={input}
        />
      </Stack.Item>
    );
  } else {
    return (
      <Stack.Item grow>
        <TextArea
          autoFocus
          height="100%"
          onInput={(_, value) => onType(value)}
          placeholder="Type something..."
          value={input}
        />
      </Stack.Item>
    );
  }
};

/** Helper functions */
const validateInput = (input, max_length) => {
  if (!!max_length && input.length > max_length) {
    return { isValid: false, error: `Too long!` };
  } else if (input.length === 0) {
    return { isValid: false, error: null };
  }
  return { isValid: true, error: null };
};

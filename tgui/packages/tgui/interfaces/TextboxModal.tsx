import { useBackend, useSharedState } from '../backend';
import { clamp01 } from 'common/math';
import { KEY_ENTER } from 'common/keycodes';
import { Box, Button, Input, Section, Stack, TextArea } from '../components';
import { Window } from '../layouts';

type TextboxData = {
  max_length: number;
  message: string;
  multiline: boolean;
  placeholder: string;
  timeout: number;
  title: string;
};

type Validator = {
  isValid: boolean;
  error: string | null;
};

export const TextboxModal = (_, context) => {
  const { data } = useBackend<TextboxData>(context);
  const { max_length, message, multiline, placeholder, timeout, title } = data;
  const [input, setInput] = useSharedState(context, 'input', placeholder);
  const [inputIsValid, setInputIsValid] = useSharedState<Validator>(
    context,
    'inputIsValid',
    { isValid: false, error: null }
  );
  const onChangeHandler = (event) => {
    event.preventDefault();
    const target = event.target;
    setInputIsValid(validateInput(target.value, max_length));
    setInput(target.value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight =
    130 + Math.ceil(message.length / 5) + (multiline ? 75 : 0);

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <MessageBox />
          </Stack.Item>
          <InputArea
            input={input}
            inputIsValid={inputIsValid}
            onChangeHandler={onChangeHandler}
          />
          <Stack.Item>
            <ButtonGroup input={input} inputIsValid={inputIsValid} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Timed text input windows!
 * Why? I don't know!
 */
const Loader = (props) => {
  const { value } = props;

  return (
    <div className="AlertModal__Loader">
      <Box
        className="AlertModal__LoaderProgress"
        style={{ width: clamp01(value) * 100 + '%' }}
      />
    </div>
  );
};

/** The message displayed. Scales the window height. */
const MessageBox = (_, context) => {
  const { data } = useBackend<TextboxData>(context);
  const { message } = data;
  return (
    <Section fill>
      <Box color="label">{message}</Box>
    </Section>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { act, data } = useBackend<TextboxData>(context);
  const { multiline } = data;
  const { input, inputIsValid, onChangeHandler } = props;

  if (!multiline) {
    return (
      <Stack.Item>
        <Input
          autoFocus
          fluid
          onInput={(event) => onChangeHandler(event)}
          onKeyDown={(event) => {
            const keyCode = window.event ? event.which : event.keyCode;
            /**
             * Simulate a click when pressing space or enter,
             * allow keyboard navigation, override tab behavior
             */
            if (keyCode === KEY_ENTER && inputIsValid) {
              act('choose', { entry: input });
            }
          }}
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
          onInput={(event) => onChangeHandler(event)}
          onKeyDown={(event) => {
            const keyCode = window.event ? event.which : event.keyCode;
            /**
             * Simulate a click when pressing space or enter,
             * allow keyboard navigation, override tab behavior
             */
            if (keyCode === KEY_ENTER && inputIsValid) {
              act('choose', { entry: input });
            }
          }}
          placeholder="Type something..."
          value={input}
        />
      </Stack.Item>
    );
  }
};

/** The buttons shown at bottom. Will display the error
 * if the input is invalid.
 */
const ButtonGroup = (props, context) => {
  const { act } = useBackend<TextboxData>(context);
  const { input, inputIsValid } = props;
  const { isValid, error } = inputIsValid;

  return (
    <Stack pl={5} pr={5}>
      <Stack.Item>
        <Button
          color="good"
          disabled={!isValid}
          onClick={() => act('submit', { entry: input })}
          width={6}
          textAlign="center">
          Submit
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        {!isValid && (
          <Box color="average" nowrap textAlign="center">
            {error}
          </Box>
        )}
      </Stack.Item>
      <Stack.Item>
        <Button
          color="bad"
          onClick={() => act('cancel')}
          width={6}
          textAlign="center">
          Cancel
        </Button>
      </Stack.Item>
    </Stack>
  );
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

import { useBackend, useSharedState } from '../backend';
import { clamp01 } from 'common/math';
import { KEY_ENTER } from 'common/keycodes';
import { Box, Button, Input, Section, Stack } from '../components';
import { Window } from '../layouts';

type NumboxData = {
  max_value: number | null;
  message: string;
  min_value: number | null;
  placeholder: number;
  timeout: number;
  title: string;
};

type Validator = {
  isValid: boolean;
  error: string | null;
};

export const NumboxModal = (_, context) => {
  const { data } = useBackend<NumboxData>(context);
  const { max_value, message, min_value, placeholder, timeout, title } = data;
  const [input, setInput] = useSharedState(context, 'input', placeholder);
  const [inputIsValid, setInputIsValid] = useSharedState<Validator>(
    context,
    'inputIsValid',
    { isValid: true, error: null }
  );
  const onTypeHandler = (event) => {
    event.preventDefault();
    const target = event.target;
    setInputIsValid(validateInput(target.value, max_value, min_value));
    setInput(target.value);
  };
  const onButtonClickHandler = (value: number) => {
    setInputIsValid(validateInput(value, max_value, min_value));
    setInput(value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight = 130 + Math.ceil(message.length / 5);

  return (
    <Window title={title} width={250} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <MessageBox />
          </Stack.Item>
          <Stack.Item>
            <InputArea
              input={input}
              inputIsValid={inputIsValid}
              onButtonClickHandler={onButtonClickHandler}
              onTypeHandler={onTypeHandler}
            />
          </Stack.Item>
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
  const { data } = useBackend<NumboxData>(context);
  const { message } = data;
  return (
    <Section fill>
      <Box color="label">{message}</Box>
    </Section>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { act, data } = useBackend<NumboxData>(context);
  const { min_value, max_value, placeholder } = data;
  const { input, inputIsValid, onButtonClickHandler, onTypeHandler } = props;

  return (
    <Stack fill>
      <Stack.Item>
        <Button
          icon="angle-double-left"
          onClick={() => onButtonClickHandler(min_value || 0)}
          tooltip="Minimum"
        />
      </Stack.Item>
      <Stack.Item grow>
        <Input
          autoFocus
          fluid
          onInput={(event) => onTypeHandler(event)}
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
          placeholder="Type a number..."
          value={input}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="angle-double-right"
          onClick={() => onButtonClickHandler(max_value || 1000)}
          tooltip="Max"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="redo"
          onClick={() => onButtonClickHandler(placeholder || 0)}
          tooltip="Reset"
        />
      </Stack.Item>
    </Stack>
  );
};

/** The buttons shown at bottom. Will display the error
 * if the input is invalid.
 */
const ButtonGroup = (props, context) => {
  const { act } = useBackend<NumboxData>(context);
  const { input, inputIsValid } = props;
  const { isValid, error } = inputIsValid;

  return (
    <Stack>
      <Stack.Item>
        <Button
          color="good"
          disabled={!isValid}
          onClick={() => act('submit', { entry: input })}
          width={5.5}
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
          width={5.5}
          textAlign="center">
          Cancel
        </Button>
      </Stack.Item>
    </Stack>
  );
};

/** Helper functions */
const validateInput = (input, max_value, min_value) => {
  if (isNaN(input)) {
    return { isValid: false, error: 'Not a number!' };
  } else if (!!max_value && input > max_value) {
    return {
      isValid: false,
      error: `Too high!`,
    };
  } else if (!!min_value && input < min_value) {
    return {
      isValid: false,
      error: `Too low!`,
    };
  } else if (input.length === 0) {
    return { isValid: false, error: null };
  } else {
    return { isValid: true, error: null };
  }
};

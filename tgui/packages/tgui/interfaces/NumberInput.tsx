import { Loader } from "./common/Loader";
import { useBackend, useSharedState } from '../backend';
import { KEY_ENTER } from 'common/keycodes';
import { Box, Button, Input, Section, Stack } from '../components';
import { Window } from '../layouts';

type NumberInputData = {
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

export const NumberInput = (_, context) => {
  const { data } = useBackend<NumberInputData>(context);
  const { max_value, message, min_value, placeholder, timeout, title } = data;
  const [input, setInput] = useSharedState(context, 'input', placeholder);
  const [inputIsValid, setInputIsValid] = useSharedState<Validator>(
    context,
    'inputIsValid',
    { isValid: true, error: null }
  );
  const onType = (event) => {
    event.preventDefault();
    const target = event.target;
    setInputIsValid(validateInput(target.value, max_value, min_value));
    setInput(target.value);
  };
  const onClick = (value: number) => {
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
              onButtonClickHandler={onClick}
              onTypeHandler={onType}
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

/** The message displayed. Scales the window height. */
const MessageBox = (_, context) => {
  const { data } = useBackend<NumberInputData>(context);
  const { message } = data;
  return (
    <Section fill>
      <Box color="label">{message}</Box>
    </Section>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { act, data } = useBackend<NumberInputData>(context);
  const { min_value, max_value, placeholder } = data;
  const { input, inputIsValid, onClick, onType } = props;

  return (
    <Stack fill>
      <Stack.Item>
        <Button
          icon="angle-double-left"
          onClick={() => onClick(min_value || 0)}
          tooltip="Minimum"
        />
      </Stack.Item>
      <Stack.Item grow>
        <Input
          autoFocus
          fluid
          onInput={(event) => onType(event)}
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
          onClick={() => onClick(max_value || 1000)}
          tooltip="Max"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="redo"
          onClick={() => onClick(placeholder || 0)}
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
  const { act } = useBackend<NumberInputData>(context);
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

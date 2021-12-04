import { Loader } from './common/Loader';
import { InputButtons, Preferences, Validator } from './common/InputButtons';
import { useBackend, useSharedState } from '../backend';
import { KEY_ENTER } from 'common/keycodes';
import { Box, Button, Input, Section, Stack } from '../components';
import { Window } from '../layouts';

type NumberInputData = {
  max_value: number | null;
  message: string;
  min_value: number | null;
  placeholder: number;
  preferences: Preferences;
  timeout: number;
  title: string;
};

export const NumberInput = (_, context) => {
  const { data } = useBackend<NumberInputData>(context);
  const {
    max_value,
    message,
    min_value,
    placeholder,
    preferences,
    timeout,
    title,
  } = data;
  const { large_buttons } = preferences;
  const [input, setInput] = useSharedState(context, 'input', placeholder);
  const [inputIsValid, setInputIsValid] = useSharedState<Validator>(
    context,
    'inputIsValid',
    { isValid: true, error: null }
  );
  const onType = (event) => {
    event.preventDefault();
    let value = event.target.value;
    /** Checks the input for leading 0s and removes them.
     *  The if check disables submit on window load.
     */
    if (value) {
      value *= 1;
    }
    setInputIsValid(validateInput(value, max_value, min_value));
    setInput(value);
  };
  const onClick = (value: number) => {
    setInputIsValid(validateInput(value, max_value, min_value));
    setInput(value);
  };
  /** Dynamically changes the window height based on the message. */
  const windowHeight
    = 130 + Math.ceil(message.length / 5) + (large_buttons ? 10 : 0);

  return (
    <Window title={title} width={270} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <InputArea
                input={input}
                inputIsValid={inputIsValid}
                onClick={onClick}
                onType={onType}
              />
            </Stack.Item>
            <Stack.Item>
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
  } else if (input !== 0 && !input) {
    return { isValid: false, error: null };
  } else {
    return { isValid: true, error: null };
  }
};

import { Loader } from './common/Loader';
import { InputButtons } from './common/InputButtons';
import { KEY_ENTER, KEY_ESCAPE } from '../../common/keycodes';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, RestrictedInput, Section, Stack } from '../components';
import { Window } from '../layouts';

type NumberInputData = {
  init_value: number;
  large_buttons: boolean;
  max_value: number | null;
  message: string;
  min_value: number | null;
  timeout: number;
  title: string;
};

export const NumberInputModal = (_, context) => {
  const { act, data } = useBackend<NumberInputData>(context);
  const { init_value, large_buttons, message = "", timeout, title }
    = data;
  const [input, setInput] = useLocalState(context, 'input', init_value);
  const onChange = (value: number) => {
    if (value === input) {
      return;
    }
    setInput(value);
  };
  const onClick = (value: number) => {
    if (value === input) {
      return;
    }
    setInput(value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight
    = 140
    + (message.length > 30 ? Math.ceil(message.length / 3) : 0)
    + (message.length && large_buttons ? 5 : 0);

  return (
    <Window title={title} width={270} height={windowHeight}>
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
            <Stack.Item grow>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <InputArea input={input} onClick={onClick} onChange={onChange} />
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

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { act, data } = useBackend<NumberInputData>(context);
  const { min_value, max_value, init_value } = data;
  const { input, onClick, onChange } = props;

  return (
    <Stack fill>
      <Stack.Item>
        <Button
          disabled={input === min_value}
          icon="angle-double-left"
          onClick={() => onClick(min_value)}
          tooltip={min_value ? `Min (${min_value})` : 'Min'}
        />
      </Stack.Item>
      <Stack.Item grow>
        <RestrictedInput
          autoFocus
          autoSelect
          fluid
          minValue={min_value}
          maxValue={max_value}
          onChange={(_, value) => onChange(value)}
          onEnter={(_, value) => act('submit', { entry: value })}
          value={input}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={input === max_value}
          icon="angle-double-right"
          onClick={() => onClick(max_value)}
          tooltip={max_value ? `Max (${max_value})` : 'Max'}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={input === init_value}
          icon="redo"
          onClick={() => onClick(init_value)}
          tooltip={init_value ? `Reset (${init_value})` : 'Reset'}
        />
      </Stack.Item>
    </Stack>
  );
};

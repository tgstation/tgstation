import { Loader } from './common/Loader';
import { InputButtons, Preferences } from './common/InputButtons';
import { KEY_ENTER, KEY_ESCAPE } from '../../common/keycodes';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';

type NumberInputData = {
  max_value: number | null;
  message: string;
  min_value: number | null;
  init_value: number;
  preferences: Preferences;
  timeout: number;
  title: string;
};

export const NumberInputModal = (_, context) => {
  const { act, data } = useBackend<NumberInputData>(context);
  const { message, init_value, preferences, timeout, title } = data;
  const { large_buttons } = preferences;
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
    = 125
    + Math.ceil(message.length / 3)
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
            <Stack.Item>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <InputArea input={input} onClick={onClick} onChange={onChange} />
            </Stack.Item>
            <Stack.Item pl={!large_buttons && 4} pr={!large_buttons && 4}>
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
  const { data } = useBackend<NumberInputData>(context);
  const { min_value, max_value, init_value } = data;
  const { input, onClick, onChange } = props;

  return (
    <Stack fill>
      <Stack.Item>
        <Button
          disabled={input === min_value}
          icon="angle-double-left"
          onClick={() => onClick(min_value || 0)}
          tooltip={min_value ? `Min (${min_value})` : 'Min'}
        />
      </Stack.Item>
      <Stack.Item grow>
        <NumberInput
          autoFocus
          autoSelect
          fluid
          minValue={min_value}
          maxValue={max_value ? max_value : 1000000}
          onChange={(_, value) => onChange(value)}
          onDrag={(_, value) => onChange(value)}
          value={input}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={!max_value || max_value === 0 || input === max_value}
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

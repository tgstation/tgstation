import { useState } from 'react';
import {
  Box,
  Button,
  RestrictedInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { isEscape, KEY } from 'tgui-core/keys';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type Data = {
  init_value: number;
  large_buttons: BooleanLike;
  max_value: number;
  message: string;
  min_value: number;
  round_value: BooleanLike;
  timeout: number;
  title: string;
};

export function NumberInputModal(props) {
  const { act, data } = useBackend<Data>();
  const {
    init_value,
    large_buttons,
    max_value = 10000,
    message = '',
    min_value = 0,
    round_value,
    timeout,
    title,
  } = data;

  const [value, setValue] = useState(init_value);
  const [isValid, setIsValid] = useState(true);

  // Dynamically changes the window height based on the message.
  const windowHeight =
    140 +
    (message.length > 30 ? Math.ceil(message.length / 3) : 0) +
    (message.length && large_buttons ? 5 : 0);

  function handleKeyDown(event: React.KeyboardEvent<HTMLDivElement>) {
    if (event.key === KEY.Enter && isValid) {
      act('submit', { entry: value });
    }
    if (isEscape(event.key)) {
      act('cancel');
    }
  }

  return (
    <Window title={title} width={270} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content onKeyDown={handleKeyDown}>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item grow>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <Stack fill>
                <Stack.Item>
                  <Button
                    disabled={value === min_value}
                    icon="angle-double-left"
                    onClick={() => setValue(min_value ?? 0)}
                    tooltip={min_value ? `Min (${min_value})` : 'Min'}
                  />
                </Stack.Item>

                <Stack.Item>
                  <Button
                    icon="angle-down"
                    disabled={value <= min_value}
                    onClick={() => setValue((value) => value - 1)}
                  />
                </Stack.Item>

                <Stack.Item grow>
                  <RestrictedInput
                    autoFocus
                    autoSelect
                    fluid
                    allowFloats={!round_value}
                    minValue={min_value}
                    maxValue={max_value}
                    onChange={setValue}
                    onValidationChange={setIsValid}
                    value={value}
                  />
                </Stack.Item>

                <Stack.Item>
                  <Button
                    icon="angle-up"
                    disabled={value >= max_value}
                    onClick={() => setValue((value) => value + 1)}
                  />
                </Stack.Item>

                <Stack.Item>
                  <Button
                    disabled={value === max_value}
                    icon="angle-double-right"
                    onClick={() => setValue(max_value ?? 10000)}
                    tooltip={max_value ? `Max (${max_value})` : 'Max'}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    disabled={value === init_value}
                    icon="redo"
                    onClick={() => setValue(init_value ?? 0)}
                    tooltip={init_value ? `Reset (${init_value})` : 'Reset'}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <InputButtons input={value} disabled={!isValid} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
}

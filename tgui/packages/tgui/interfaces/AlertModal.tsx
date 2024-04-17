import { KEY } from 'common/keys';
import { BooleanLike } from 'common/react';
import { KeyboardEvent, useState } from 'react';

import { useBackend } from '../backend';
import { Autofocus, Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';
import { Loader } from './common/Loader';

type Data = {
  autofocus: BooleanLike;
  buttons: string[];
  large_buttons: BooleanLike;
  message: string;
  swapped_buttons: BooleanLike;
  timeout: number;
  title: string;
};

enum DIRECTION {
  Increment = 1,
  Decrement = -1,
}

export function AlertModal(props) {
  const { act, data } = useBackend<Data>();
  const {
    autofocus,
    buttons = [],
    large_buttons,
    message = '',
    timeout,
    title,
  } = data;

  const [selected, setSelected] = useState(0);

  // Dynamically sets window dimensions
  const windowHeight =
    120 +
    (message.length > 30 ? Math.ceil(message.length / 4) : 0) +
    (message.length && large_buttons ? 5 : 0);

  const windowWidth = 345 + (buttons.length > 2 ? 55 : 0);

  /** Changes button selection, etc */
  function keyDownHandler(event: KeyboardEvent<HTMLDivElement>) {
    switch (event.key) {
      case KEY.Space:
      case KEY.Enter:
        act('choose', { choice: buttons[selected] });
        return;
      case KEY.Escape:
        act('cancel');
        return;
      case KEY.Left:
        event.preventDefault();
        onKey(DIRECTION.Decrement);
        return;
      case KEY.Tab:
      case KEY.Right:
        event.preventDefault();
        onKey(DIRECTION.Increment);
        return;
    }
  }

  /** Manages iterating through the buttons */
  function onKey(direction: DIRECTION) {
    const newIndex = (selected + direction + buttons.length) % buttons.length;
    setSelected(newIndex);
  }

  return (
    <Window height={windowHeight} title={title} width={windowWidth}>
      {!!timeout && <Loader value={timeout} />}
      <Window.Content onKeyDown={keyDownHandler}>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item grow m={1}>
              <Box color="label" overflow="hidden">
                {message}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {!!autofocus && <Autofocus />}
              <ButtonDisplay selected={selected} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
}

/**
 * Displays a list of buttons ordered by user prefs.
 * Technically this handles more than 2 buttons, but you
 * should just be using a list input in that case.
 */
const ButtonDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { buttons = [], large_buttons, swapped_buttons } = data;
  const { selected } = props;

  return (
    <Stack fill reverse={!!swapped_buttons} justify="space-around">
      {buttons.map((button, index) => (
        <Stack.Item grow={large_buttons ? 1 : undefined} key={index}>
          <Button
            fluid
            onClick={() => act('choose', { choice: button })}
            py={large_buttons ? 0.5 : 0}
            selected={selected === index}
            textAlign="center"
            overflowX="hidden"
          >
            {!large_buttons ? button : button.toUpperCase()}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
};

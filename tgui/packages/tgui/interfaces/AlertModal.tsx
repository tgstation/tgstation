import { KeyboardEvent, useState } from 'react';
import { Autofocus, Box, Button, Section, Stack } from 'tgui-core/components';
import { isEscape, KEY } from 'tgui-core/keys';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
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

  // At least one of the buttons has a long text message
  const isVerbose = buttons.some((button) => button.length > 10);
  const largeSpacing = isVerbose && large_buttons ? 20 : 15;

  // Dynamically sets window dimensions
  const windowHeight =
    120 +
    (isVerbose ? largeSpacing * buttons.length : 0) +
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
      case KEY.Left:
        event.preventDefault();
        onKey(DIRECTION.Decrement);
        return;
      case KEY.Tab:
      case KEY.Right:
        event.preventDefault();
        onKey(DIRECTION.Increment);
        return;

      default:
        if (isEscape(event.key)) {
          act('cancel');
          return;
        }
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
            <Stack.Item m={1}>
              <Box color="label" overflow="hidden">
                {message}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              {!!autofocus && <Autofocus />}
              {isVerbose ? (
                <VerticalButtons selected={selected} />
              ) : (
                <HorizontalButtons selected={selected} />
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
}

type ButtonDisplayProps = {
  selected: number;
};

/**
 * Displays a list of buttons ordered by user prefs.
 */
function HorizontalButtons(props: ButtonDisplayProps) {
  const { act, data } = useBackend<Data>();
  const { buttons = [], large_buttons, swapped_buttons } = data;
  const { selected } = props;

  return (
    <Stack fill justify="space-around" reverse={!swapped_buttons}>
      {buttons.map((button, index) => (
        <Stack.Item grow={large_buttons ? 1 : undefined} key={index}>
          <Button
            fluid={!!large_buttons}
            minWidth={5}
            onClick={() => act('choose', { choice: button })}
            overflowX="hidden"
            px={2}
            py={large_buttons ? 0.5 : 0}
            selected={selected === index}
            textAlign="center"
          >
            {!large_buttons ? button : button.toUpperCase()}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}

/**
 * Technically the parent handles more than 2 buttons, but you
 * should just be using a list input in that case.
 */
function VerticalButtons(props: ButtonDisplayProps) {
  const { act, data } = useBackend<Data>();
  const { buttons = [], large_buttons, swapped_buttons } = data;
  const { selected } = props;

  return (
    <Stack
      align="center"
      fill
      justify="space-around"
      reverse={!swapped_buttons}
      vertical
    >
      {buttons.map((button, index) => (
        <Stack.Item
          grow
          width={large_buttons ? '100%' : undefined}
          key={index}
          m={0}
        >
          <Button
            fluid
            minWidth={20}
            onClick={() => act('choose', { choice: button })}
            overflowX="hidden"
            px={2}
            py={large_buttons ? 0.5 : 0}
            selected={selected === index}
            textAlign="center"
          >
            {!large_buttons ? button : button.toUpperCase()}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}

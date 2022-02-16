import { Loader } from './common/Loader';
import { Preferences } from './common/InputButtons';
import { useBackend, useLocalState } from '../backend';
import { KEY_ENTER, KEY_ESCAPE, KEY_LEFT, KEY_RIGHT, KEY_SPACE, KEY_TAB } from '../../common/keycodes';
import { Autofocus, Box, Button, Flex, Section, Stack } from '../components';
import { Window } from '../layouts';

type AlertModalData = {
  autofocus: boolean;
  buttons: string[];
  message: string;
  preferences: Preferences;
  timeout: number;
  title: string;
};

const KEY_DECREMENT = -1;
const KEY_INCREMENT = 1;

export const AlertModal = (_, context) => {
  const { act, data } = useBackend<AlertModalData>(context);
  const {
    autofocus,
    buttons = [],
    message,
    preferences,
    timeout,
    title,
  } = data;
  const { large_buttons } = preferences;
  const [selected, setSelected] = useLocalState<number>(context, 'selected', 0);
  // Dynamically sets window height
  const windowHeight
  = 115
  + (message.length > 30 ? Math.ceil(message.length / 3) : 0)
  + (message.length && large_buttons ? 5 : 0)
  + (buttons.length > 2 ? buttons.length * 25 : 0);
  const onKey = (direction: number) => {
    if (selected === 0 && direction === KEY_DECREMENT) {
      setSelected(buttons.length - 1);
    } else if (selected === buttons.length - 1 && direction === KEY_INCREMENT) {
      setSelected(0);
    } else {
      setSelected(selected + direction);
    }
  };

  return (
    <Window height={windowHeight} title={title} width={325}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(e) => {
          const keyCode = window.event ? e.which : e.keyCode;
          /**
           * Simulate a click when pressing space or enter,
           * allow keyboard navigation, override tab behavior
           */
          if (keyCode === KEY_SPACE || keyCode === KEY_ENTER) {
            act('choose', { choice: buttons[selected] });
          } else if (keyCode === KEY_ESCAPE) {
            act('cancel');
          } else if (
            keyCode === KEY_LEFT
            || (e.shiftKey && keyCode === KEY_TAB)
          ) {
            onKey(KEY_DECREMENT);
          } else if (keyCode === KEY_RIGHT || keyCode === KEY_TAB) {
            onKey(KEY_INCREMENT);
          }
        }}>
        <Section fill>
          <Stack fill vertical>
            <Stack.Item grow m={1}>
              <Box color="label" overflow="hidden">{message}</Box>
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
};

/**
 * Displays a list of buttons ordered by user prefs.
 * Technically this handles more than 2 buttons, but you
 * should just be using a list input in that case.
 */
const ButtonDisplay = (props, context) => {
  const { data } = useBackend<AlertModalData>(context);
  const { buttons = [], preferences } = data;
  const { selected } = props;
  const { large_buttons, swapped_buttons } = preferences;
  const buttonDirection
    = (buttons.length > 2 ? 'column' : 'row')
    + (!swapped_buttons ? '-reverse' : '');

  return (
    <Flex
      align="center"
      direction={buttonDirection}
      fill
      justify="space-around">
      {buttons?.map((button, index) =>
        !!large_buttons && buttons.length < 3 ? (
          <Flex.Item grow key={index}>
            <AlertButton
              button={button}
              id={index.toString()}
              selected={selected === index}
            />
          </Flex.Item>
        ) : (
          <Flex.Item key={index}>
            <AlertButton
              button={button}
              id={index.toString()}
              selected={selected === index}
            />
          </Flex.Item>
        )
      )}
    </Flex>
  );
};

/**
 * Displays a button with variable sizing.
 */
const AlertButton = (props, context) => {
  const { act, data } = useBackend<AlertModalData>(context);
  const { preferences } = data;
  const { large_buttons } = preferences;
  const { button, selected } = props;

  return (
    <Button
      fluid={!!large_buttons}
      height={!!large_buttons && 2}
      onClick={() => act('choose', { choice: button })}
      m={0.5}
      pl={2}
      pr={2}
      pt={large_buttons ? 0.33 : 0}
      selected={selected}
      textAlign="center">
      {!large_buttons ? button : button.toUpperCase()}
    </Button>
  );
};

/**
 * @file
 * @copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * @license MIT
 */

import { Loader } from "./common/Loader";
import { useBackend } from '../backend';
import { Component, createRef } from 'inferno';
import { Box, Flex, Section } from '../components';
import { Window } from '../layouts';
import {
  KEY_ENTER,
  KEY_LEFT,
  KEY_RIGHT,
  KEY_SPACE,
  KEY_TAB,
} from 'common/keycodes';

export class AlertModal extends Component {
  constructor() {
    super();

    this.buttonRefs = [createRef()];
    this.state = { current: 0 };
  }

  componentDidMount() {
    const { data } = useBackend(this.context);
    const { buttons, autofocus } = data;
    const { current } = this.state;
    const button = this.buttonRefs[current].current;

    // Fill ref array with refs for other buttons
    for (let i = 1; i < buttons.length; i++) {
      this.buttonRefs.push(createRef());
    }

    if (autofocus) {
      setTimeout(() => button.focus(), 1);
    }
  }

  setCurrent(current, isArrowKey) {
    const { data } = useBackend(this.context);
    const { buttons } = data;

    // Mimic alert() behavior for tabs and arrow keys
    if (current >= buttons.length) {
      current = isArrowKey ? current - 1 : 0;
    } else if (current < 0) {
      current = isArrowKey ? 0 : buttons.length - 1;
    }

    const button = this.buttonRefs[current].current;

    // Prevents an error from occurring on close
    if (button) {
      setTimeout(() => button.focus(), 1);
    }
    this.setState({ current });
  }

  render() {
    const { act, data } = useBackend(this.context);
    const { title, message, buttons, timeout } = data;
    const { current } = this.state;
    const focusCurrentButton = () => this.setCurrent(current, false);

    return (
      <Window
        title={title}
        width={350}
        height={150}>
        {timeout && <Loader value={timeout} />}
        <Window.Content
          onFocus={focusCurrentButton}
          onClick={focusCurrentButton}>
          <Section fill>
            <Flex direction="column" height="100%">
              <Flex.Item grow={1}>
                <Flex
                  direction="column"
                  className="AlertModal__Message"
                  height="100%">
                  <Flex.Item>
                    <Box m={1}>
                      {message}
                    </Box>
                  </Flex.Item>
                </Flex>
              </Flex.Item>
              <Flex.Item my={2}>
                <Flex className="AlertModal__Buttons">
                  {buttons.map((button, buttonIndex) => (
                    <Flex.Item key={buttonIndex} mx={1}>
                      <div
                        ref={this.buttonRefs[buttonIndex]}
                        className="Button Button--color--default"
                        px={3}
                        onClick={() => act("choose", { choice: button })}
                        onKeyDown={e => {
                          const keyCode = window.event ? e.which : e.keyCode;

                          /**
                           * Simulate a click when pressing space or enter,
                           * allow keyboard navigation, override tab behavior
                           */
                          if (keyCode === KEY_SPACE || keyCode === KEY_ENTER) {
                            act("choose", { choice: button });
                          } else if (
                            keyCode === KEY_LEFT
                            || (e.shiftKey && keyCode === KEY_TAB)
                          ) {
                            this.setCurrent(current - 1, keyCode === KEY_LEFT);
                          } else if (
                            keyCode === KEY_RIGHT || keyCode === KEY_TAB
                          ) {
                            this.setCurrent(current + 1, keyCode === KEY_RIGHT);
                          }
                        }}>
                        {button}
                      </div>
                    </Flex.Item>
                  ))}
                </Flex>
              </Flex.Item>
            </Flex>
          </Section>
        </Window.Content>
      </Window>
    );
  }

}


/**
 * @file
 * @copyright 2020 watermelon914 (https://github.com/watermelon914)
 * @license MIT
 */

import { clamp01 } from 'common/math';
import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Input } from '../components';
import { KEY_DOWN, KEY_UP, KEY_ENTER } from 'common/keycodes';
import { Window } from '../layouts';
import { Component, createRef } from 'inferno';
import { globalEvents } from "../events";

export class ListInput extends Component {
  constructor() {
    super();
    this.inputRef = createRef();

    this.state = {
      showSearchBar: true,
      displayedArray: null,
      selectedButton: null,
    };

    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleKey = this.handleKey.bind(this);
  }

  handleKeyDown(e) {
    const { act, data } = useBackend(this.context);
    const {
      buttons,
    } = data;
    const {
      selectedButton,
    } = this.state;

    e.preventDefault();
    if (e.keyCode === KEY_UP || e.keyCode === KEY_DOWN) {
      let direction = 1;
      if (e.keyCode === KEY_UP) {
        direction = -1;
      }

      let index = 0;
      for (index; index < buttons.length; index++) {
        if (buttons[index] === selectedButton) {
          break;
        }
      }
      index += direction;
      if (index < 0) {
        index = buttons.length - 1;
      } else if (index >= buttons.length) {
        index = 0;
      }
      this.setState({
        selectedButton: buttons[index],
      });
      document.getElementById(buttons[index]).focus();
      return;
    }

    if (e.keyCode === KEY_ENTER) {
      act("choose", { choice: selectedButton });
      return;
    }

    const input = this.inputRef.current?.inputRef?.current;
    if (input) {
      input.value = e.key;
      input.selectionStart = input.selectionEnd = input.value.length;
      input.focus();
    }
  }

  handleKey(key) {
    key.event.preventDefault();
  }

  componentDidMount() {
    globalEvents.on("keydown", this.handleKey);
    setTimeout(() => this.inputRef.current?.inputRef?.current.focus(), 1);
  }

  componentWillUnmount() {
    globalEvents.off("keydown", this.handleKey);
  }

  render() {
    const { act, data } = useBackend(this.context);
    const {
      title,
      message,
      buttons,
      timeout,
    } = data;
    const {
      showSearchBar,
      displayedArray,
      selectedButton,
    } = this.state;

    if (!displayedArray) {
      this.setState({
        displayedArray: buttons,
        selectedButton: buttons[0],
      });
      return;
    }

    return (
      <Window
        title={title}
        width={325}
        height={325}>
        {timeout !== undefined && <Loader value={timeout} />}
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item grow>
              <Section
                fill
                scrollable
                className="ListInput__Section"
                title={message}
                tabIndex={0}
                onKeyDown={this.handleKeyDown}
                buttons={(
                  <Button
                    compact
                    icon="search"
                    color="transparent"
                    selected={showSearchBar}
                    tooltip="Search Bar"
                    tooltipPosition="left"
                    onClick={() => {
                      this.setState({
                        showSearchBar: !showSearchBar,
                        displayedArray: buttons,
                      });
                    }}
                  />
                )}>
                {displayedArray.map(button => (
                  <Button
                    style={{
                      "animation": "none",
                      "transition": "none",
                    }}
                    key={button}
                    color="transparent"
                    fluid
                    id={button}
                    selected={selectedButton === button}
                    onClick={() => {
                      if (selectedButton === button) {
                        act("choose", { choice: button });
                      }
                      else {
                        this.setState({
                          selectedButton: button,
                        });
                      }
                    }}>
                    {button}
                  </Button>
                ))}
              </Section>
            </Stack.Item>
            {showSearchBar && (
              <Stack.Item>
                <Input
                  fluid
                  ref={this.inputRef}
                  onEnter={(e, value) => {
                    act("choose", { choice: selectedButton });
                  }}
                  onInput={(e, value) => {
                    const filteredArray = buttons.filter(val => (
                      val.toLowerCase().search(value.toLowerCase()) !== -1
                    ));
                    this.setState({
                      displayedArray: filteredArray,
                      selectedButton: filteredArray[0],
                    });
                  }}
                />
              </Stack.Item>
            )}
            <Stack.Item>
              <Stack textAlign="center">
                <Stack.Item grow basis={0}>
                  <Button
                    fluid
                    color="good"
                    lineHeight={2}
                    content="Confirm"
                    disabled={selectedButton === null}
                    onClick={() => act("choose", { choice: selectedButton })}
                  />
                </Stack.Item>
                <Stack.Item grow basis={0}>
                  <Button
                    fluid
                    color="bad"
                    lineHeight={2}
                    content="Cancel"
                    onClick={() => act("cancel")}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
}

export const Loader = props => {
  const { value } = props;
  return (
    <div className="ListInput__Loader">
      <Box
        className="ListInput__LoaderProgress"
        style={{
          width: clamp01(value) * 100 + '%',
        }} />
    </div>
  );
};

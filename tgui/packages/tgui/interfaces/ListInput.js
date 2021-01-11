/**
 * @file
 * @copyright 2020 watermelon914 (https://github.com/watermelon914)
 * @license MIT
 */

import { clamp01 } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Section, Input } from '../components';
import { Window } from '../layouts';

const ARROW_KEY_UP = 38;
const ARROW_KEY_DOWN = 40;

let lastScrollTime = 0;

export const ListInput = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    title,
    message,
    buttons,
    timeout,
  } = data;

  // Search
  const [showSearchBar, setShowSearchBar] = useLocalState(
    context, 'search_bar', false);
  const [displayedArray, setDisplayedArray] = useLocalState(
    context, 'displayed_array', buttons);

  // KeyPress
  const [searchArray, setSearchArray] = useLocalState(
    context, 'search_array', []);
  const [searchIndex, setSearchIndex] = useLocalState(
    context, 'search_index', 0);
  const [lastCharCode, setLastCharCode] = useLocalState(
    context, 'last_char_code', null);

  // Selected Button
  const [selectedButton, setSelectedButton] = useLocalState(
    context, 'selected_button', buttons[0]);
  return (
    <Window
      title={title}
      width={325}
      height={325}
      resizable
    >
      {timeout !== undefined && <Loader value={timeout} />}
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item grow={1}>
            <Section
              scrollable
              className="ListInput__Section"
              width="100%"
              fill
              title={message}
              tabIndex={0}
              onKeyDown={e => {
                e.preventDefault();
                if (lastScrollTime > performance.now()) {
                  return;
                }
                lastScrollTime = performance.now() + 125;

                if (e.keyCode === ARROW_KEY_UP || e.keyCode === ARROW_KEY_DOWN)
                {
                  let direction = 1;
                  if (e.keyCode === ARROW_KEY_UP) direction = -1;

                  let index = 0;
                  for (index; index < buttons.length; index++) {
                    if (buttons[index] === selectedButton) break;
                  }
                  index += direction;
                  if (index < 0) index = buttons.length-1;
                  else if (index >= buttons.length) index = 0;
                  setSelectedButton(buttons[index]);
                  setLastCharCode(null);
                  document.getElementById(buttons[index]).focus();
                  return;
                }

                const charCode = String.fromCharCode(e.keyCode).toLowerCase();
                if (!charCode) return;

                let foundValue;
                if (charCode === lastCharCode && searchArray.length > 0) {
                  const nextIndex = searchIndex + 1;

                  if (nextIndex < searchArray.length) {
                    foundValue = searchArray[nextIndex];
                    setSearchIndex(nextIndex);
                  }
                  else {
                    foundValue = searchArray[0];
                    setSearchIndex(0);
                  }
                }
                else {
                  const resultArray = displayedArray.filter(value =>
                    value.substring(0, 1).toLowerCase() === charCode
                  );

                  if (resultArray.length > 0) {
                    setSearchArray(resultArray);
                    setSearchIndex(0);
                    foundValue = resultArray[0];
                  }
                }

                if (foundValue) {
                  setLastCharCode(charCode);
                  setSelectedButton(foundValue);
                  document.getElementById(foundValue).focus();
                }
              }}
              buttons={(
                <Button
                  icon="search"
                  color="transparent"
                  selected={showSearchBar}
                  tooltip="Search Bar"
                  tooltipPosition="left"
                  onClick={() => {
                    setShowSearchBar(!showSearchBar);
                    setDisplayedArray(buttons);
                  }}
                  compact
                />
              )}
            >
              <Flex wrap>
                {displayedArray.map(button => (
                  <Flex.Item key={button} basis="100%">
                    <Button
                      color="transparent"
                      content={button}
                      id={button}
                      width="100%"
                      selected={selectedButton === button}
                      onClick={() => {
                        if (selectedButton === button) {
                          act("choose", { choice: button });
                        }
                        else {
                          setSelectedButton(button);
                        }
                        setLastCharCode(null);
                      }}
                      onComponentDidMount={dom =>
                        selectedButton === button && dom.focus()}
                    />
                  </Flex.Item>
                ))}
              </Flex>
            </Section>
          </Flex.Item>
          {showSearchBar && (
            <Flex.Item mt={1}>
              <Input
                fluid
                onInput={(e, value) => setDisplayedArray(
                  buttons.filter(val =>
                    val.toLowerCase().search(value.toLowerCase()) !== -1
                  )
                )}
              />
            </Flex.Item>
          )}
          <Flex.Item mt={1}>
            <Flex textAlign="center">
              <Flex.Item grow={1} basis={0}>
                <Button
                  fluid
                  color="bad"
                  lineHeight={2}
                  content="Cancel"
                  onClick={() => act("cancel")}
                />
              </Flex.Item>
              <Flex.Item grow={1} basis={0} ml={1}>
                <Button
                  fluid
                  color="good"
                  lineHeight={2}
                  content="Confirm"
                  disabled={selectedButton === null}
                  onClick={() => act("choose", { choice: selectedButton })}
                />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

export const Loader = props => {
  const { value } = props;
  return (
    <div
      className="ListInput__Loader">
      <Box
        className="ListInput__LoaderProgress"
        style={{
          width: clamp01(value) * 100 + '%',
        }} />
    </div>
  );
};

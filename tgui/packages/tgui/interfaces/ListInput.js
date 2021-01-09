/**
 * @file
 * @copyright 2020 watermelon914 (https://github.com/watermelon914)
 * @license MIT
 */

import { clamp01 } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Section, Input } from '../components';
import { Window } from '../layouts';

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
  const [showSearchBar, setShowSearchBar] = useLocalState(context, "search_bar", false);
  const [displayedArray, setDisplayedArray] = useLocalState(context, "displayed_array", buttons);

  // KeyPress
  const [searchArray, setSearchArray] = useLocalState(context, "search_array", []);
  const [searchIndex, setSearchIndex] = useLocalState(context, "search_index", 0);
  const [lastCharCode, setLastCharCode] = useLocalState(context, "last_char_code", null);

  // Selected Button
  const [selectedButton, setSelectedButton] = useLocalState(context, "selected_button", null);
  return (
    <Window
      title={title}
      width={325}
      height={325}
    >
      {timeout !== undefined && <Loader value={timeout} />}
      <Window.Content>
        <Section fill>
          <Flex
            height={showSearchBar? "80%" : "90%"}
          >
            <Section
              scrollable
              width="100%"
              fill
              title={message}
              tabIndex={0}
              onKeyDown={e => {
                const charCode = String.fromCharCode(e.keyCode);
                if (!charCode || lastScrollTime > performance.now()) return;
                lastScrollTime = performance.now() + 150;

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
                    value.substring(0, 1) === String.fromCharCode(e.keyCode)
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
                  icon="cog"
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
              level={2}
            >
              <Flex
                wrap="wrap"
              >
                {displayedArray.map(button => (
                  <Flex.Item key={button} basis="100%">
                    <Button
                      color="transparent"
                      content={button}
                      id={button}
                      width="100%"
                      selected={selectedButton === button}
                      onClick={() => {
                        (selectedButton === button)
                          ? act("choose", { choice: button }): setSelectedButton(button);
                        setLastCharCode(null);
                      }}
                    />
                  </Flex.Item>
                ))}
              </Flex>
            </Section>
          </Flex>
          {showSearchBar && (
            <Flex width="100%" mt={1}>
              <Input
                width="100%"
                onInput={(e, value) => setDisplayedArray(
                  buttons.filter(val =>
                    val.toLowerCase().search(value.toLowerCase()) !== -1
                  )
                )}
              />
            </Flex>
          )}
          <Flex width="100%" mt={1}>
            <Button
              height="100%"
              width="100%"
              color="good"
              content="Confirm"
              disabled={selectedButton === null}
              onClick={() => act("choose", { choice: selectedButton })}
            />
            <Button
              height="100%"
              width="100%"
              color="bad"
              content="Cancel"
              onClick={() => act("cancel")}
            />
          </Flex>
        </Section>
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

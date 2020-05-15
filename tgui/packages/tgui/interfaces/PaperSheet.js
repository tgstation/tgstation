/**
 * @file
 * @copyright 2020 Paul Bruner
 * @license MIT
 */


import { toTitleCase } from 'common/string';
import { Box, Flex, Button, TextArea } from '../components';
import { useBackend, useSharedState, useLocalState } from '../backend';
import { Window } from '../layouts';
// import marked from 'marked';
import { marked } from 'common/marked/marked';
import { isFalsy } from 'common/react';

import { createLogger } from '../logging';

const logger = createLogger('PaperSheet');


export const PaperSheet = (props, context) => {
  const { act, data } = useBackend(context);
  // https://github.com/segment-boneyard/socrates/blob/master/libs/marked.js
  // his is older code where the updated
  const {
    text = "",
    edit_sheet,
    paper_color="white",
    pen_color="black",
    ...rest
  } = data;
  const [marked_value, setMarked]
    = useLocalState(context, 'marked_state', text);
  const handleOnInput = (e, value) => {
    // Need to fix cut and paste humm
    setMarked(value);
  };

  const readSheet = marked_text => {
    return (
      <Box p="0px" textColor={pen_color} backgroundColor={pen_color}
        width="auto" height={(window.innerHeight) + "px"}>
        {marked(isFalsy(marked_text) ? '' : marked_text,
          { breaks: true, smartypants: true })}
      </Box>
    );
  };
  const editSheet = () => {
    return (
      <Flex direction="column" justify="center">
        <Flex.Item>
          <Button.Confirm
            content="FINISH"
            onClick={() => act('save', { 'text': marked_value })}
          />
        </Flex.Item>
        <Flex.Item>
          <Flex>
            <Flex.Item width="50%" >
              <TextArea fluid height={(window.innerHeight-60) + "px"}
                onInput={handleOnInput} />
            </Flex.Item>
            <Flex.Item width="50%">
              {readSheet(marked_value)}
            </Flex.Item>
          </Flex>
        </Flex.Item>
      </Flex>
    );
  };

  return (
    <Window resizable theme="paper">
      <Window.Content textColor={pen_color} backgroundColor={pen_color} >
        {edit_sheet ? editSheet : readSheet(text)}
      </Window.Content>
    </Window>
  );
};

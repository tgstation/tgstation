/**
 * @file
 * @copyright 2020
 * @author Original Warlockd (https://github.com/warlockd)
 * @author Changes stylemistake
 * @license MIT
 */


import { toTitleCase } from 'common/string';
import { Tabs, Fragment, Box, Flex, Button, TextArea } from '../components';
import { useBackend, useSharedState, useLocalState } from '../backend';
import { Window } from '../layouts';
// import marked from 'marked';
import { marked } from 'common/marked/marked';
import { isFalsy } from 'common/react';

import { createLogger } from '../logging';

const logger = createLogger('PaperSheet');

const PaperSheetView = (props, context) => {
  const { data } = useBackend(context);
  const { text } = data;
  const {
    paper_color = "white",
    pen_color = "black",
  } = data;
  const {
    value = text || '',
    ...rest
  } = props;
  return (
    <Box
      backgroundColor={paper_color}
      color={pen_color}
      {...rest}>
      {marked(value, {
        breaks: true,
        smartypants: true,
      })}
    </Box>
  );
};

const PaperSheetEdit = (props, context) => {
  const { act, data } = useBackend(context);
  const [text, setText] = useLocalState(context, 'text', data.text || '');
  const [
    previewSelected,
    setPreviewSelected,
  ] = useLocalState(context, 'preview', "Preview");
  return (
    <Flex height="100%" direction="column">
      <Flex.Item height="1.5em">
        <Tabs>
          <Tabs.Tab
            key="marked_edit"
            textColor={'black'}
            backgroundColor={previewSelected === "Edit" ? "grey" : "white"}
            selected={previewSelected === "Edit"}
            onClick={() => setPreviewSelected("Edit")}>
            Edit
          </Tabs.Tab>
          <Tabs.Tab
            key="marked_preview"
            textColor={'black'}
            backgroundColor={previewSelected === "Preview" ? "grey" : "white"}
            selected={previewSelected === "Preview"}
            onClick={() => setPreviewSelected("Preview")}>
            Preview
          </Tabs.Tab>
          <Tabs.Tab
            key="marked_done"
            textColor={'black'}
            backgroundColor={previewSelected === "confirm"
              ? "red"
              : previewSelected === "save"
                ? "grey"
                : "white"}
            selected={previewSelected === "confirm"
              || previewSelected === "save"}
            onClick={() => {
              if (previewSelected === "confirm") {
                act('save', { text });
              } else {
                setPreviewSelected("confirm");
              }
            }}>
            { previewSelected === "confirm" ? "confirm" : "save" }
          </Tabs.Tab>
        </Tabs>

      </Flex.Item>
      <Flex.Item
        position="relative"
        grow={1}
        shrink={0}
        basis={1}>

        {previewSelected === "Edit" && (
          <TextArea
            backgroundColor="white"
            textColor="black"
            height={(window.innerHeight - 80)+ "px"}
            onInput={(e, value) => setText(value)} />
        ) || (
          <PaperSheetView value={text} />
        )}
      </Flex.Item>
    </Flex>
  );
};

export const PaperSheet = (props, context) => {
  const { data } = useBackend(context);
  const {
    edit_sheet,
    paper_color = "white",
    pen_color = "black",
  } = data;
  return (
    <Window resizable theme="paper" >
      <Window.Content>
        {edit_sheet && (
          <PaperSheetEdit />
        ) || (
          <PaperSheetView fillPositionedParent />
        )}
      </Window.Content>
    </Window>
  );
};

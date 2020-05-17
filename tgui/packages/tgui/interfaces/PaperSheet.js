/**
 * @file
 * @copyright 2020
 * @author Original Warlockd (https://github.com/warlockd)
 * @author Changes stylemistake
 * @license MIT
 */

import { Tabs, Box, Flex, Button, TextArea } from '../components';
import { useBackend, useSharedState, useLocalState } from '../backend';
import { Window } from '../layouts';
// import marked from 'marked';
import marked from 'marked';


import { createLogger } from '../logging';
import { Fragment } from 'inferno';

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
  const innerHTML = { __html:
    marked(value, { breaks: true, smartypants: true }) };
  return (
    <Box
      backgroundColor={paper_color}
      color={pen_color}
      {...rest}
      dangerouslySetInnerHTML={innerHTML} />
  );
};

const PaperSheetEdit = (props, context) => {
  const { act, data } = useBackend(context);
  const [text, setText] = useLocalState(context, 'text', data.text || '');
  const [
    previewSelected,
    setPreviewSelected,
  ] = useLocalState(context, 'preview', "Preview");
  const {
    paper_color = "white",
    pen_color = "black",
  } = data;
  return (
    <Flex direction="column">
      <Flex.Item>
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
        grow={1}
        basis={1}>
        {previewSelected === "Edit" && (
          <TextArea
            value={text}
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
  } = data;
  return (
    <Window resizable theme="paper">
      <Window.Content scrollable>
        {edit_sheet && (
          <PaperSheetEdit />
        ) || (
          <PaperSheetView fillPositionedParent />
        )}
      </Window.Content>
    </Window>
  );
};

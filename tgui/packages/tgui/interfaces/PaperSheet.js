/**
 * @file
 * @copyright 2020 WarlockD (https://github.com/warlockd)
 * @author Original WarlockD (https://github.com/warlockd)
 * @author Changes stylemistake
 * @license MIT
 */

import { Tabs, Box, Flex, Button, TextArea } from '../components';
import { useBackend, useSharedState, useLocalState } from '../backend';
import { Window } from '../layouts';
// import marked from 'marked';
import marked from 'marked';
import DOMPurify from 'dompurify';
// There is a sanatize option in marked but they say its deprecated.
// Might as well use a proper one then

import { createLogger } from '../logging';
import { Fragment } from 'inferno';

const logger = createLogger('PaperSheet');

const run_marked_default = value => {
  const sanitizer = DOMPurify.sanitize;
  // too much?
  // return sanitizer(marked(sanitizer(value),
  //   { breaks: true, smartypants: true });
  return sanitizer(marked(value,
    { breaks: true, smartypants: true }));
};

const PaperSheetView = (props, context) => {
  const { data } = useBackend(context);
  const {
    paper_color = "white",
    pen_color = "black",
    text = '',
  } = data;
  const {
    value = text || '',
    ...rest
  } = props;
  // We use this for caching so we don't keep refreshing it each time
  const [marked_text, setMarkedText] = useLocalState(context, 'marked_text',
    { __html: run_marked_default(value) });
  return (
    <Box
      backgroundColor={paper_color}
      color={pen_color}
      {...rest}
      dangerouslySetInnerHTML={marked_text} />
  );
};

const PaperSheetEdit = (props, context) => {
  const { act, data } = useBackend(context);
  const [text, setText] = useLocalState(context, 'text', data.text || '');
  const [marked_text, setMarkedText] = useLocalState(context, 'marked_text',
    { __html: run_marked_default(text) });
  const [
    previewSelected,
    setPreviewSelected,
  ] = useLocalState(context, 'preview', "Preview");
  const {
    paper_color = "white",
    pen_color = "black",
  } = data;
  const onInputHandler = (e, value) => {
    if (value.length < 1000) {
      setText(value);
      setMarkedText({ __html: run_marked_default(value) });
    } else {
      setText(value.substr(1000));
    }
  };

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
            onInput={onInputHandler} />
        ) || (
          <PaperSheetView />
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

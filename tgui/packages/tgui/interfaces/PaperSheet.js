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
import marked from 'marked';
import DOMPurify from 'dompurify';
// There is a sanatize option in marked but they say its deprecated.
// Might as well use a proper one then

import { createLogger } from '../logging';
import { Fragment } from 'inferno';
const logger = createLogger('PaperSheet');

// Override function, any links and images should
// be just converted to text
const walkTokens = token => {
  switch (token.type) {
    case 'link':
    case 'image':
      token.type = 'text';
      // Once asset system is up change to some default image
      // or rewrite for icon images
      token.href = "";
      break;
  }
};

const run_marked_default = value => {
  const clean = DOMPurify.sanitize(value,
    // { FORBID_TAGS: ['a'] }
    { ALLOWED_TAGS: [] } // Fuck html, you can't have any of it
  );
  return marked(clean,
    { breaks: true,
      smartypants: true,
      smartLists: true,
      walkTokens: walkTokens,
      // Once assets are fixed might need to change this for them
      baseUrl: "thisshouldbreakhttp",
    });
};

const PaperSheetView = (props, context) => {
  const { data } = useBackend(context);
  const {
    paper_color = "#FFFFFF",
    pen_color = "#000000",
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
      opacity={1}
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
                act('save', { text: DOMPurify.sanitize(text) });
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
            backgroundColor="#FFFFFF"
            textColor="#000000"
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

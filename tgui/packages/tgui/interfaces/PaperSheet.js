/**
 * @file
 * @copyright 2020 WarlockD (https://github.com/warlockd)
 * @author Original WarlockD (https://github.com/warlockd)
 * @author Changes stylemistake
 * @license MIT
 */
import { Component } from 'inferno';
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
const MAX_TEXT_LENGTH = 1000;     // Question, should we send this with ui_data?
// Override function, any links and images should
// kill any other marked tokens we don't want here
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

const sanatize_text = value => {
  // This is VERY important to think first if you NEED
  // the tag you put in here.  We are pushing all this
  // though dangerouslySetInnerHTML and even though
  // the default DOMPurify kills javascript, it dosn't
  // kill href links or such
  return DOMPurify.sanitize(value,
    { ALLOWED_TAGS:
        ['br', 'code', 'li', 'p', 'pre',
          'span', 'table', 'td', 'tr',
          'th', 'ul', 'font', 'b', 'center'] }
  );
};

const run_marked_default = value => {

  return marked(sanatize_text(value),
    { breaks: true,
      smartypants: true,
      smartLists: true,
      walkTokens: walkTokens,
      // Once assets are fixed might need to change this for them
      baseUrl: "thisshouldbreakhttp",
    });
};

// got to make this a full component if we
// want to control updates
class PaperSheetView extends Component {
  constructor(props, context) {
    super(props,context);
    const {
      value = '',
    } = props;
    this.state = {
      marked: { __html: run_marked_default(value) },
      raw_text: value,
    };
  }
  shouldComponentUpdate(nextProps, nextState) {
    if (nextProps.value !== this.props.value
        && nextProps.value !== this.state.raw_text) {
      // first check if the parrent updated us
      // if so queue a state change, then
      // skip to the state change
      const new_text = nextProps.value;
      this.setState({ marked: { __html: run_marked_default(new_text) },
        raw_text: new_text });
    } else if (nextState.raw_text !== this.state.raw_text) {
      // ok, we are at the queued state change, lets do an update
      return false;
    }
    return true; // only update on state changes
  }

  render() {
    const {
      value,
      ...rest
    } = this.props;
    return (
      <Box {...rest}
        dangerouslySetInnerHTML={this.state.marked} />
    );
  }
}
// ugh.  So have to turn this into a full component too if I want to keep updates
// low and keep the wierd flashing down
class PaperSheetEdit extends Component {
  constructor(props, context) {
    this.state = {
      previewSelected: "Edit",
      old_text: props.value || "",
      textarea_text:"",
      combined_text: props.value || "",

    }
  }


  shouldComponentUpdate(nextProps, nextState) {
    if(nextState.previewSelected != this.state.previewSelected) {
      // change tab, so we want to update for sure
      return true;
    }
    return false; // otherwise there is no point
  }

  onInputHandler(e, value) {
    if (value !== his.state.textarea_text) {
      const combined_length = his.state.old_text.length + his.state.textarea_text.length;
      if (combined_length > MAX_TEXT_LENGTH) {
        if ((combined_length - MAX_TEXT_LENGTH) >= value.length) {
          value='';   // basicly we cannot add any more text to the paper
        } else {
          value = value.substr(0, value.length- (combined_length - MAX_TEXT_LENGTH));
        }
        // we check again to save an update
        if (value === this.state.textarea_text) { return; }// do nooothing
      }
      const combined_text = this.state.old_text + this.state.textarea_text;
      this.setState({ { __new_text: value, __combined_text: combined_text });
  };
  render()
    const { act, data } = useBackend(this.context);
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
              value={editedText.__new_text}
              backgroundColor="#FFFFFF"
              textColor="#000000"
              height={(window.innerHeight - 80) + "px"}
              onInput={onInputHandler} />
          ) || (
            <PaperSheetView
              value={editedText.__combined_text}
              backgroundColor={paper_color}
              textColor={pen_color} />
          )}
        </Flex.Item>
      </Flex>
    );
  }
};

export const PaperSheet = (props, context) => {
  const { data } = useBackend(context);
  const {
    edit_sheet,
    text,
    paper_color = "white",
    pen_color = "black",
    pen_font = "Verdana",
  } = data;
  return (
    <Window resizable theme="paper">
      <Window.Content scrollable>
        {edit_sheet && (
          <PaperSheetEdit value={text} backgroundColor={paper_color} textColor={pen_color} textFont={pen_font} >
        ) || (
          <PaperSheetView fillPositionedParent value={text} />
        )}
      </Window.Content>
    </Window>
  );
};

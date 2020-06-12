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
import { classes } from "common/react";
// There is a sanatize option in marked but they say its deprecated.
// Might as well use a proper one then

import { createLogger } from '../logging';
import { Fragment } from 'inferno';
import { vecCreate, vecAdd, vecSubtract } from 'common/vector';
const logger = createLogger('PaperSheet');
const MAX_TEXT_LENGTH = 1000; // Question, should we send this with ui_data?
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
  return DOMPurify.sanitize(value, {
    ALLOWED_TAGS: [
      'br', 'code', 'li', 'p', 'pre',
      'span', 'table', 'td', 'tr',
      'th', 'ul', 'ol', 'menu', 'font', 'b', 'center',
    ],
  });
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

const pauseEvent = e => {
  if (e.stopPropagation) { e.stopPropagation(); }
  if (e.preventDefault) { e.preventDefault(); }
  e.cancelBubble=true;
  e.returnValue=false;
  return false;
};

const Stamp = (props, context) => {
  const {
    image,
    opacity,
    ...rest
  } = props;

  const matrix_trasform = 'rotate(' + image.rotate
    + 'deg) translate(' + image.x + 'px,' + image.y + 'px)';
  const stamp_trasform = {
    'transform': matrix_trasform,
    '-ms-transform': matrix_trasform,
    '-webkit-transform': matrix_trasform,
    'opacity': opacity || 1.0,
    'position': 'absolute',
  };
  return (
    <div
      className={classes([
        'paper121x54',
        image.sprite,
      ])}
      style={stamp_trasform}
    />
  );
};

// got to make this a full component if we
// want to control updates
class PaperSheetView extends Component {
  constructor(props, context) {
    super(props, context);
    const {
      value = '',
      stamps,
    } = props;
    this.state = {
      marked: { __html: run_marked_default(value) },
      raw_text: value,
      stamps: stamps || [],
    };
  }
  shouldComponentUpdate(nextProps, nextState) {
    if (nextState.raw_text !== this.state.raw_text
      || nextState.stamps.length !== this.state.stamps.length) {
      // ok, we are at the queued state change, lets do an update
      // or do one if the stamps get updated
      return false;
    }
    if (nextProps.stamps
        && nextProps.stamps.length !== this.state.stamps.length) {
      this.setState({ stamps: nextProps.stamps });
    }
    if ((nextProps.value !== this.props.value
        && nextProps.value !== this.state.raw_text)) {
      // first check if the parrent updated us
      // if so queue a state change, then
      // skip to the state change
      this.setState({ marked: { __html: run_marked_default(nextProps.value) },
        raw_text: nextProps.value });
    }
    return true;
  }
  render() {
    const {
      value,
      stamps,
      ...rest
    } = this.props;
    const stamp_list = this.state.stamps;
    return (
      <Box position="relative" {...rest} >
        <Box position="absoulte" {...rest} top={0} left={0}
          dangerouslySetInnerHTML={this.state.marked} />
        {stamp_list.map((o, i) => (
          <Stamp key={o[0] + i}
            image={{ sprite: o[0], x: o[1], y: o[2], rotate: o[3] }} />
        ))}
      </Box>
    );
  }
}
// again, need the states for dragging and such
class PaperSheetStamper extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      x: 0,
      y: 0,
      rotate: 0,
    };
  }
  findStampPosition(e) {
    const position = {
      x: event.pageX,
      y: event.pageY,
    };

    const offset = {
      left: e.target.offsetLeft,
      top: e.target.offsetTop,
    };

    let reference = e.target.offsetParent;

    while (reference) {
      offset.left += reference.offsetLeft;
      offset.top += reference.offsetTop;
      reference = reference.offsetParent;
    }

    const pos_x = position.x - offset.left;
    const pos_y = position.y - offset.top;
    const pos = vecCreate(pos_x, pos_y);

    const center_offset = vecCreate((121/2), (51/2));
    const center = vecSubtract(pos, center_offset);
    return center;
  }
  handleMouseMove(e) {
    const pos = this.findStampPosition(e);
    // center offset of stamp
    pauseEvent(e);
    this.setState({ x: pos[0], y: pos[1] });
  }

  handleMouseClick(e) {
    const pos = this.findStampPosition(e);
    const { act, data } = useBackend(this.context);
    act("stamp", { x: pos[0], y: pos[1], r: this.state.rotate });
    this.setState({ x: pos[0], y: pos[1] });

  }
  handleWheel(e) {
    const rotate_amount = e.deltaY > 0 ? 15 : -15;
    if (e.deltaY < 0 && this.state.rotate === 0) {
      this.setState({ rotate: (360+rotate_amount) });
    } else if (e.deltaY > 0 && this.state.rotate === 360) {
      this.setState({ rotate: rotate_amount });
    } else {
      const rotate = { rotate: rotate_amount + this.state.rotate };
      this.setState(() => rotate);
    }
    pauseEvent(e);
    logger.log("while pos: (" + e.deltaY + ", " + rotate_amount+ ")");
  }

  render() {
    const {
      value,
      stamp_class,
      stamps,
      ...rest
    } = this.props;
    const stamp_list = stamps || [];
    const current_pos = {
      sprite: stamp_class,
      x: this.state.x,
      y: this.state.y,
      rotate: this.state.rotate,
    };
    return (
      <Box position="absoulte" onClick={this.handleMouseClick.bind(this)}
        onMouseMove={this.handleMouseMove.bind(this)} {...rest}>
        <PaperSheetView fillPositionedParent={1}
          value={value} stamps={stamp_list} />
        <Stamp
          opacity={0.5} image={current_pos} />
      </Box>
    );
  }
}

// ugh.  So have to turn this into a full
// component too if I want to keep updates
// low and keep the wierd flashing down
class PaperSheetEdit extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      previewSelected: "Edit",
      old_text: props.value || "",
      textarea_text: "",
      combined_text: props.value || "",
    };
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (nextState.previewSelected !== this.state.previewSelected
      || this.state.textarea_text !== nextState.textarea_text) {
      // change tab, so we want to update for sure
      return true;
    }
    return false; // otherwise there is no point
  }
  // sets up combined text from state to make the preview to be as close
  // to what it will look like.  Its all fixed once its submited
  createPreviewText(text) {
    const { act, data } = useBackend(this.context);
    if (data.is_crayon) {
      return this.state.old_text
      + "<font face=\"" + data.pen_font
      + "\" color=\"" + data.pen_color
      + "\"><b>" + text + "</b></font>";
    } else {
      return this.state.old_text
        + "<font face=\"" + data.pen_font
        + "\" color=\"" + data.pen_color
        + "\">" + text + "</font>";
    }
  }
  onInputHandler(e, value) {
    if (value !== this.state.textarea_text) {
      const combined_length = this.state.old_text.length
        + this.state.textarea_text.length;
      if (combined_length > MAX_TEXT_LENGTH) {
        if ((combined_length - MAX_TEXT_LENGTH) >= value.length) {
          value = ''; // basicly we cannot add any more text to the paper
        } else {
          value = value.substr(0, value.length
            - (combined_length - MAX_TEXT_LENGTH));
        }
        // we check again to save an update
        if (value === this.state.textarea_text) { return; }// do nooothing
      }
      const combined_text = this.createPreviewText(this.state.textarea_text);
      this.setState(() => {
        return { textarea_text: value,
          combined_text: combined_text }; });
    }
  }
  // the final update send to byond, final upkeep
  finalUpdate(text) {
    return sanatize_text(text + "\n \n"); // add an end line
  }
  render() {
    const { act, data } = useBackend(this.context);
    const {
      value="",
      backgroundColor,
      textColor,
      textFont,
      stamps,
      ...rest
    } = this.props;

    return (
      <Flex direction="column" fillPositionedParent={1}>
        <Flex.Item>
          <Tabs>
            <Tabs.Tab
              key="marked_edit"
              textColor={'black'}
              backgroundColor={this.state.previewSelected === "Edit"
                ? "grey"
                : "white"}
              selected={this.state.previewSelected === "Edit"}
              onClick={() => this.setState({ previewSelected: "Edit" })}>
              Edit
            </Tabs.Tab>
            <Tabs.Tab
              key="marked_preview"
              textColor={'black'}
              backgroundColor={this.state.previewSelected === "Preview"
                ? "grey"
                : "white"}
              selected={this.state.previewSelected === "Preview"}
              onClick={() => this.setState({ previewSelected: "Preview" })}>
              Preview
            </Tabs.Tab>
            <Tabs.Tab
              key="marked_done"
              textColor={'black'}
              backgroundColor={this.state.previewSelected === "confirm"
                ? "red"
                : this.state.previewSelected === "save"
                  ? "grey"
                  : "white"}
              selected={this.state.previewSelected === "confirm"
                || this.state.previewSelected === "save"}
              onClick={() => {
                if (this.state.previewSelected === "confirm") {
                  act('save',
                    { text: this.finalUpdate(this.state.textarea_text) });
                } else {
                  this.setState({ previewSelected: "confirm" });
                }
              }}>
              { this.state.previewSelected === "confirm" ? "confirm" : "save" }
            </Tabs.Tab>
          </Tabs>

        </Flex.Item>
        <Flex.Item
          grow={1}
          basis={1}>
          {this.state.previewSelected === "Edit" && (
            <TextArea
              value={this.state.textarea_text}
              backgroundColor="#FFFFFF"
              textColor="#000000"
              textFont={textFont}
              height={(window.innerHeight - 80) + "px"}
              onInput={this.onInputHandler.bind(this)} />
          ) || (
            <PaperSheetView
              value={this.state.combined_text}
              stamps={stamps}
              backgroundColor={backgroundColor}
              textColor={textColor} />
          )}
        </Flex.Item>
      </Flex>
    );
  }
}


export const PaperSheet = (props, context) => {
  const { data } = useBackend(context);
  const {
    edit_mode,
    text,
    paper_color = "white",
    pen_color = "black",
    pen_font = "Verdana",
    stamps,
    stamp_class,
    stamped,
  } = data;
  const background_style = {
    'background-color': paper_color && paper_color !== "white"
      ? paper_color
      : "#FFFFFF",
  };
  const stamp_list = !stamps || stamps === null
    ? []
    : stamps;

  const decide_mode = mode => {
    switch (mode) {
      case 0:
        return (<PaperSheetView fillPositionedParent={1}
          value={text} stamps={stamp_list} />);
      case 1:
        return (<PaperSheetEdit value={text}
          backgroundColor={paper_color}
          textColor={pen_color}
          textFont={pen_font}
          stamps={stamp_list}
        />);
      case 2:
        return (<PaperSheetStamper value={text}
          stamps={stamp_list} stamp_class={stamp_class}
          fillPositionedParent={1} />);
      default:
        return "ERROR ERROR WE CANNOT BE HERE!!";
    }
  };

  return (
    <Window resizable theme="paper" style={background_style}>
      <Window.Content min-height="100vh" min-width="100vw">
        <Box min-height="100vh" min-width="100vw">
          {decide_mode(edit_mode)}
        </Box>
      </Window.Content>
    </Window>
  );
};

/**
 * @file
 * @copyright 2020 WarlockD (https://github.com/warlockd)
 * @author Original WarlockD (https://github.com/warlockd)
 * @author Changes stylemistake
 * @license MIT
 */
import { Component, createRef } from 'inferno';
import { Tabs, Box, Flex, Button, TextArea, Input } from '../components';
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
const MAX_PAPER_LENGTH = 5000; // Question, should we send this with ui_data?

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
/*



*/
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
      'th', 'ul', 'ol', 'menu', 'font', 'b',
      'center', 'input',
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
const getCssProp = (element, property) => {
  return window.getComputedStyle(element, null).getPropertyValue(property);
};

// Hacky, yes, works?...yes
const textWidth = (text, font, fontsize) => {
  // default font height is 12 in tgui
  font = fontsize + "x " + font;
  const c = document.createElement('canvas');
  const ctx = c.getContext("2d");
  ctx.font = font;
  const width = ctx.measureText(text).width;
  return width;
};


const setFontinText = (text, font, color, bold=false) => {
  if (bold) {
    return "<font face=\"" + font
    + "\" color=\"" + color
    + "\"><b>" + text + "</b></font>";
  } else {
    return "<font face=\"" + font
      + "\" color=\"" + color
      + "\">" + text + "</font>";
  }
};

const paperfield_id_headder = "paperfield_";
const createIDHeader = index => {
  return "paperfield_" + index;
};
// To make a field you do a [_______] or however long the field is
// we will then output a TEXT input for it that hopefuly covers
// the exact amount of spaces
const field_regex = /\[([_]+)\]/g;
const field_tag_regex = /\[<\s*input\s*class='paper-field'(.*?)maxlength=(?<maxlength>\d+)(.*?)id='(?<id>paperfield_\d+)'(.*?)\/>\]/gm;


const field_id_regex = /id\s*=\s*'(paperfield_\d+)'/g;
const field_maxlength_regex = /maxlength\s*=\s*(\d+)/g;

const createFields = (txt, font, fontsize, color, counter) => {
  const ret_text = txt.replace(field_regex, (match, p1, offset, string) => {
    const pixel_width = textWidth(p1, font, fontsize);
    const id = createIDHeader(counter++);
    return "[<input class='paper-field' "
        + " style='font:" + fontsize + " x" + font + "; color:" + color
        + "' maxlength=" + p1.length
        + " id='" + id + "'/>]";
  });
  return [counter, ret_text];
};
/*
** This gets the field, and finds the dom object and sees if
** the user has typed something in.  If so, it replaces,
** the dom object, in txt with the value, spaces so it
** fits the [] format and saves the value into a object
** There may be ways to optimize this in javascript but
** doing this in byond is nightmarish.
**
** It returns any values that were saved and a corrected
** html code or null if nothing was updated
*/
const getAllFields = txt => {
  let matches;
  let values = {};
  let replace = [];
  logger.log("getAllFields start");
  while ((matches = field_tag_regex.exec(txt)) !== null) {
    const full_match = matches[0];
    const maxlength = matches.groups.maxlength;
    const id = matches.groups.id;
    if (id && maxlength) {
      const dom = document.getElementById(id);
      // make sure we got data, and kill any html that might
      // be in it
      const dom_text = dom && dom.value ? dom.value : "";
      if (dom_text.length === 0) { continue; }
      const sanitized_text
        = DOMPurify.sanitize(dom.value.trim(), { ALLOWED_TAGS: [] });
      values[id] = sanitized_text; // save the data

      replace.push({ value: sanitized_text,
        field_length: maxlength, raw_text: full_match });

    }
  }
  logger.log("please work length=" + replace.length);
  // Not alot of easy ways to solve this because the index positions change
  // so replace it is!
  for (const o of replace) {
    const ntxt = "[" + o.value
      + " ".repeat(o.field_length - o.value.length) + "]";
    txt = txt.replace(o.raw_text, ntxt);
  }

  return replace.length > 0 ? [txt, values] : null;
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
      const {
        fontFamily,
        stamps,
      } = this.props;

      const fixed_text = run_marked_default(nextProps.value);

      const new_state = { marked: { __html: fixed_text },
        raw_text: nextProps.value };
      this.setState(() => new_state);
    }
    return true;
  }
  render() {
    const {
      value,
      stamps,
      backgroundColor,
      ...rest
    } = this.props;
    const stamp_list = this.state.stamps;
    return (
      <Box position="relative"
        backgroundColor={backgroundColor} width="100%" height="100%">
        <Box fillPositionedParent={1} width="100%" height="100%"
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
    logger.log("wheel thing " + rotate_amount);
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
      <Box onClick={this.handleMouseClick.bind(this)}
        onMouseMove={this.handleMouseMove.bind(this)}
        onwheel={this.handleWheel.bind(this)} {...rest}>
        <PaperSheetView
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
      previewSelected: "Preview",
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
    return false; // otherwise don't
  }
  // sets up combined text from state to make the preview to be as close
  // to what it will look like.  Its all fixed once its submited
  createPreview(value) {
    const { data } = useBackend(this.context);
    const {
      text,
      pen_color,
      pen_font,
      is_crayon,
    } = data;
    const sanatized_text = sanatize_text(value + "\n \n");
    const combined_text = text
      + setFontinText(sanatized_text, pen_font, pen_color, is_crayon);
    return combined_text;
  }
  onInputHandler(e, value) {
    if (value !== this.state.textarea_text) {
      const combined_length = this.state.old_text.length
        + this.state.textarea_text.length;
      if (combined_length > MAX_PAPER_LENGTH) {
        if ((combined_length - MAX_PAPER_LENGTH) >= value.length) {
          value = ''; // basicly we cannot add any more text to the paper
        } else {
          value = value.substr(0, value.length
            - (combined_length - MAX_PAPER_LENGTH));
        }
        // we check again to save an update
        if (value === this.state.textarea_text) { return; }// do nooothing
      }
      this.setState(() => {
        return { textarea_text: value,
          combined_text: this.createPreview(value) }; });
    }
  }
  // the final update send to byond, final upkeep
  finalUpdate(new_text) {
    const { act, data } = useBackend(this.context);
    const {
      text,
      pen_color,
      pen_font,
      is_crayon,
      field_counter,
    } = data;

    if (new_text && new_text.length > 0) {
      const sanatized_text = sanatize_text(new_text + "\n \n");
      const fielded_text = createFields(sanatized_text,
        pen_font, 12, pen_color, field_counter);
      const new_counter = fielded_text[0];

      const combined_text = text + setFontinText(fielded_text[1],
        pen_font, pen_color, is_crayon);

      const final_processing = getAllFields(combined_text);
      if (final_processing) {
        logger.log("final_processing   " + final_processing[0]);
        act('save', {
          text: final_processing[0],
          form_fields: final_processing[1],
          field_counter: new_counter,
        });
      } else {
        logger.log("!final_processing   " + combined_text);
        act('save', {
          text: combined_text,
          field_counter: new_counter,
        });
      }
    } else { // User just hit save so mabye he did something to the form
      const final_processing = getAllFields(text);
      if (final_processing) {
        act('save', {
          text: final_processing[0],
          form_fields: final_processing[1],
        });
      } else {
        act('save', { text: "" });
      }
    }
  }

  render() {
    const {
      value="",
      textColor,
      fontFamily,
      stamps,
      backgroundColor,
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
              onClick={() => this.setState({
                previewSelected: "Preview",
                combined_text: this.createPreview(value),
              })}>
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
                  this.finalUpdate(this.state.textarea_text);
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
              textColor={textColor}
              fontFamily={fontFamily}
              height={(window.innerHeight - 80) + "px"}
              backgroundColor={backgroundColor}
              onInput={this.onInputHandler.bind(this)} />

          ) || (
            <PaperSheetView
              value={this.state.combined_text}
              stamps={stamps}
              fontFamily={fontFamily}
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
    paper_color,
    pen_color = "black",
    pen_font = "Verdana",
    stamps,
    stamp_class,
    stamped,
  } = data;
  // You might ask why?  Because Window/window content do wierd
  // css stuff with white for some reason
  const backgroundColor = paper_color && paper_color !== "white"
    ? paper_color
    : "#FFFFFF";
  const background_style = {
    'background-color': backgroundColor,
  };
  const stamp_list = !stamps || stamps === null
    ? []
    : stamps;

  const decide_mode = mode => {
    switch (mode) {
      case 0: // min-height="100vh" min-width="100vw"
        return (<PaperSheetView
          value={text}
          stamps={stamp_list} m={5} />);
      case 1:
        return (<PaperSheetEdit value={text}
          textColor={pen_color}
          fontFamily={pen_font}
          stamps={stamp_list}
          backgroundColor={backgroundColor}
          m={5}
        />);
      case 2:
        return (<PaperSheetStamper value={text}
          stamps={stamp_list}
          stamp_class={stamp_class}
          m={5} />);
      default:
        return "ERROR ERROR WE CANNOT BE HERE!!";
    }
  };

  return (
    <Window resizable theme="paper" style={background_style}>
      <Window.Content min-height="100vh" min-width="100vw"
        style={background_style}>
        <Box fillPositionedParent={1} min-height="100vh"
          min-width="100vw" backgroundColor={backgroundColor}>
          {decide_mode(edit_mode)}
        </Box>
      </Window.Content>
    </Window>
  );
};

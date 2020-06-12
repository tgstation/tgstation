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
  return DOMPurify.sanitize(value,
    { ALLOWED_TAGS:
        ['br', 'code', 'li', 'p', 'pre',
          'span', 'table', 'td', 'tr',
          'th', 'ul', 'ol', 'menu', 'font', 'b', 'center'] }
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

const pauseEvent = e => {
  if (e.stopPropagation) e.stopPropagation();
  if (e.preventDefault) e.preventDefault();
  e.cancelBubble=true;
  e.returnValue=false;
  return false;
};
const copyPositioning = (target, event) => {
  target.pageX = event.pageX;
  target.pageY = event.pageY;
  target.clientX = event.clientX;
  target.clientY = event.clientY;
};

const mapPointerEvent = event => {
  const result = {};
  result.isTouchEvent = !!event.touches;
  if (result.isTouchEvent) {
    copyPositioning(result, event.touches[0]);
  } else {
    copyPositioning(result, event);
  }
  result.target = event.target;
  result.original = event;
  return result;
};

export const dragHelper = (options, event) => {
  const onStart = typeof options.onStart === 'function' && options.onStart;
  const onMove = typeof options.onMove === 'function' && options.onMove;
  const onEnd = typeof options.onEnd === 'function' && options.onEnd;

  const onDragStart = event => {
    if (event.currentTarget !== event.target) return;
    if (event.button !== 0) return;

    event.preventDefault();

    const mappedEvent = mapPointerEvent(event);
    const init = onStart && onStart(mappedEvent);
    const eventNames = mappedEvent.isTouchEvent
      ? ['touchmove', 'touchend']
      : ['mousemove', 'mouseup'];

    if (!mappedEvent.isTouchEvent) event.preventDefault();

    if (options.moveOnStart) {
      onDragMove(event);
    }

    const onDragMove = event => {
      event.preventDefault();

      if (onMove) {
        const mappedEvent = mapPointerEvent(event);
        onMove(init, mappedEvent);
      }
    };

    const onDragEnd = event => {
      if (onEnd) {
        onEnd(event);
      }

      document.removeEventListener(eventNames[0], onDragMove, {
        capture: true,
        passive: false,
      });
      document.removeEventListener(eventNames[1], onDragEnd);
    };

    document.addEventListener(eventNames[0], onDragMove, {
      capture: true,
      passive: false,
    });
    document.addEventListener(eventNames[1], onDragEnd);
  };

  return event
    ? onDragStart(event)
    : onDragStart;
};

const Stamp = (props, context) => {
  const {
    image,
    opacity,
    ...rest
  } = props;

  const matrix_trasform = 'rotate(' + image.rotate + 'deg) translate(' + image.x + 'px,' + image.y + 'px)';
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
      stamps,
      ...rest
    } = this.props;
    const stamp_list = stamps || [];
    return (
      <Box position="relative" {...rest} >
        <Box position="absoulte" {...rest} top={0} left={0}
          dangerouslySetInnerHTML={this.state.marked} />
                  {stamp_list.map(o => (
            <Stamp image={{ sprite: o[0], x: o[1], y: o[2], rotate: o[3]}} />
        ))}
        <Stamp image={{ sprite: "stamp-clown", rotate: 45, x: 40, y: 30 }} />
      </Box>
    );
  }
}
// again, need the states for dragging and such
class PaperSheetStamper extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      dragging: false,
      x: 0,
      y: 0,
      rotate: 0,
      stamp_class: props.stamp_class,
      stamps: [],
    };

    this.startNodeMove = dragHelper({
      onStart: event => {
        pauseEvent(event);
        logger.log("pos: (" + event.pageX + ", " + event.pageY + ")");
        return {
          p: vecCreate(this.state.x, this.state.y),
          prev: vecCreate(event.pageX, event.pageY),
        };
      },
      onMove: (start, event) => {
        pauseEvent(event);
        const dpos = vecCreate(
          event.clientX - start.prev[0],
          event.clientY - start.prev[1]);
        // choice here, update before or after set state, lets try before
        const new_pos = vecAdd(start.p, dpos);
        logger.log("pos: (" + new_pos[0] + ", " + new_pos[1] + ")");
        this.setState({ x: new_pos[0], y: new_pos[1], dragging:true });
      },
      onEnd: event => {

      },
    });
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
    this.setState({ x: pos[0] , y: pos[1] , dragging:false });
  }

  handleMouseClick(e) {
    const position = this.findStampPosition(e);
    let sstamps = this.state.stamps || [];
    sstamps.push([this.props.stamp_class, position[0], position[1], this.state.rotate]);
    const new_stamps = { stamps: sstamps };
    logger.log("Length :" + new_stamps.stamps.length);
    this.setState(() => new_stamps);

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
    logger.log("while pos: (" + e.deltaY +  ", " + rotate_amount+ ")");
  }
  componentDidMount() {
    logger.log("mounted");
    document.addEventListener('wheel', this.handleWheel.bind(this));
   // window.addEventListener('onmousedown', this.startNodeMove.bind(this) );
   // window.addEventListener('onclick', this.handleMouseClick.bind(this) );

   // window.addEventListener('onwheel', this.handleWheel.bind(this) );
   // window.addEventListener('mousewheel', this.handleWheel.bind(this) );

// onClick={this.handleMouseClick.bind(this)}

  }
  componentWillUnmount() {

  }

  render() {
    const {
      value,
      stamp_class,
      stamps,
      ...rest
    } = this.props;
    const stamp_list = this.state.stamps;
    return (
      <Box position="absoulte" onClick={this.handleMouseClick.bind(this)} onMouseMove={this.handleMouseMove.bind(this)}  onWheel={this.handleWheel.bind(this)} {...rest}>
        {this.state.stamps.map(o => (
          <Stamp image={{ sprite: o[0], x: o[1], y: o[2], rotate: o[3]}} />
        ))}
        <PaperSheetView fillPositionedParent={1} value={value} stamps={stamps} />

        {<Stamp
          opacity={0.5}
          image={{ sprite: stamp_class, x: this.state.x, y: this.state.y, rotate: this.state.rotate }}
          style={{ 'z-order': 100 }}
          onMouseDown={this.startNodeMove.bind(this)}
          />}
      </Box>
    );
  }

};
// ugh.  So have to turn this into a full component too if I want to keep updates
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
      stamps = "",
      ...rest
    } = this.props;

    return (
      <Flex direction="column" >
        <Flex.Item>
          <Tabs>
            <Tabs.Tab
              key="marked_edit"
              textColor={'black'}
              backgroundColor={this.state.previewSelected === "Edit" ? "grey" : "white"}
              selected={this.state.previewSelected === "Edit"}
              onClick={() => this.setState({ previewSelected: "Edit" })}>
              Edit
            </Tabs.Tab>
            <Tabs.Tab
              key="marked_preview"
              textColor={'black'}
              backgroundColor={this.state.previewSelected === "Preview" ? "grey" : "white"}
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
                  act('save', { text: this.finalUpdate(this.state.textarea_text) });
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
              onInput={this.onInputHandler.bind(this)} {...rest} />
          ) || (
            <PaperSheetView
              value={this.state.combined_text+stamps}
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
    'background-color': paper_color && paper_color !== "white" ? paper_color : "#FFFFFF",
  };
  const stamp_list = !stamps || stamps === null? [] : stamps;

  //        <img src="paper_121x54.png" alt="Girl in a jacket" width="500" height="600" />
  // {stamped.length >0 && <link rel="stylesheet" href="spritesheet_paper.css" />}
  // {stamped.map((x, i) => <Stamp key={i} stamp_class={x} stamp_index={i} />)}
  const decide_mode = mode => {
    switch (mode) {
      case 0:
        return (<PaperSheetView fillPositionedParent={1}
          value={text} stamps={stamps} />);
      case 1:
        return (<PaperSheetEdit value={text}
          backgroundColor={paper_color}
          textColor={pen_color}
          textFont={pen_font}
          fillPositionedParent={1} />);
      case 2:
        return (<PaperSheetStamper value={text}
          stamps={stamps} stamp_class={stamp_class}
          fillPositionedParent={1} />);
      default:
        return "ERROR ERROR WE CANNOT BE HERE!!";
    }
  };

  return (
    <Window resizable theme="paper" style={background_style}>
      <Window.Content min-height="100vh" min-width="100vw">
        <Box ml={0 + 'px'} mt={0 + 'px'} min-height="100vh" min-width="100vw">
          {decide_mode(edit_mode)}
        </Box>
      </Window.Content>
    </Window>
  );
};

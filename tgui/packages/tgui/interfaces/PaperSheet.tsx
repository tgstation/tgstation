/**
 * @license MIT
 */

import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Flex, Section, TextArea } from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';
import { marked } from 'marked';
import { Component, createRef, RefObject } from 'inferno';
import { clamp } from 'common/math';
import { logger } from '../logging';

const Z_INDEX_PREVIEW = 0;
const Z_INDEX_TEXTAREA = 3;
const Z_INDEX_STAMP = 1;
const Z_INDEX_STAMP_PREVIEW = 2;

type PaperContext = {
  // ui_static_data
  raw_text_input?: PaperInput[];
  raw_field_input?: FieldInput[];
  raw_stamp_input?: StampInput[];
  max_length: number;
  paper_color: string;
  paper_name: string;
  default_pen_font: string;
  default_pen_color: string;

  // ui_data
  held_item_details?: WritingImplement;
};

type PaperInput = {
  raw_text: string;
  font?: string;
  color?: string;
  bold?: boolean;
};

type StampInput = {
  class: string;
  x: number;
  y: number;
  rotation: number;
};

type FieldInput = {
  field_index: number;
  field_data: PaperInput;
};

type WritingImplement = {
  interaction_mode: InteractionType;
  font?: string;
  color?: string;
  use_bold?: boolean;
  stamp_icon_state?: string;
  stamp_class?: string;
};

type PaperSheetStamperState = {
  x: number;
  y: number;
  rotation: number;
  yOffset: number;
};

type PaperSheetStamperProps = {
  scrollableRef: RefObject<HTMLDivElement>;
};

enum InteractionType {
  reading = 0,
  writing = 1,
  stamping = 2,
}

const canEdit = (heldItemDetails?: WritingImplement): boolean => {
  if (!heldItemDetails) {
    return false;
  }

  return heldItemDetails.interaction_mode === InteractionType.writing;
};

const canStamp = (heldItemDetails?: WritingImplement): boolean => {
  if (!heldItemDetails) {
    return false;
  }

  return heldItemDetails.interaction_mode === InteractionType.stamping;
};

// This creates the html from marked text as well as the form fields
const createPreview = (
  inputList: PaperInput[] | undefined,
  stampList: StampInput[] | undefined,
  currentTextInput: string | undefined,
  defaultFont: string,
  defaultColor: string,
  penFont: string | undefined,
  penColor: string | undefined,
  penBold: boolean | undefined
) => {
  let output = '';

  inputList?.forEach((value, index) => {
    let rawText = value.raw_text.trim();
    if (!rawText.length) {
      return;
    }

    const fontColor = value.color || defaultColor;
    const fontFace = value.font || defaultFont;
    const fontBold = value.bold || false;

    output += formatAndProcessRawText(rawText, fontFace, fontColor, fontBold);
  });

  if (currentTextInput?.length) {
    const fontColor = penColor || defaultColor;
    const fontFace = penFont || defaultFont;
    const fontBold = penBold || false;

    output += formatAndProcessRawText(
      currentTextInput,
      fontFace,
      fontColor,
      fontBold
    );
  }

  if (stampList?.length) {
  }

  return output;
};

const formatAndProcessRawText = (text, font, color, bold): string => {
  // First lets make sure it ends in a new line
  text += text[text.length] === '\n' ? '\n' : '\n\n';
  // Second, we sanitize the text of html
  const sanitizedText = sanitizeText(text);
  // const signed_text = signDocument(sanitized_text, color, user_name);

  // Third we replace the [__] with fields as markedjs fucks them up
  /* const fielded_text = createFields(
    signed_text,
    font,
    12,
    color,
    field_counter
  );*/

  // Fourth, parse the text using markup
  const parsedText = runMarkedDefault(sanitizedText);

  // Fifth, we wrap the created text in the pin color, and font.
  // crayon is bold (<b> tags), maybe make fountain pin italic?
  const fontedText = setFontinText(parsedText, font, color, bold);

  return fontedText;
};

const setFontinText = (text, font, color, bold = false) => {
  return (
    '<span style="' +
    'color:' +
    color +
    ';' +
    "font-family:'" +
    font +
    "';" +
    (bold ? 'font-weight: bold;' : '') +
    '">' +
    text +
    '</span>'
  );
};

const runMarkedDefault = (value) => {
  // Override function, any links and images should
  // kill any other marked tokens we don't want here
  const walkTokens = (token) => {
    switch (token.type) {
      case 'url':
      case 'autolink':
      case 'reflink':
      case 'link':
      case 'image':
        token.type = 'text';
        // Once asset system is up change to some default image
        // or rewrite for icon images
        token.href = '';
        break;
    }
  };
  return marked(value, {
    breaks: true,
    smartypants: true,
    smartLists: true,
    walkTokens,
    // Once assets are fixed might need to change this for them
    baseUrl: 'thisshouldbreakhttp',
  });
};

const pauseEvent = (e) => {
  if (e.stopPropagation) {
    e.stopPropagation();
  }
  if (e.preventDefault) {
    e.preventDefault();
  }
  e.cancelBubble = true;
  e.returnValue = false;
  return false;
};

// again, need the states for dragging and such
class PaperSheetStamper extends Component<PaperSheetStamperProps> {
  style: null;
  handleMouseMove: (this: Document, ev: MouseEvent) => any;
  handleMouseClick: (this: Document, ev: MouseEvent) => any;
  state: PaperSheetStamperState = { x: 0, y: 0, rotation: 0, yOffset: 0 };
  scrollableRef: RefObject<HTMLDivElement>;

  constructor(props, context) {
    super(props, context);

    this.style = null;
    this.scrollableRef = props.scrollableRef;

    this.handleMouseMove = (e) => {
      const pos = this.findStampPosition(e);
      if (!pos) {
        return;
      }

      pauseEvent(e);
      this.setState({
        x: pos[0],
        y: pos[1],
        rotation: pos[2],
        yOffset: pos[3],
      });
    };

    this.handleMouseClick = (e) => {
      if (e.pageY <= 30) {
        return;
      }
      const { act } = useBackend<PaperContext>(this.context);

      act('add_stamp', {
        x: this.state.x,
        y: this.state.y + this.state.yOffset,
        rotation: this.state.rotation,
      });
    };
  }

  findStampPosition(e) {
    let rotating;
    const scrollable = this.scrollableRef.current;

    if (!scrollable) {
      return;
    }

    const stampYOffset = scrollable.scrollTop || 0;

    const stamp = document.getElementById('stamp');
    if (!stamp) {
      return;
    }

    if (e.shiftKey) {
      rotating = true;
    }

    const stampHeight = stamp.clientHeight;
    const stampWidth = stamp.clientWidth;

    const currentHeight = rotating ? this.state.y : e.pageY - stampHeight;
    const currentWidth = rotating ? this.state.x : e.pageX - stampWidth / 2;

    const widthMin = 0;
    const heightMin = 0;

    const widthMax = scrollable.clientWidth - stampWidth;
    const heightMax = scrollable.clientHeight - stampHeight;

    const radians = Math.atan2(e.pageX - currentWidth, e.pageY - currentHeight);

    const rotate = rotating
      ? radians * (180 / Math.PI) * -1
      : this.state.rotation;

    const pos = [
      clamp(currentWidth, widthMin, widthMax),
      clamp(currentHeight, heightMin, heightMax),
      rotate,
      stampYOffset,
    ];

    logger.log(pos);
    return pos;
  }

  componentDidMount() {
    document.addEventListener('mousemove', this.handleMouseMove);
    document.addEventListener('click', this.handleMouseClick);
  }

  componentWillUnmount() {
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('click', this.handleMouseClick);
  }

  render() {
    const { data } = useBackend<PaperContext>(this.context);
    const { held_item_details } = data;

    if (!held_item_details?.stamp_class) {
      return;
    }

    return (
      <Stamp
        activeStamp
        opacity={0.5}
        sprite={held_item_details.stamp_class}
        x={this.state.x}
        y={this.state.y}
        rotation={this.state.rotation}
      />
    );
  }
}

export const Stamp = (props, context) => {
  const { activeStamp, sprite, x, y, rotation, opacity, yOffset = 0 } = props;
  const stamp_transform = {
    'left': x + 'px',
    'top': y + yOffset + 'px',
    'transform': 'rotate(' + rotation + 'deg)',
    'opacity': opacity || 1.0,
    'z-index': activeStamp ? Z_INDEX_STAMP_PREVIEW : Z_INDEX_STAMP,
  };

  return (
    <div
      id="stamp"
      className={classes(['Paper__Stamp', sprite])}
      style={stamp_transform}
    />
  );
};

// Overarching component that holds the primary view for papercode.
export class PrimaryView extends Component {
  // Reference that gets passed to the <Section> holding the main preview.
  // Eventually gets filled with a reference to the section's scroll bar
  // funtionality.
  scrollableRef: RefObject<HTMLDivElement>;

  // The last recorded distance the scrollbar was from the bottom.
  // Used to implement "text scrolls up instead of down" behaviour.
  lastDistanceFromBottom: number;

  // Event handler for the onscroll event. Also gets passed to the <Section>
  // holding the main preview. Updates lastDistanceFromBottom.
  onScrollHandler: (this: GlobalEventHandlers, ev: Event) => any;

  constructor(props, context) {
    super(props, context);
    this.scrollableRef = createRef();
    this.lastDistanceFromBottom = 0;

    this.onScrollHandler = (ev: Event) => {
      const scrollable = ev.currentTarget as HTMLDivElement;
      if (scrollable) {
        this.lastDistanceFromBottom =
          scrollable.scrollHeight - scrollable.scrollTop;
      }
    };
  }

  render() {
    const { data } = useBackend<PaperContext>(this.context);
    const {
      default_pen_font,
      default_pen_color,
      paper_color,
      held_item_details,
    } = data;

    const useFont = held_item_details?.font || default_pen_font;
    const useColor = held_item_details?.color || default_pen_color;
    const useBold = held_item_details?.use_bold || false;

    const [textAreaContents, setTextAreaContents] = useLocalState(
      this.context,
      'textAreaContents',
      ''
    );

    return (
      <>
        <PaperSheetStamper scrollableRef={this.scrollableRef} />
        <Flex direction="column" fillPositionedParent>
          <Flex.Item grow={3} basis={1}>
            <PreviewView
              scrollableRef={this.scrollableRef}
              handleOnScroll={this.onScrollHandler}
            />
          </Flex.Item>
          <Flex.Item shrink={1} height="150px" style={{ 'z-index': 2 }}>
            <TextArea
              value={textAreaContents}
              textColor={useColor}
              fontFamily={useFont}
              bold={useBold}
              height={'100%'}
              backgroundColor={paper_color}
              onInput={(e, value) => {
                setTextAreaContents(value);
                if (this.scrollableRef.current) {
                  let thisDistFromBottom =
                    this.scrollableRef.current.scrollHeight -
                    this.scrollableRef.current.scrollTop;
                  this.scrollableRef.current.scrollTop +=
                    thisDistFromBottom - this.lastDistanceFromBottom;
                }
              }}
            />
          </Flex.Item>
        </Flex>
      </>
    );
  }
}

export const PreviewView = (props, context) => {
  const { data } = useBackend<PaperContext>(context);
  const {
    raw_text_input,
    raw_stamp_input,
    default_pen_font,
    default_pen_color,
    held_item_details,
    paper_color,
  } = data;

  const [textAreaContents] = useLocalState(context, 'textAreaContents', '');

  const parsedAndSanitisedHTML = createPreview(
    raw_text_input,
    raw_stamp_input,
    textAreaContents,
    default_pen_font,
    default_pen_color,
    held_item_details?.font,
    held_item_details?.color,
    held_item_details?.use_bold
  );

  const textHTML = {
    __html: '<span class="paper-text">' + parsedAndSanitisedHTML + '</span>',
  };

  const { scrollableRef, handleOnScroll } = props;

  return (
    <Section
      fill
      fitted
      scrollable
      scrollableRef={scrollableRef}
      onScroll={handleOnScroll}>
      <Box
        fillPositionedParent
        position="relative"
        bottom={'100%'}
        minHeight="100%"
        backgroundColor={paper_color}
        className="Paper__Page"
        dangerouslySetInnerHTML={textHTML}
        p="10px"
      />
      <StampView />
    </Section>
  );
};

export const StampView = (props, context) => {
  const { data } = useBackend<PaperContext>(context);

  const { raw_stamp_input = [] } = data;

  const { stampYOffset } = props;

  return (
    <>
      {raw_stamp_input.map((stamp, index) => {
        return (
          <Stamp
            key={index}
            x={stamp.x}
            y={stamp.y}
            rotation={stamp.rotation}
            sprite={stamp.class}
            yOffset={stampYOffset}
          />
        );
      })}
    </>
  );
};

export const PaperSheet = (props, context) => {
  const { data } = useBackend<PaperContext>(context);
  const {
    raw_field_input,
    raw_stamp_input,
    max_length,
    paper_color,
    paper_name,
    held_item_details,
  } = data;

  return (
    <Window title={paper_name} theme="paper" width={400} height={500}>
      <Window.Content backgroundColor={paper_color}>
        <PrimaryView />
      </Window.Content>
    </Window>
  );
};

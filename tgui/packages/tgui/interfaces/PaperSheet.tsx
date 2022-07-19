/**
 * @license MIT
 */

import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Button, Box, Flex, Section, TextArea } from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';
import { marked } from 'marked';
import { Component, createRef, MouseEventHandler, RefObject } from 'inferno';
import { clamp } from 'common/math';

const Z_INDEX_STAMP = 1;
const Z_INDEX_STAMP_PREVIEW = 2;

const TEXTAREA_INPUT_HEIGHT = 200;

type PaperContext = {
  // ui_static_data
  user_name: string;
  raw_text_input?: PaperInput[];
  raw_field_input?: FieldInput[];
  raw_stamp_input?: StampInput[];
  max_length: number;
  max_input_field_length: number;
  paper_color: string;
  paper_name: string;
  default_pen_font: string;
  default_pen_color: string;
  signature_font: string;

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
  field_index: string;
  field_data: PaperInput;
  is_signature: boolean;
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

type FieldCreationReturn = {
  counter: number;
  text: string;
};

type StampPosition = {
  x: number;
  y: number;
  rotation: number;
  yOffset: number;
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

// Creates the final inline HTML for previewing or reading the paper.
const createPreview = (
  inputList: PaperInput[] | undefined,
  dmCache: string,
  setDMCache: (nextState: string) => void,
  fieldDataList: FieldInput[] | undefined,
  textAreaText: string | null,
  defaultFont: string,
  defaultColor: string,
  paperColor: string,
  heldItemDetails: WritingImplement | undefined
): string => {
  let output = '';

  const readOnly = !canEdit(heldItemDetails);

  const heldColor = heldItemDetails?.color;
  const heldFont = heldItemDetails?.font;
  const heldBold = heldItemDetails?.use_bold;

  let fieldCounter = 0;

  if (dmCache?.length) {
    // logger.log(dmCache);
    // output = dmCache;
  } else {
    inputList?.forEach((value) => {
      let rawText = value.raw_text.trim();
      if (!rawText.length) {
        return;
      }

      const fontColor = value.color || defaultColor;
      const fontFace = value.font || defaultFont;
      const fontBold = value.bold || false;

      let processingOutput = formatAndProcessRawText(
        rawText,
        fontFace,
        fontColor,
        paperColor,
        fontBold,
        fieldCounter,
        readOnly,
        fieldDataList
      );

      output += processingOutput.text;

      fieldCounter = processingOutput.counter;

      // fillAllFields(fieldDataList || [], paperColor);
    });
    setDMCache(`${output}`);
  }

  if (textAreaText?.length) {
    const fontColor = heldColor || defaultColor;
    const fontFace = heldFont || defaultFont;
    const fontBold = heldBold || false;

    output += formatAndProcessRawText(
      textAreaText,
      fontFace,
      fontColor,
      paperColor,
      fontBold,
      fieldCounter,
      true
    ).text;
  }

  return output;
};

// Builds a paper field ID from a number or string.
const createIDHeader = (index: number | string): string => {
  return 'paperfield_' + index;
};

// Extracts the paper field "counter" from a full ID.
const getHeaderID = (header: string): string => {
  return header.replace('paperfield_', '');
};

// Returns the width the text with the provided attributes would take up in px.
const textWidth = (text: string, font: string, fontsize: number): number => {
  const c = document.createElement('canvas');
  const ctx = c.getContext('2d');

  if (!ctx) {
    return -1;
  }

  ctx.font = `${fontsize}px ${font}`;
  return ctx.measureText(text).width;
};

// Regex that finds [____] fields.
const fieldRegex: RegExp = /\[((?:_+))\]/gi;
// Regex that finds <input ... id="paperfield_x">.
const fieldTagRegex: RegExp =
  /\[<input\s+(?!disabled)(.*?)\s+id="paperfield_(?<id>\d+)"(.*?)\/>\]/gm;

// Replaces all [______] fields in raw text with fully formed <input ...>
// fields replacements.
const createFields = (
  rawText: string,
  font: string,
  fontSize: number,
  color: string,
  paperColor: string,
  forceReadonlyFields: boolean,
  counter: number = 0,
  fieldDataList: FieldInput[]
): FieldCreationReturn => {
  const ret_text = rawText.replace(fieldRegex, (match, p1, offset, string) => {
    const width = textWidth(match, font, fontSize);
    const matchingData = fieldDataList.find(
      (e) => e.field_index === `${counter}`
    );
    if (matchingData) {
      return createFilledInputField(
        matchingData,
        p1.length,
        width,
        font,
        fontSize,
        color,
        paperColor,
        createIDHeader(counter++)
      );
    }
    return createInputField(
      p1.length,
      width,
      font,
      fontSize,
      color,
      createIDHeader(counter++),
      forceReadonlyFields
    );
  });

  return {
    counter: counter,
    text: ret_text,
  };
};

// Builds an <input> field from the supplied props.
const createInputField = (
  length: number,
  width: number,
  font: string,
  fontSize: number,
  color: string,
  id: string,
  readOnly: boolean
): string => {
  return `[<input ${
    readOnly ? 'disabled ' : ''
  }type="text" style="font-size:${fontSize}px; font-family: ${font};color:${color};min-width:${width}px;max-width:${width}px" id="${id}" maxlength=${length} size=${length} />]`;
};

// Builds an <input> field from the supplied props, pre-filled with a value and disabled.
const createFilledInputField = (
  field: FieldInput,
  length: number,
  width: number,
  font: string,
  fontSize: number,
  color: string,
  paperColor: string,
  id: string
): string => {
  const fieldData = field.field_data;
  const thing = document.createTextNode(fieldData.raw_text);

  let div = document.createElement('input');
  div.setAttribute('type', 'text');
  div.style.fontSize = field.is_signature ? '30px' : `${fontSize}px`;
  div.style.fontFamily = fieldData.font || font;
  div.style.fontStyle = field.is_signature ? 'italic' : 'normal';
  div.style.fontWeight = 'bold';
  div.style.color = fieldData.color || color;
  div.style.minWidth = `${width}px`;
  div.style.maxWidth = `${width}px`;
  div.style.backgroundColor = paperColor;
  div.id = id;
  div.maxLength = length;
  div.size = length;
  div.defaultValue = fieldData.raw_text;
  div.disabled = true;

  return div.outerHTML;
};

// Fully formats, sanitises and parses the provided raw text and wraps it
// as necessary.
const formatAndProcessRawText = (
  rawText: string,
  font: string,
  color: string,
  paperColor: string,
  bold: boolean,
  fieldCounter: number = 0,
  forceReadonlyFields: boolean = false,
  fieldDataList: FieldInput[] = []
): FieldCreationReturn => {
  // First lets make sure it ends in a new line
  rawText += rawText[rawText.length] === '\n' ? '\n' : '\n\n';

  // Second, we sanitize the text of html
  const sanitizedText = sanitizeText(rawText);

  // Third we replace the [__] with fields as markedjs fucks them up
  const fieldedText = createFields(
    sanitizedText,
    font,
    12,
    color,
    paperColor,
    forceReadonlyFields,
    fieldCounter,
    fieldDataList
  );

  // Fourth, parse the text using markup
  const parsedText = runMarkedDefault(fieldedText.text);

  // Fifth, we wrap the created text in the writing implement properties.
  const fontedText = setFontInText(parsedText, font, color, bold);

  return { text: fontedText, counter: fieldedText.counter };
};

// Wraps the given raw text in a font span based on the supplied props.
const setFontInText = (
  text: string,
  font: string,
  color: string,
  bold: boolean = false
): string => {
  return `<span style="color:${color};font-family:${font};${
    bold ? 'font-weight: bold;' : ''
  }">${text}</span>`;
};

// Parses the given raw text through marked for applying markdown.
const runMarkedDefault = (rawText: string): string => {
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
  return marked(rawText, {
    breaks: true,
    smartypants: true,
    smartLists: true,
    walkTokens,
    // Once assets are fixed might need to change this for them
    baseUrl: 'thisshouldbreakhttp',
  });
};

// Stops propagation of a given event.
const pauseEvent = (e: Event): boolean => {
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

// Handles the ghost stamp when attempting to stamp paper sheets.
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
        x: pos.x,
        y: pos.y,
        rotation: pos.rotation,
        yOffset: pos.yOffset,
      });
    };

    this.handleMouseClick = (e: MouseEvent): void => {
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

  findStampPosition(e: MouseEvent): StampPosition | void {
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

    const radians = Math.atan2(
      currentWidth + stampWidth / 2 - e.pageX,
      currentHeight + stampHeight / 2 - e.pageY
    );

    const rotate = rotating
      ? radians * (180 / Math.PI) * -1
      : this.state.rotation;

    return {
      x: clamp(currentWidth, widthMin, widthMax),
      y: clamp(currentHeight, heightMin, heightMax),
      rotation: rotate,
      yOffset: stampYOffset,
    };
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

// Creates a full stamp div to render the given stamp to the preview.
export const Stamp = (props, context): InfernoElement<HTMLDivElement> => {
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

// Hooks into all input fields, registering an oninput handler.
const hookAllFields = (
  rawText: string,
  onInputHandler: (this: GlobalEventHandlers, ev: Event) => void
): void => {
  let match;

  while ((match = fieldTagRegex.exec(rawText)) !== null) {
    const id = parseInt(match.groups.id, 10);

    if (!isNaN(id)) {
      const dom = document.getElementById(
        createIDHeader(id)
      ) as HTMLInputElement;

      if (!dom) {
        continue;
      }

      if (dom.disabled) {
        continue;
      }

      dom.oninput = onInputHandler;
    }
  }
};

// Goes through the list of field input data and modifies all fields to be
// filled with the appropriate data and then disables them.
const fillAllFields = (
  fieldInputData: FieldInput[],
  paperColor: string
): void => {
  if (!fieldInputData?.length) {
    return;
  }

  fieldInputData.forEach((field, i) => {
    const dom = document.getElementById(
      createIDHeader(field.field_index)
    ) as HTMLInputElement;

    if (!dom) {
      return;
    }

    const fieldData = field.field_data;

    dom.disabled = true;
    dom.value = fieldData.raw_text;
    dom.style.fontFamily = fieldData.font || '';
    dom.style.color = fieldData.color || '';
    dom.style.backgroundColor = paperColor;
    dom.style.fontSize = field.is_signature ? '30px' : '12px';
    dom.style.fontStyle = field.is_signature ? 'italic' : 'normal';
    dom.style.fontWeight = 'bold';
  });
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
  onScrollHandler: (this: MouseEventHandler, ev: Event) => any;

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
    const { act, data } = useBackend<PaperContext>(this.context);
    const {
      default_pen_font,
      default_pen_color,
      paper_color,
      held_item_details,
    } = data;

    const useFont = held_item_details?.font || default_pen_font;
    const useColor = held_item_details?.color || default_pen_color;
    const useBold = held_item_details?.use_bold || false;

    const [textAreaText, setTextAreaText] = useLocalState(
      this.context,
      'textAreaText',
      ''
    );

    const [inputFieldData, setInputFieldData] = useLocalState(
      this.context,
      'inputFieldData',
      {}
    );

    const interactMode =
      held_item_details?.interaction_mode || InteractionType.reading;

    const savableData =
      textAreaText.length || Object.keys(inputFieldData).length;

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
          {interactMode === InteractionType.writing && (
            <Flex.Item shrink={1} height={TEXTAREA_INPUT_HEIGHT + 'px'}>
              <Section
                title="Insert Text"
                fitted
                fill
                buttons={
                  <Button.Confirm
                    disabled={!savableData}
                    content="Save"
                    color="good"
                    onClick={() => {
                      if (textAreaText.length) {
                        act('add_text', { text: textAreaText });
                        setTextAreaText('');
                      }
                      if (Object.keys(inputFieldData).length) {
                        act('fill_input_field', { field_data: inputFieldData });
                        setInputFieldData({});
                      }
                    }}
                  />
                }>
                <TextArea
                  scrollbar
                  noborder
                  value={textAreaText}
                  textColor={useColor}
                  fontFamily={useFont}
                  bold={useBold}
                  height={'100%'}
                  backgroundColor={paper_color}
                  onInput={(e, text) => {
                    setTextAreaText(text);
                    if (this.scrollableRef.current) {
                      let thisDistFromBottom =
                        this.scrollableRef.current.scrollHeight -
                        this.scrollableRef.current.scrollTop;
                      this.scrollableRef.current.scrollTop +=
                        thisDistFromBottom - this.lastDistanceFromBottom;
                    }
                  }}
                />
              </Section>
            </Flex.Item>
          )}
        </Flex>
      </>
    );
  }
}

// Real-time text preview section. When not editing, this is simply the
// component that builds and renders the final HTML output.
export const PreviewView = (props, context) => {
  const { data } = useBackend<PaperContext>(context);
  const {
    raw_text_input,
    raw_field_input,
    default_pen_font,
    default_pen_color,
    paper_color,
    held_item_details,
  } = data;

  const [textAreaText] = useLocalState(context, 'textAreaText', '');
  const [inputFieldData, setInputFieldData] = useLocalState(
    context,
    'inputFieldData',
    {}
  );

  // When we parse everything from DM-side, we can definitely cache it.
  const [dmParsedAndSanitisedCache, setDmParsedAndSanitisedCache] =
    useLocalState(context, 'dmParsedAndSanitisedCache', '');

  const parsedAndSanitisedHTML = createPreview(
    raw_text_input,
    dmParsedAndSanitisedCache,
    setDmParsedAndSanitisedCache,
    raw_field_input,
    canEdit(held_item_details) ? textAreaText : null,
    default_pen_font,
    default_pen_color,
    paper_color,
    held_item_details
  );

  // When one of the <input> fields has text entered, this keeps track of it
  // and holds the state of every modified input field.
  const onInputHandler = (ev) => {
    const input = ev.currentTarget as HTMLInputElement;
    if (input.value.length) {
      inputFieldData[getHeaderID(input.id)] = input.value;
    } else {
      delete inputFieldData[getHeaderID(input.id)];
    }
    setInputFieldData(inputFieldData);
    input.style.fontFamily = held_item_details?.font || default_pen_font;
    input.style.color = held_item_details?.color || default_pen_color;
  };

  // If we can edit the page, we can write to existing input fields.
  if (canEdit(held_item_details)) {
    hookAllFields(parsedAndSanitisedHTML, onInputHandler);
  }

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

// Renders all the stamp components for every valid stamp.
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
  const { paper_color, paper_name, held_item_details } = data;

  const writeMode = canEdit(held_item_details);

  if (!writeMode) {
    const [inputFieldData, setInputFieldData] = useLocalState(
      context,
      'inputFieldData',
      {}
    );
    if (Object.keys(inputFieldData).length) {
      setInputFieldData({});
    }
  }

  return (
    <Window
      title={paper_name}
      theme="paper"
      width={420}
      height={500 + (writeMode ? TEXTAREA_INPUT_HEIGHT : 0)}>
      <Window.Content backgroundColor={paper_color}>
        <PrimaryView />
      </Window.Content>
    </Window>
  );
};

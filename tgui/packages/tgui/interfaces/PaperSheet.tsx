/**
 * @license MIT
 */

import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Section, TextArea } from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';
import { marked } from 'marked';
import { Component, createRef, RefObject } from 'inferno';
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
  nextCounter: number;
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

type PreviewViewProps = {
  scrollableRef: RefObject<HTMLDivElement>;
  handleOnScroll: (this: GlobalEventHandlers, ev: Event) => any;
  textArea: string;
};

const canEdit = (heldItemDetails?: WritingImplement): boolean => {
  if (!heldItemDetails) {
    return false;
  }

  return heldItemDetails.interaction_mode === InteractionType.writing;
};

// Regex that finds [____] fields.
const fieldRegex: RegExp = /\[((?:_+))\]/gi;

// Handles the ghost stamp when attempting to stamp paper sheets.
class PaperSheetStamper extends Component<PaperSheetStamperProps> {
  style: null;
  state: PaperSheetStamperState = { x: 0, y: 0, rotation: 0, yOffset: 0 };
  scrollableRef: RefObject<HTMLDivElement>;

  constructor(props, context) {
    super(props, context);

    this.style = null;
    this.scrollableRef = props.scrollableRef;
  }

  // Stops propagation of a given event.
  pauseEvent = (e: Event): boolean => {
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

  handleMouseMove = (e: MouseEvent): void => {
    const pos = this.findStampPosition(e);
    if (!pos) {
      return;
    }

    this.pauseEvent(e);
    this.setState({
      x: pos.x,
      y: pos.y,
      rotation: pos.rotation,
      yOffset: pos.yOffset,
    });
  };

  handleMouseClick = (e: MouseEvent): void => {
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
      currentHeight + stampHeight - e.pageY
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
    const { act, data } = useBackend<PaperContext>(this.context);
    const {
      raw_text_input,
      raw_field_input,
      default_pen_font,
      default_pen_color,
      paper_color,
      held_item_details,
      max_length,
    } = data;

    const useFont = held_item_details?.font || default_pen_font;
    const useColor = held_item_details?.color || default_pen_color;
    const useBold = held_item_details?.use_bold || false;

    const [inputFieldData, setInputFieldData] = useLocalState(
      this.context,
      'inputFieldData',
      {}
    );

    const [textAreaText, setTextAreaText] = useLocalState(
      this.context,
      'textAreaText',
      ''
    );

    const interactMode =
      held_item_details?.interaction_mode || InteractionType.reading;

    const savableData =
      textAreaText.length || Object.keys(inputFieldData).length;

    const dmCharacters =
      raw_text_input?.reduce((lhs: number, rhs: PaperInput) => {
        return lhs + rhs.raw_text.length;
      }, 0) || 0;

    const usedCharacters = dmCharacters + textAreaText.length;

    const tooManyCharacters = usedCharacters > max_length;

    return (
      <>
        <PaperSheetStamper scrollableRef={this.scrollableRef} />
        <Flex direction="column" fillPositionedParent>
          <Flex.Item grow={3} basis={1}>
            <PreviewView
              key={`${raw_field_input?.length || 0}_${
                raw_text_input?.length || 0
              }`}
              scrollableRef={this.scrollableRef}
              handleOnScroll={this.onScrollHandler}
              textArea={textAreaText}
            />
          </Flex.Item>
          {interactMode === InteractionType.writing && (
            <Flex.Item shrink={1} height={TEXTAREA_INPUT_HEIGHT + 'px'}>
              <Section
                title="Insert Text"
                fitted
                fill
                buttons={
                  <>
                    <Box
                      inline
                      pr={'5px'}
                      color={tooManyCharacters ? 'bad' : 'default'}>
                      {`${usedCharacters} / ${max_length}`}
                    </Box>
                    <Button.Confirm
                      disabled={!savableData || tooManyCharacters}
                      content="Save"
                      color="good"
                      onClick={() => {
                        if (textAreaText.length) {
                          act('add_text', { text: textAreaText });
                          setTextAreaText('');
                        }
                        if (Object.keys(inputFieldData).length) {
                          act('fill_input_field', {
                            field_data: inputFieldData,
                          });
                          setInputFieldData({});
                        }
                      }}
                    />
                  </>
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

/**
 * Real-time text preview section. When not editing, this is simply
 * the component that builds and renders the final HTML output.
 * It parses and sanitises the DM-side raw input and field input data once on
 * creation.
 * It caches writable input fields as a form of state management.
 * This component should be used with a `key` prop that changes
 * when DM-side raw input or field input data have changed.
 * We currently do this by keying the component based on the lengths of the
 * raw and field input arrays.
 */
export class PreviewView extends Component<PreviewViewProps> {
  // Array containing cache of HTMLInputElements that are enabled.
  enabledInputFieldCache: { [key: string]: HTMLInputElement } = {};

  constructor(props, context) {
    super(props, context);
  }

  // Extracts the paper field "counter" from a full ID.
  getHeaderID = (header: string): string => {
    return header.replace('paperfield_', '');
  };

  // Since we're not using Components and are instead dangerously setting
  // the inner HTML, none of the input fields persist on the document past
  // their own render. This causes a few side effects, the main one being
  // that our event handlers get lost every update. Another one being that
  // the input boxes lose their state as well.
  // We can use event bubbling to listen for events from input boxes and
  // handle them from the document level, solving problem one.
  // We can do a little state management thanks to that, allowing us to track
  // what input fields have been changed allowing other parts to run their own
  // logic.
  // Finally, we can just keep a cache of input fields as they're modified,
  // allowing us to re-use them in the input field creation process to persist
  // their state across updates.
  onInputHandler = (ev: Event): void => {
    const input = ev.target as HTMLInputElement;

    // Skip text area input.
    if (input.nodeName !== 'INPUT') {
      return;
    }

    const [inputFieldData, setInputFieldData] = useLocalState(
      this.context,
      'inputFieldData',
      {}
    );

    const { data } = useBackend<PaperContext>(this.context);
    const { default_pen_font, default_pen_color, held_item_details } = data;

    if (input.value.length) {
      inputFieldData[this.getHeaderID(input.id)] = input.value;
    } else {
      delete inputFieldData[this.getHeaderID(input.id)];
    }
    setInputFieldData(inputFieldData);
    input.style.fontFamily = held_item_details?.font || default_pen_font;
    input.style.color = held_item_details?.color || default_pen_color;
    input.defaultValue = input.value;
    this.enabledInputFieldCache[input.id] = input;
  };

  componentDidMount() {
    document.addEventListener('input', this.onInputHandler);
  }

  componentWillUnmount() {
    document.removeEventListener('input', this.onInputHandler);
  }

  // Creates the partial inline HTML for previewing or reading the paper from
  // only static_ui_data from DM.
  createPreviewFromDM = (): { text: string; newFieldCount: number } => {
    const { data } = useBackend<PaperContext>(this.context);
    const {
      raw_text_input,
      default_pen_font,
      default_pen_color,
      paper_color,
      held_item_details,
    } = data;

    let output = '';
    let fieldCount = 0;

    const readOnly = !canEdit(held_item_details);

    raw_text_input?.forEach((value) => {
      let rawText = value.raw_text.trim();
      if (!rawText.length) {
        return;
      }

      const fontColor = value.color || default_pen_color;
      const fontFace = value.font || default_pen_font;
      const fontBold = value.bold || false;

      let processingOutput = this.formatAndProcessRawText(
        rawText,
        fontFace,
        fontColor,
        paper_color,
        fontBold,
        fieldCount,
        readOnly
      );

      output += processingOutput.text;

      fieldCount = processingOutput.nextCounter;
    });

    return { text: output, newFieldCount: fieldCount };
  };

  // Creates the partial inline HTML for previewing or reading the paper from
  // the text input area.
  createPreviewFromTextArea = (fieldCount: number = 0): string => {
    const { data } = useBackend<PaperContext>(this.context);
    const {
      default_pen_font,
      default_pen_color,
      paper_color,
      held_item_details,
    } = data;
    const { textArea } = this.props;

    const readOnly = true;

    const fontColor = held_item_details?.color || default_pen_color;
    const fontFace = held_item_details?.font || default_pen_font;
    const fontBold = held_item_details?.use_bold || false;

    let processingOutput = this.formatAndProcessRawText(
      textArea,
      fontFace,
      fontColor,
      paper_color,
      fontBold,
      fieldCount,
      readOnly
    );

    return processingOutput.text;
  };

  // Wraps the given raw text in a font span based on the supplied props.
  setFontInText = (
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
  runMarkedDefault = (rawText: string): string => {
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

  // Fully formats, sanitises and parses the provided raw text and wraps it
  // as necessary.
  formatAndProcessRawText = (
    rawText: string,
    font: string,
    color: string,
    paperColor: string,
    bold: boolean,
    fieldCounter: number = 0,
    forceReadonlyFields: boolean = false
  ): FieldCreationReturn => {
    // First lets make sure it ends in a new line
    rawText += rawText[rawText.length] === '\n' ? '\n' : '\n\n';

    // Second, we sanitize the text of html
    const sanitizedText = sanitizeText(rawText);

    // Third we replace the [__] with fields as markedjs fucks them up
    const fieldedText = this.createFields(
      sanitizedText,
      font,
      12,
      color,
      paperColor,
      forceReadonlyFields,
      fieldCounter
    );

    // Fourth, parse the text using markup
    const parsedText = this.runMarkedDefault(fieldedText.text);

    // Fifth, we wrap the created text in the writing implement properties.
    const fontedText = this.setFontInText(parsedText, font, color, bold);

    return { text: fontedText, nextCounter: fieldedText.nextCounter };
  };

  // Builds a paper field ID from a number or string.
  createIDHeader = (index: number | string): string => {
    return 'paperfield_' + index;
  };

  // Returns the width the text with the provided attributes would take up in px.
  textWidth = (text: string, font: string, fontsize: number): number => {
    const c = document.createElement('canvas');
    const ctx = c.getContext('2d');

    if (!ctx) {
      return -1;
    }

    ctx.font = `${fontsize}px ${font}`;
    return ctx.measureText(text).width;
  };

  // Replaces all [______] fields in raw text with fully formed <input ...>
  // field replacements.
  createFields = (
    rawText: string,
    font: string,
    fontSize: number,
    color: string,
    paperColor: string,
    forceReadonlyFields: boolean,
    counter: number = 0
  ): FieldCreationReturn => {
    const { data } = useBackend<PaperContext>(this.context);
    const { raw_field_input } = data;

    const ret_text = rawText.replace(
      fieldRegex,
      (match, p1, offset, string) => {
        const width = this.textWidth(match, font, fontSize);
        const matchingData = raw_field_input?.find(
          (e) => e.field_index === `${counter}`
        );
        if (matchingData) {
          return this.createFilledInputField(
            matchingData,
            p1.length,
            width,
            font,
            fontSize,
            color,
            paperColor,
            this.createIDHeader(counter++)
          );
        }
        return this.createInputField(
          p1.length,
          width,
          font,
          fontSize,
          color,
          this.createIDHeader(counter++),
          forceReadonlyFields
        );
      }
    );

    return {
      nextCounter: counter,
      text: ret_text,
    };
  };

  // Builds an <input> field from the supplied props.
  createInputField = (
    length: number,
    width: number,
    font: string,
    fontSize: number,
    color: string,
    id: string,
    readOnly: boolean
  ): string => {
    // This are fields that may potentially be fillable, so we'll use the
    // currently held item's stats for them if possible.
    const { data } = useBackend<PaperContext>(this.context);
    const { held_item_details, max_input_field_length } = data;

    const fontColor = held_item_details?.color || color;
    const fontFace = held_item_details?.font || font;

    // Do we have this ID in our cache?
    let input = this.enabledInputFieldCache[id];

    if (input) {
      // If we've gone to readOnly now, drop the cache because we're no longer
      // in write mode. Will reset the input field the next time it's writable.
      if (readOnly) {
        delete this.enabledInputFieldCache[id];
      }
      // If we do, recycle it, updating font and color incase we've changed
      // writing implements.
      input.style.fontFamily = fontFace;
      input.style.color = fontColor;
      return `[${input.outerHTML}]`;
    }

    // If we don't, make a new one.
    input = document.createElement('input');
    input.id = id;
    input.setAttribute('type', 'text');
    input.style.fontSize = `${fontSize}px`;
    input.style.fontFamily = fontFace;
    input.style.color = fontColor;
    input.style.minWidth = `${width}px`;
    input.style.maxWidth = `${width}px`;

    input.maxLength = Math.min(max_input_field_length, length);
    input.size = length;
    input.disabled = readOnly;

    if (!readOnly) {
      this.enabledInputFieldCache[id] = input;
    }

    return `[${input.outerHTML}]`;
  };

  // Builds an <input> field from the supplied props, pre-filled with a value
  // and disabled.
  // We never need to track these because they are always disabled, so we're
  // just using it as a convenient way to build the HTML output.
  createFilledInputField = (
    field: FieldInput,
    length: number,
    width: number,
    font: string,
    fontSize: number,
    color: string,
    paperColor: string,
    id: string
  ): string => {
    const { data } = useBackend<PaperContext>(this.context);
    const { max_input_field_length } = data;

    const fieldData = field.field_data;

    let input = document.createElement('input');
    input.setAttribute('type', 'text');

    input.style.fontSize = field.is_signature ? '30px' : `${fontSize}px`;
    input.style.fontFamily = fieldData.font || font;
    input.style.fontStyle = field.is_signature ? 'italic' : 'normal';
    input.style.fontWeight = 'bold';
    input.style.color = fieldData.color || color;
    input.style.minWidth = `${width}px`;
    input.style.maxWidth = `${width}px`;
    input.style.backgroundColor = paperColor;
    input.id = id;
    input.maxLength = Math.min(max_input_field_length, length);
    input.size = length;
    input.defaultValue = fieldData.raw_text;
    input.disabled = true;

    return `[${input.outerHTML}]`;
  };

  render() {
    const { data } = useBackend<PaperContext>(this.context);
    const { paper_color, held_item_details } = data;
    const interactMode =
      held_item_details?.interaction_mode || InteractionType.reading;

    const dmTextPreviewData = this.createPreviewFromDM();
    let previewText = dmTextPreviewData.text;

    if (interactMode === InteractionType.writing) {
      previewText += this.createPreviewFromTextArea(
        dmTextPreviewData.newFieldCount
      );
    }

    const textHTML = {
      __html: `<span class='paper-text'>${previewText}</span>`,
    };

    const { scrollableRef, handleOnScroll } = this.props;

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
  }
}

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

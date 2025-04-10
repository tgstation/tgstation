import { marked } from 'marked';
import { Component, RefObject } from 'react';
import { Box, Section } from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import { sanitizeText } from '../../sanitize';
import { canEdit, tokenizer, walkTokens } from './helpers';
import { StampView } from './StampView';
import { FieldInput, InteractionType, PaperContext } from './types';

type PreviewViewProps = {
  scrollableRef: RefObject<HTMLDivElement | null>;
  handleOnScroll: (this: GlobalEventHandlers, ev: Event) => any;
  textArea: string;
};

type FieldCreationReturn = {
  nextCounter: number;
  text: string;
};

// Regex that finds [____] fields.
const fieldRegex: RegExp = /\[((?:_+))\]/gi;

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
  enabledInputFieldCache: Record<string, HTMLInputElement> = {};

  // State checking variables. Used to determine whether or not to use cache.
  lastReadOnly: boolean = true;
  lastDMInputCount: number = 0;
  lastFieldCount: number = 0;
  lastFieldInputCount: number = 0;

  // Cache variables for fully parsed text. Workaround for marked.js not being
  // super fast on the BYOND/IE js engine.
  parsedDMCache: string = '';
  parsedTextBoxCache: string = '';

  constructor(props) {
    super(props);
    this.configureMarked();
  }

  configureMarked = (): void => {
    // This is an extension for marked defining a complete custom tokenizer.
    // This tokenizer should run before the the non-custom ones, and gives us
    // the ability to handle [_____] fields before the em/strong tokenizers
    // mangle them, since underscores are used for italic/bold.
    // This massively improves the order of operations, allowing us to run
    // marked, THEN sanitise the output (much safer) and finally insert fields
    // manually afterwards.
    const inputField = {
      name: 'inputField',
      level: 'inline',

      start(src) {
        return src.match(/\[/)?.index;
      },

      tokenizer,

      renderer(token) {
        return `${token.raw}`;
      },

      walkTokens,
    };

    marked.use({
      extensions: [inputField],
      breaks: true,
      gfm: true,
      smartypants: true,
      walkTokens: walkTokens,
      // Once assets are fixed might need to change this for them
      baseUrl: 'thisshouldbreakhttp',
    });
  };

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

    // We don't care about text area input, but this is a good place to
    // clear the text box cache if we've had new input.
    if (input.nodeName !== 'INPUT') {
      this.parsedTextBoxCache = '';
      return;
    }

    const [inputFieldData, setInputFieldData] = useLocalState(
      'inputFieldData',
      {},
    );

    const { data } = useBackend<PaperContext>();
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
    const { data } = useBackend<PaperContext>();
    const {
      raw_field_input,
      raw_text_input,
      default_pen_font,
      default_pen_color,
      paper_color,
      held_item_details,
    } = data;

    let output = '';
    let fieldCount = 0;

    const readOnly = !canEdit(held_item_details);

    // If readonly is the same (input field writiability state hasn't changed)
    // And the input stats are the same (no new text inputs since last time)
    // Then use any cached values.
    if (
      this.lastReadOnly === readOnly &&
      this.lastDMInputCount === raw_text_input?.length &&
      this.lastFieldInputCount === raw_field_input?.length
    ) {
      return { text: this.parsedDMCache, newFieldCount: this.lastFieldCount };
    }

    this.lastReadOnly = readOnly;

    raw_text_input?.forEach((value) => {
      let rawText = value.raw_text.trim();
      if (!rawText.length) {
        return;
      }

      const fontColor = value.color || default_pen_color;
      const fontFace = value.font || default_pen_font;
      const fontBold = value.bold || false;
      const advancedHtml = value.advanced_html || false;

      let processingOutput = this.formatAndProcessRawText(
        rawText,
        fontFace,
        fontColor,
        paper_color,
        fontBold,
        fieldCount,
        readOnly,
        advancedHtml,
      );

      output += processingOutput.text;

      fieldCount = processingOutput.nextCounter;
    });

    this.lastDMInputCount = raw_text_input?.length || 0;
    this.lastFieldInputCount = raw_field_input?.length || 0;
    this.lastFieldCount = fieldCount;
    this.parsedDMCache = output;

    return { text: output, newFieldCount: fieldCount };
  };

  // Creates the partial inline HTML for previewing or reading the paper from
  // the text input area.
  createPreviewFromTextArea = (fieldCount: number = 0): string => {
    const { data } = useBackend<PaperContext>();
    const {
      default_pen_font,
      default_pen_color,
      paper_color,
      held_item_details,
    } = data;
    const { textArea } = this.props;

    // Use the cache if one exists.
    if (this.parsedTextBoxCache) {
      return this.parsedTextBoxCache;
    }

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
      readOnly,
    );

    this.parsedTextBoxCache = processingOutput.text;

    return processingOutput.text;
  };

  // Wraps the given raw text in a font span based on the supplied props.
  setFontInText = (
    text: string,
    font: string,
    color: string,
    bold: boolean = false,
  ): string => {
    return `<span style="color:${color};font-family:${font};${
      bold ? 'font-weight: bold;' : ''
    }">${text}</span>`;
  };

  // Parses the given raw text through marked for applying markdown.
  runMarkedDefault = (rawText: string): string => {
    // Override function, any links and images should
    // kill any other marked tokens we don't want here
    walkTokens;

    // This is an extension for marked defining a complete custom tokenizer.
    // This tokenizer should run before the the non-custom ones, and gives us
    // the ability to handle [_____] fields before the em/strong tokenizers
    // mangle them, since underscores are used for italic/bold.
    // This massively improves the order of operations, allowing us to run
    // marked, THEN sanitise the output (much safer) and finally insert fields
    // manually afterwards.
    const inputField = {
      name: 'inputField',
      level: 'inline',

      start(src) {
        return src.match(/\[/)?.index;
      },

      tokenizer,

      renderer(token) {
        return `${token.raw}`;
      },
    };

    return marked.parse(rawText);
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
    forceReadonlyFields: boolean = false,
    advanced_html: boolean = false,
  ): FieldCreationReturn => {
    // First lets make sure it ends in a new line
    const { data } = useBackend<PaperContext>();
    rawText += rawText[rawText.length] === '\n' ? '\n' : '\n\n';

    // Second, parse the text using markup
    const parsedText = this.runMarkedDefault(rawText);

    // Third, we sanitize the text of html
    const sanitizedText = sanitizeText(parsedText, advanced_html);

    // Fourth we replace the [__] with fields
    const fieldedText = this.createFields(
      sanitizedText,
      font,
      12,
      color,
      paperColor,
      forceReadonlyFields,
      fieldCounter,
    );

    // Fifth, we wrap the created text in the writing implement properties.
    const fontedText = this.setFontInText(fieldedText.text, font, color, bold);

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
    counter: number = 0,
  ): FieldCreationReturn => {
    const { data } = useBackend<PaperContext>();
    const { raw_field_input } = data;

    const ret_text = rawText.replace(
      fieldRegex,
      (match, p1, offset, string) => {
        const width = this.textWidth(match, font, fontSize);
        const matchingData = raw_field_input?.find(
          (e) => e.field_index === `${counter}`,
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
            this.createIDHeader(counter++),
          );
        }
        return this.createInputField(
          p1.length,
          width,
          font,
          fontSize,
          color,
          this.createIDHeader(counter++),
          forceReadonlyFields,
        );
      },
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
    readOnly: boolean,
  ): string => {
    // This are fields that may potentially be fillable, so we'll use the
    // currently held item's stats for them if possible.
    const { data } = useBackend<PaperContext>();
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
    id: string,
  ): string => {
    const { data } = useBackend<PaperContext>();
    const { max_input_field_length } = data;

    const fieldData = field.field_data;

    let input = document.createElement('input');
    input.setAttribute('type', 'text');

    input.style.fontSize = field.is_signature ? '15px' : `${fontSize}px`;
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
    const { data } = useBackend<PaperContext>();
    const { paper_color, held_item_details } = data;
    const interactMode =
      held_item_details?.interaction_mode || InteractionType.reading;

    const dmTextPreviewData = this.createPreviewFromDM();
    let previewText = dmTextPreviewData.text;

    if (interactMode === InteractionType.writing) {
      previewText += this.createPreviewFromTextArea(
        dmTextPreviewData.newFieldCount,
      );
    }

    const textHTML = {
      __html: `<span className='paper-text'>${previewText}</span>`,
    };

    const { scrollableRef, handleOnScroll } = this.props;

    return (
      <Section
        fill
        fitted
        scrollable
        ref={scrollableRef}
        onScroll={handleOnScroll as any}
      >
        <Box
          fillPositionedParent
          position="relative"
          bottom="100%"
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

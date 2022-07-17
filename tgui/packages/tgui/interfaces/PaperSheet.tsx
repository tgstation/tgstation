/**
 * @license MIT
 */

 import { useBackend, useLocalState } from '../backend';
 import { Box, Flex, Tabs, TextArea } from '../components';
 import { Window } from '../layouts';
 import { sanitizeText } from '../sanitize';
 import { marked } from 'marked';

type PaperContext = {
  // ui_static_data
  raw_text_input?: PaperInput[],
  raw_field_input?: FieldInput[],
  raw_stamp_input?: StampInput[],
  max_length: number,
  paper_color: string,
  paper_name: string,
  default_pen_font: string,
  default_pen_color: string,

  // ui_data
  held_item_details?: WritingImplement,
}

type PaperInput = {
  raw_text: string,
  font?: string,
  color?: string,
  bold?: boolean,
}

type StampInput = {
  class: string,
  stamp_x: number,
  stamp_y: number,
  rotation: number,
}

type FieldInput = {
  field_index: number,
  field_data: PaperInput,
}

type WritingImplement = {
  interaction_mode: InteractionType,
	font?: string,
	color?: string,
	use_bold?: boolean,
  stamp_icon_state?: string,
  stamp_class?: string,
}

enum InteractionType {
  reading = 0,
  writing = 1,
  stamping = 2,
}

enum Mode {
  edit,
  preview,
  stamp,
}

enum SaveTabState {
  normal,
  confirmSave,
}

const canEdit = (heldItemDetails?: WritingImplement): boolean => {
  if(!heldItemDetails) {
    return false;
  }

  return heldItemDetails.interaction_mode === InteractionType.writing;
};

const canStamp = (heldItemDetails?: WritingImplement): boolean => {
  if(!heldItemDetails) {
    return false;
  }

  return heldItemDetails.interaction_mode === InteractionType.stamping;
};

// This creates the html from marked text as well as the form fields
const createPreview = (
  inputList: PaperInput[] | undefined,
  currentTextInput: string | undefined,
  defaultFont: string,
  defaultColor: string,
  penFont: string | undefined,
  penColor: string | undefined,
  penBold: boolean | undefined,
) => {
  let output = "";

  inputList?.forEach((value, index) => {
    let rawText = value.raw_text.trim();
    if(!rawText.length) {
      return;
    }

    const fontColor = value.color || defaultColor;
    const fontFace = value.font || defaultFont;
    const fontBold = value.bold || false;

    output += formatAndProcessRawText(
      rawText,
      fontFace,
      fontColor,
      fontBold);
  });

  if(currentTextInput?.length) {
    const fontColor = penColor || defaultColor;
    const fontFace = penFont || defaultFont;
    const fontBold = penBold || false;

    output += formatAndProcessRawText(
      currentTextInput,
      fontFace,
      fontColor,
      fontBold);
  }
  return output;
};

const formatAndProcessRawText = (text, font, color, bold): string => {
  // First lets make sure it ends in a new line
  text += text[text.length] === "\n" ? "\n" : "\n\n";
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

export const TabView = (props, context) => {
  const { act, data } = useBackend<PaperContext>(context);
  const {
    default_pen_font,
    default_pen_color,
    paper_color,
    held_item_details,
  } = data;

  const useFont = held_item_details?.font || default_pen_font;
  const useColor = held_item_details?.color || default_pen_color;
  const useBold = held_item_details?.use_bold || false;

  const [currentTab, setCurrentTab] = useLocalState(
    context,
    'tabView',
    Mode.edit,
  );

  const [saveTabState, setSaveTabState] = useLocalState(
    context,
    'saveTabState',
    SaveTabState.normal,
  );

  const [textAreaContents, setTextAreaContents] = useLocalState(
    context,
    'textAreaContents',
    "",
  );


  return (
    <Flex direction="column" fillPositionedParent>
        <Flex.Item>
          <Tabs>
            <Tabs.Tab
              textColor={'black'}
              backgroundColor={
                (currentTab === Mode.edit) ? 'grey' : 'white'
              }
              selected={currentTab === Mode.edit}
              onClick={() => setCurrentTab(Mode.edit)}>
              Edit
            </Tabs.Tab>
            <Tabs.Tab
              textColor={'black'}
              backgroundColor={
                (currentTab === Mode.preview) ? 'grey' : 'white'
              }
              selected={currentTab === Mode.edit}
              onClick={() => setCurrentTab(Mode.preview)}>
              Preview
            </Tabs.Tab>
            <Tabs.Tab
              textColor={'black'}
              backgroundColor={
                ((saveTabState === SaveTabState.confirmSave) && "red")
                || "white"
              }
              selected={(saveTabState === SaveTabState.confirmSave)}
              onClick={() => {
                if ((saveTabState === SaveTabState.normal)) {
                  setSaveTabState(SaveTabState.confirmSave);
                }
                else {
                  act("add_text", { text: textAreaContents });
                  setSaveTabState(SaveTabState.normal);
                  setTextAreaContents("");
                }
              }}>
              {(saveTabState === SaveTabState.confirmSave) ? 'Confirm' : 'Save'}
            </Tabs.Tab>
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1} basis={1}>
          {(currentTab === Mode.edit && (
            <>
              <PreviewView />
              <TextArea
                value={textAreaContents}
                textColor={useColor}
                fontFamily={useFont}
                bold={useBold}
                height={"200px"}
                backgroundColor={paper_color}
                onInput={(e, value) => { setTextAreaContents(value); }}
              />
            </>
          )) || (<PreviewView />)}
        </Flex.Item>
    </Flex>
  );
};

export const PreviewView = (props, context) => {
  const { data } = useBackend<PaperContext>(context);
  const {
    raw_text_input,
    default_pen_font,
    default_pen_color,
    held_item_details,
    paper_color,
  } = data;

  const [textAreaContents] = useLocalState(
    context,
    'textAreaContents',
    "",
  );

  const parsedAndSanitisedHTML = createPreview(
    raw_text_input,
    textAreaContents,
    default_pen_font,
    default_pen_color,
    held_item_details?.font,
    held_item_details?.color,
    held_item_details?.use_bold,
  );

  const textHTML = {
    __html: "<span class=\"paper-text\">" +
      parsedAndSanitisedHTML +
      "</span>",
  };

  return (
    <Box
      position="relative"
      backgroundColor={paper_color}
      width="100%">
      <Box
        className="Paper__Page"
        fillPositionedParent
        width="100%"
        height="100%"
        dangerouslySetInnerHTML={textHTML}
        p="10px"
      />
    </Box>
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
    <Window
      title={paper_name}
      theme="paper"
      width={400}
      height={500}>
      <Window.Content backgroundColor={paper_color} scrollable>
        <Box fitted fillPositionedParent>
          {(canEdit(held_item_details) && (<TabView />))
          || <PreviewView />}
        </Box>
      </Window.Content>
    </Window>
  );
};

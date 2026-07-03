import { Marked } from 'marked';
import { markedSmartypants } from 'marked-smartypants';
import { type RefObject, type SetStateAction, useEffect, useMemo } from 'react';
import { Box, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { sanitizeText } from '../../sanitize';
import { SPECIAL_TOKENS } from './constants';
import {
  canEdit,
  createWriteButtonId,
  getWriteButtonLocation,
  parseReplacements,
  walkTokens,
} from './helpers';
import { StampView } from './StampView';
import type { PaperContext, PaperInput, PaperReplacement } from './types';

interface CustomToken {
  token: string;
  element: string;
  isBlock?: boolean;
  closingTag?: boolean;
}

const CUSTOM_TOKENS: CustomToken[] = [
  {
    token: '!',
    element: 'strong',
    isBlock: false,
  },
  {
    token: '-#',
    element: 'small',
    isBlock: true,
  },
  {
    token: '---',
    element: 'hr',
    isBlock: false,
  },
  {
    token: '===',
    element: 'center',
    isBlock: false,
    closingTag: true,
  },
];

type PreviewViewProps = {
  paperContext: PaperContext;
  scrollableRef: RefObject<HTMLDivElement | null>;
  activeWriteButtonId: string;
  textAreaTextForPreview: string;
  usedReplacementsRef: RefObject<PaperReplacement[]>;
  handleOnScroll: (this: GlobalEventHandlers, event: Event) => any;
  setActiveWriteButtonId: (value: SetStateAction<string>) => void;
  setTextAreaActive: (value: SetStateAction<boolean>) => void;
};

// Regex that finds [input_field] fields.
const FIELD_REGEX: RegExp = /\[input_field(?:\]|\s+autofill_type=(\w+)\])/gi;
const CHILD_INPUT_REGEX: RegExp = /\[child_(\d+)\]/gi;
const SPECIAL_TOKEN_REGEX: RegExp = /\[(\w+)[^[]*?\]/gi;

const DOCUMENT_END_BUTTON_ID = 'document_end';
const INPUT_FIELD_BUTTON_AUTOFILL_TYPE_ATTRIBUTE = 'autofill-type';

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
export function PreviewView(props: PreviewViewProps) {
  const { act } = useBackend();

  const {
    paperContext,
    scrollableRef,
    handleOnScroll,
    activeWriteButtonId,
    setActiveWriteButtonId,
    setTextAreaActive,
    textAreaTextForPreview,
    usedReplacementsRef,
  } = props;

  const {
    raw_text_input,
    default_pen_font,
    default_pen_color,
    held_item_details,
    advanced_html_user,
    paper_color,
    replacements,
  } = paperContext;

  const editMode = canEdit(held_item_details);
  const fontFace = held_item_details?.font || default_pen_font;
  const fontColor = held_item_details?.color || default_pen_color;
  const fontBold = held_item_details?.use_bold || false;
  const marked = createAndConfigureMarked();
  const parsedDmText = useMemo(
    () =>
      createPreviewFromDM(raw_text_input, default_pen_font, default_pen_color),
    [raw_text_input, default_pen_font, default_pen_color, editMode],
  );

  const parseTextAreaText = useMemo(
    () =>
      parseReplacements(
        formatAndProcessRawText(
          textAreaTextForPreview,
          fontFace,
          fontColor,
          fontBold,
          advanced_html_user,
        ),
        Array.isArray(replacements) ? replacements : [],
      ),
    [textAreaTextForPreview, fontFace, fontColor, fontBold, advanced_html_user, replacements],
  );

  // Wraps the given raw text in a font span based on the supplied props.
  function setFontInText(
    text: string,
    font: string,
    color: string,
    bold: boolean = false,
  ): string {
    return `<span style="color:${color};font-family:${font};${
      bold ? 'font-weight: bold;' : ''
    }">${text}</span>`;
  }

  // Parses the given raw text through marked for applying markdown.
  function runMarkedDefault(rawText: string) {
    return marked.parse(rawText) as string;
  }

  // Fully formats, sanitises and parses the provided raw text and wraps it
  // as necessary.
  function formatAndProcessRawText(
    rawText: string,
    font: string,
    color: string,
    bold: boolean,
    advanced_html: boolean = false,
    paperInputRef?: string,
  ): string {
    if (!rawText) {
      return '';
    }

    const parsedText = runMarkedDefault(rawText);
    const sanitizedText = sanitizeText(parsedText, advanced_html);
    const fieldedText = createWriteButtons(sanitizedText, paperInputRef);
    const specialTokensParsedText = parseSpecialTokens(fieldedText);

    // Forth, we wrap the created text in the writing implement properties.
    return setFontInText(specialTokensParsedText, font, color, bold);
  }

  function createWriteButtons(text: string, paperInputRef?: string): string {
    let counter = 0;
    return text.replace(FIELD_REGEX, (match, p1) => {
      return createWriteButton(
        paperInputRef && createWriteButtonId(paperInputRef, counter++),
        p1,
      );
    });
  }

  function generatePreviewText(
    parsedDmText: string,
    parsedTextBox: string,
    editMode: boolean,
    writeButtonId: string,
  ) {
    return editMode
      ? insertTextAreaPreview(parsedDmText, parsedTextBox, writeButtonId) +
          `<button id='${DOCUMENT_END_BUTTON_ID}'><i class='fa fa-file-pen'></i> Писать в конец</button>`
      : parsedDmText;
  }

  function createWriteButton(id?: string, autofillType?: string): string {
    if (!editMode) {
      return '';
    }

    const inputFieldButton = document.createElement('button');
    if (id) {
      inputFieldButton.id = id;
    }
    if (autofillType) {
      inputFieldButton.setAttribute(
        INPUT_FIELD_BUTTON_AUTOFILL_TYPE_ATTRIBUTE,
        autofillType,
      );
    }
    inputFieldButton.classList.add('icon_only');
    inputFieldButton.innerHTML = "<i class='fa fa-pen'></i>";

    return inputFieldButton.outerHTML;
  }

  function onWriteButtonClick(event: MouseEvent) {
    const button = event.target as HTMLButtonElement;
    if (button.id === activeWriteButtonId) {
      setActiveWriteButtonId('');
    } else {
      setActiveWriteButtonId(button.id);
      setTextAreaActive(true);
    }
  }

  function onEndWriteButtonClick() {
    if (activeWriteButtonId) {
      setActiveWriteButtonId('');
    }

    setTextAreaActive(true);
  }

  function onAutofillButtonContextMenu(event: MouseEvent) {
    const button = event.target as HTMLButtonElement;
    const autofillType = button.getAttribute(
      INPUT_FIELD_BUTTON_AUTOFILL_TYPE_ATTRIBUTE,
    );

    if (!autofillType) {
      return;
    }

    const replacements = usedReplacementsRef.current;
    if (!Array.isArray(replacements)) {
      return;
    }

    const replacement = replacements.find(
      (r) => r.key === autofillType,
    );

    if (!replacement) {
      return;
    }

    event.preventDefault();
    const location = getWriteButtonLocation(button.id);
    act('add_text', {
      text: replacement.value,
      paper_input_ref: location.paperInputRef,
      field_id: location.fieldId + 1,
    });
  }

  // Creates the partial inline HTML for previewing or reading the paper from
  // only static_ui_data from DM.
  function createPreviewFromDM(
    rawTextInput: PaperInput[] | undefined,
    defaultPenFont: string,
    defaultPenColor: string,
  ): string {
    return (
      rawTextInput
        ?.map((paperInput) =>
          formatAndProcessPaperInput(
            paperInput,
            defaultPenFont,
            defaultPenColor,
          ),
        )
        .filter((value) => value)
        .join('') || ''
    );
  }

  function formatAndProcessPaperInput(
    paperInput: PaperInput,
    defaultPenFont: string,
    defaultPenColor: string,
  ) {
    const processedParentPaperInput = formatAndProcessRawText(
      paperInput.raw_text,
      paperInput.font || defaultPenFont,
      paperInput.color || defaultPenColor,
      paperInput.bold || false,
      paperInput.advanced_html,
      paperInput.ref,
    );

    if (!paperInput.children?.length) {
      return processedParentPaperInput;
    }

    return processedParentPaperInput.replaceAll(
      CHILD_INPUT_REGEX,
      (match, p1) => {
        if (!paperInput.children) {
          return '';
        }
        if (paperInput.children.length < p1) {
          return '';
        }

        return formatAndProcessPaperInput(
          paperInput.children[p1 - 1],
          defaultPenFont,
          defaultPenColor,
        );
      },
    );
  }

  // Inserts text area parsed data before active write button id
  //
  function insertTextAreaPreview(
    text: string,
    insertText: string,
    buttonId: string,
  ): string {
    const highlightedInsertText = `<span style='background-color:yellow'>${insertText}</span>`;
    if (!buttonId) {
      return text + highlightedInsertText;
    }

    return text.replace(
      new RegExp(`<button[^>]*id=["']${buttonId}["'][^>]*>`),
      (match) => {
        return highlightedInsertText + match;
      },
    );
  }

  function parseSpecialTokens(text: string) {
    return text.replace(SPECIAL_TOKEN_REGEX, (match, p1) => {
      const specialTokenResolver: (value: string) => string =
        SPECIAL_TOKENS[p1];

      if (!specialTokenResolver) {
        return match;
      }

      const resolved = specialTokenResolver(match);

      return parseSpecialTokens(resolved);
    });
  }

  function createAndConfigureMarked() {
    const markedInstance = new Marked();

    const customRules = CUSTOM_TOKENS.map((token) => ({
      pattern: new RegExp(
        `^${token.token}\\s+(.+?)(?:\\s*${token.closingTag && token.token}$|$)`,
        'm',
      ),
      render: (match: RegExpExecArray) => {
        const content = markedInstance.parseInline(match[1]);
        return `<${token.element}>${content}</${token.element}>${token.isBlock ? '<br>' : ''}`;
      },
    }));

    markedInstance.use(
      {
        breaks: true,
        gfm: true,
        walkTokens: walkTokens,
        renderer: {
          paragraph(tokens) {
            return marked.parseInline(tokens.text) as string;
          },
          text(tokens) {
            const result = tokens.text;
            for (const rule of customRules) {
              const match = rule.pattern.exec(result);
              if (match) {
                return rule.render(match);
              }
            }
            return result;
          },
        },
      },
      markedSmartypants(),
    );
    return markedInstance;
  }

  const previewText = generatePreviewText(
    parsedDmText,
    parseTextAreaText,
    editMode,
    activeWriteButtonId,
  );

  useEffect(() => {
    const buttons = document.querySelectorAll("[id^='paperfield_']");

    buttons.forEach((button: HTMLButtonElement) => {
      if (button.id === activeWriteButtonId) {
        button.ariaChecked = 'true';
      }
      button.addEventListener('click', onWriteButtonClick);

      const autofillType = button.getAttribute(
        INPUT_FIELD_BUTTON_AUTOFILL_TYPE_ATTRIBUTE,
      );
      if (autofillType) {
        button.addEventListener('contextmenu', onAutofillButtonContextMenu);
      }
    });

    return () =>
      buttons.forEach((button: HTMLButtonElement) => {
        if (button.id === activeWriteButtonId) {
          button.ariaChecked = 'false';
        }
        button.removeEventListener('contextmenu', onAutofillButtonContextMenu);
        button.removeEventListener('click', onWriteButtonClick);
      });
  }, [previewText, activeWriteButtonId]);

  useEffect(() => {
    const endButton = document.getElementById(DOCUMENT_END_BUTTON_ID);
    if (endButton) {
      endButton.addEventListener('click', onEndWriteButtonClick);
      if (!activeWriteButtonId) {
        endButton.ariaChecked = 'true';
      }
    }

    return () => {
      if (endButton) {
        endButton.removeEventListener('click', onEndWriteButtonClick);
        if (!activeWriteButtonId) {
          endButton.ariaChecked = 'false';
        }
      }
    };
  }, [previewText, activeWriteButtonId]);

  useEffect(() => {
    usedReplacementsRef.current = Array.isArray(replacements) ? replacements : [];
    return () => {
      usedReplacementsRef.current = [];
    };
  }, [
    textAreaTextForPreview,
    fontFace,
    fontColor,
    fontBold,
    advanced_html_user,
  ]);

  const textHTML = useMemo(
    () => ({
      __html: `<span class='paper-text'>${previewText}</span>`,
    }),
    [previewText],
  );

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

import { type KeyboardEvent, type RefObject, type SetStateAction, useCallback } from 'react';
import { Box, Button, Section, TextArea } from 'tgui-core/components';
import { KEY } from 'tgui-core/keys';
import { debounce } from 'tgui-core/timer';

import { useBackend } from '../../backend';
import { REPLACEMENT_TOKEN_START_REGEX } from './constants';
import { getWriteButtonLocation, parseReplacements } from './helpers';
import type { PaperContext, PaperInput, PaperReplacement } from './types';

type TextAreaSectionProps = {
  paperContext: PaperContext;
  textAreaText: string;
  activeWriteButtonId: string;
  lastDistanceFromBottom: number;
  usedReplacementsRef: RefObject<PaperReplacement[]>;
  textAreaRef: RefObject<HTMLTextAreaElement | null>;
  scrollableRef: RefObject<HTMLDivElement | null>;
  paperReplacementHint: PaperReplacement[];
  handleTextAreaKeyDown: (event: KeyboardEvent<HTMLTextAreaElement>) => void;
  setTextAreaText: (value: SetStateAction<string>) => void;
  setTextAreaActive: (value: SetStateAction<boolean>) => void;
  setTextAreaTextForPreview: (value: SetStateAction<string>) => void;
  setPaperReplacementHint: (value: SetStateAction<PaperReplacement[]>) => void;
  setSelectedHintButtonId: (value: SetStateAction<number>) => void;
  setActiveWriteButtonId: (value: SetStateAction<string>) => void;
};

export function TextAreaSection(props: TextAreaSectionProps) {
  const {
    paperContext,
    textAreaText,
    activeWriteButtonId,
    lastDistanceFromBottom,
    usedReplacementsRef,
    textAreaRef,
    scrollableRef,
    handleTextAreaKeyDown,
    setTextAreaText,
    setTextAreaActive,
    setTextAreaTextForPreview,
    paperReplacementHint,
    setPaperReplacementHint,
    setSelectedHintButtonId,
    setActiveWriteButtonId,
  } = props;

  const { act } = useBackend<PaperContext>();
  const {
    raw_text_input,
    default_pen_font,
    default_pen_color,
    paper_color,
    held_item_details,
    max_length,
    replacements,
  } = paperContext;

  const setTextAreaTextForPreviewWithDelayCallback = useCallback(
    debounce((text) => setTextAreaTextForPreview(text), 500),
    [],
  );

  const useFont = held_item_details?.font || default_pen_font;
  const useColor = held_item_details?.color || default_pen_color;
  const useBold = held_item_details?.use_bold || false;

  const savableData = textAreaText.length;

  const dmCharacters =
    raw_text_input?.reduce((lhs: number, rhs: PaperInput) => {
      return lhs + rhs.raw_text.length;
    }, 0) || 0;

  const usedCharacters = dmCharacters + textAreaText.length;

  const tooManyCharacters = usedCharacters > max_length;

  function onConfirmButtonClick() {
    if (!textAreaText.length) {
      return;
    }

    const textAreaTextWithReplacements = parseReplacements(
      `${textAreaText}${!activeWriteButtonId ? '<br>' : ''}`,
      Array.isArray(usedReplacementsRef.current) ? usedReplacementsRef.current : [],
    );
    const addTextData = activeWriteButtonId
      ? (() => {
          setActiveWriteButtonId('');

          const location = getWriteButtonLocation(activeWriteButtonId);
          return {
            text: textAreaTextWithReplacements,
            paper_input_ref: location.paperInputRef,
            field_id: location.fieldId + 1,
          };
        })()
      : { text: textAreaTextWithReplacements };

    act('add_text', addTextData);
    setTextAreaText('');
    setTextAreaTextForPreview('');
  }

  function handleTextAreaKeyUp(event: KeyboardEvent<HTMLTextAreaElement>) {
    if (event.key === KEY.Up || event.key === KEY.Down) {
      if (paperReplacementHint.length) {
        return;
      }
    }

    updatePaperReplacentHints();
  }

  function updatePaperReplacentHints() {
    setPaperReplacementHint(getReplacementHints());
    setSelectedHintButtonId(0);
  }

  function getReplacementHints(): PaperReplacement[] {
    if (!textAreaRef.current) {
      return [];
    }

    const textAreaValue = textAreaRef.current.value;
    const selectionStart = textAreaRef.current.selectionStart;
    if (!textAreaValue || !selectionStart) {
      return [];
    }

    const match = textAreaValue
      .substring(0, selectionStart)
      .match(REPLACEMENT_TOKEN_START_REGEX);

    if (!match) {
      return [];
    }

    if (match[0] === '[') {
      return (replacements ?? []).slice().sort((a, b) => a.key.length - b.key.length);
    }

    const tokenKey = match[1];

    return (replacements ?? [])
      .filter((value) => value.key.startsWith(tokenKey))
      .sort((a, b) => a.key.length - b.key.length);
  }

  return (
    <Section
      fill
      fitted
      title="Вставьте текст"
      buttons={
        <>
          <Box inline pr={'5px'} color={tooManyCharacters ? 'bad' : 'default'}>
            {`${usedCharacters} / ${max_length}`}
          </Box>
          <Button.Confirm
            disabled={!savableData || tooManyCharacters}
            color="good"
            onClick={onConfirmButtonClick}
          >
            Сохранить
          </Button.Confirm>
          <Button
            iconPosition="right"
            color={'red'}
            icon={'down-long'}
            onClick={() => setTextAreaActive(false)}
          >
            Скрыть
          </Button>
        </>
      }
    >
      <TextArea
        autoFocus
        className="Paper__TextArea"
        ref={textAreaRef}
        value={textAreaText}
        textColor={useColor}
        fontFamily={useFont}
        bold={useBold}
        backgroundColor={paper_color}
        dontUseTabForIndent={paperReplacementHint.length > 0}
        onKeyDown={handleTextAreaKeyDown}
        onKeyUp={handleTextAreaKeyUp}
        onClick={updatePaperReplacentHints}
        onChange={(text: string) => {
          setTextAreaText(text);
          setTextAreaTextForPreviewWithDelayCallback(text);

          if (scrollableRef.current) {
            const thisDistFromBottom =
              scrollableRef.current.scrollHeight -
              scrollableRef.current.scrollTop;
            scrollableRef.current.scrollTop +=
              thisDistFromBottom - lastDistanceFromBottom;
          }
        }}
      />
    </Section>
  );
}

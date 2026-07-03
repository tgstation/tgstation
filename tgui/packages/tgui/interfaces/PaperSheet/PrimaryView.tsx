import { type KeyboardEvent, useRef, useState } from 'react';
import { Button, Stack } from 'tgui-core/components';
import { KEY } from 'tgui-core/keys';

import { useBackend } from '../../backend';
import {
  REPLACEMENT_TOKEN_START_REGEX,
  TEXTAREA_INPUT_HEIGHT,
} from './constants';
import { canEdit } from './helpers';
import { PreviewView } from './Preview';
import { ReplacementHint } from './ReplacementHint';
import { PaperSheetStamper } from './Stamper';
import { TextAreaSection } from './TextAreaSection';
import type { PaperContext, PaperReplacement } from './types';

// Overarching component that holds the primary view for papercode.
export function PrimaryView() {
  const [textAreaActive, setTextAreaActive] = useState(false);
  const [textAreaText, setTextAreaText] = useState('');
  const [textAreaTextForPreview, setTextAreaTextForPreview] = useState('');
  const [activeWriteButtonId, setActiveWriteButtonId] = useState('');
  const [selectedHintButtonId, setSelectedHintButtonId] = useState(0);
  const [paperReplacementHint, setPaperReplacementHint] = useState<
    PaperReplacement[]
  >([]);
  const [lastDistanceFromBottom, setLastDistanceFromBottom] = useState(0);

  // Reference that gets passed to the <Section> holding the main preview.
  // Eventually gets filled with a reference to the section's scroll bar
  // funtionality.
  const scrollableRef = useRef<HTMLDivElement>(null);
  const usedReplacementsRef = useRef<PaperReplacement[]>([]);
  const textAreaRef = useRef<HTMLTextAreaElement>(null);

  const { data } = useBackend<PaperContext>();
  const { held_item_details } = data;
  const writeMode = canEdit(held_item_details);

  // Event handler for the onscroll event. Also gets passed to the <Section>
  // holding the main preview. Updates lastDistanceFromBottom.
  function onScrollHandler(this: GlobalEventHandlers, ev: Event) {
    const scrollable = ev.currentTarget as HTMLDivElement;
    if (scrollable) {
      setLastDistanceFromBottom(scrollable.scrollHeight - scrollable.scrollTop);
    }
  }

  function applyReplacementByHint(buttonKey: string) {
    if (!textAreaRef?.current) {
      return;
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
      return;
    }

    const matchedText = match[0];
    const matchIndex = match.index;
    if (matchIndex === undefined) {
      return;
    }

    const updatedTextArea =
      textAreaValue.slice(0, matchIndex) +
      `[${buttonKey}]` +
      textAreaValue.slice(matchIndex + matchedText.length);

    setTextAreaText(updatedTextArea);
    setTextAreaTextForPreview(updatedTextArea);
    setPaperReplacementHint([]);
    setSelectedHintButtonId(0);

    textAreaRef.current.focus();
  }

  function handleHintListInteraction(
    event: KeyboardEvent<HTMLTextAreaElement | HTMLDivElement>,
  ): void {
    if (!paperReplacementHint.length || !textAreaActive) {
      return;
    }

    switch (event.key) {
      case KEY.Up:
      case KEY.Down:
        handleArrowKeys(event.key);
        event.preventDefault();
        break;
      case KEY.Tab:
      case KEY.Enter:
        handleEnterKey();
        event.preventDefault();
        break;
    }
  }

  function handleArrowKeys(key: KEY.Up | KEY.Down) {
    const lastIndex = paperReplacementHint.length - 1;
    const firstIndex = 0;

    setSelectedHintButtonId((id) => {
      const newId = key === KEY.Up ? id - 1 : id + 1;
      const clampedId = Math.max(firstIndex, Math.min(lastIndex, newId));
      const selectedButton = document.querySelector(
        `#Paper__Hints .Paper__Hints--hint:nth-child(${clampedId + 1})`,
      );

      if (selectedButton) {
        selectedButton.scrollIntoView({ behavior: 'auto', block: 'nearest' });
      }

      return clampedId;
    });
  }

  function handleEnterKey() {
    applyReplacementByHint(paperReplacementHint[selectedHintButtonId].key);
  }

  return (
    <>
      <PaperSheetStamper scrollableRef={scrollableRef} />
      <Stack vertical fillPositionedParent g={0}>
        <Stack.Item grow={3} basis={1}>
          <PreviewView
            paperContext={data}
            scrollableRef={scrollableRef}
            handleOnScroll={onScrollHandler}
            activeWriteButtonId={activeWriteButtonId}
            setActiveWriteButtonId={setActiveWriteButtonId}
            textAreaTextForPreview={textAreaTextForPreview}
            setTextAreaActive={setTextAreaActive}
            usedReplacementsRef={usedReplacementsRef}
          />
        </Stack.Item>
        {writeMode &&
          (textAreaActive ? (
            <Stack.Item
              shrink={1}
              height={`${TEXTAREA_INPUT_HEIGHT}px`}
              position="relative"
            >
              {paperReplacementHint.length > 0 && textAreaActive && (
                <Stack className="Paper__Hints--wrapper">
                  <Stack.Item className="Paper__Hints" grow>
                    <ReplacementHint
                      onKeyDown={handleHintListInteraction}
                      paperReplacementHint={paperReplacementHint}
                      selectedHintButtonId={selectedHintButtonId}
                      onHintButtonClick={applyReplacementByHint}
                    />
                  </Stack.Item>
                  <Stack.Item className="Paper__Hints--blur" m={0} />
                </Stack>
              )}
              <TextAreaSection
                paperContext={data}
                textAreaText={textAreaText}
                activeWriteButtonId={activeWriteButtonId}
                lastDistanceFromBottom={lastDistanceFromBottom}
                usedReplacementsRef={usedReplacementsRef}
                textAreaRef={textAreaRef}
                scrollableRef={scrollableRef}
                paperReplacementHint={paperReplacementHint}
                handleTextAreaKeyDown={handleHintListInteraction}
                setTextAreaText={setTextAreaText}
                setTextAreaActive={setTextAreaActive}
                setTextAreaTextForPreview={setTextAreaTextForPreview}
                setPaperReplacementHint={setPaperReplacementHint}
                setSelectedHintButtonId={setSelectedHintButtonId}
                setActiveWriteButtonId={setActiveWriteButtonId}
              />
            </Stack.Item>
          ) : (
            <Stack.Item textAlign="right">
              <Button
                icon={'up-long'}
                iconPosition="right"
                onClick={() => setTextAreaActive(true)}
              >
                Открыть редактор
              </Button>
            </Stack.Item>
          ))}
      </Stack>
    </>
  );
}

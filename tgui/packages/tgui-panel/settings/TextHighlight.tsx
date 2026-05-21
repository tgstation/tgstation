import { useMemo } from 'react';
import {
  Box,
  Button,
  ColorBox,
  Divider,
  Icon,
  Input,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { chatRenderer } from '../chat/renderer';
import { WARN_AFTER_HIGHLIGHT_AMT } from './constants';
import { useHighlights } from './use-highlights';

export function TextHighlightSettings(props) {
  const {
    highlights: { highlightSettings },
    addHighlight,
  } = useHighlights();

  return (
    <Section fill scrollable height="250px">
      <Stack vertical>
        {highlightSettings.map((id, i) => (
          <TextHighlightSetting
            key={i}
            id={id}
            mb={i + 1 === highlightSettings.length ? 0 : '10px'}
          />
        ))}
        <Stack.Item>
          <Box>
            <Button
              color="transparent"
              icon="plus"
              onClick={() => addHighlight()}
            >
              Add Highlight Setting
            </Button>
            {highlightSettings.length >= WARN_AFTER_HIGHLIGHT_AMT && (
              <Box inline fontSize="0.9em" ml={1} color="red">
                <Icon mr={1} name="triangle-exclamation" />
                Large amounts of highlights can potentially cause performance
                issues!
              </Box>
            )}
          </Box>
        </Stack.Item>
      </Stack>
      <Divider />
      <Box>
        <Button icon="check" onClick={() => chatRenderer.rebuildChat()}>
          Apply now
        </Button>
        <Box inline fontSize="0.9em" ml={1} color="label">
          Can freeze the chat for a while.
        </Box>
      </Box>
    </Section>
  );
}

const oneCharacterRegex = /^(\[.*\]|\\.|.)$/;

function extractRegex(highlight: string): string | null {
  if (
    highlight.charAt(0) !== '/' ||
    highlight.charAt(highlight.length - 1) !== '/'
  ) {
    return null;
  }
  const expr = highlight.substring(1, highlight.length - 1);
  if (oneCharacterRegex.test(expr)) {
    return null;
  }
  return expr;
}

function TextHighlightSetting(props) {
  const { id, ...rest } = props;
  const {
    highlights: { highlightSettingById },
    updateHighlight,
    removeHighlight,
  } = useHighlights();
  const {
    enabled,
    highlightColor,
    highlightText,
    highlightWholeMessage,
    matchWord,
    matchCase,
  } = highlightSettingById[id];

  const highlightRegex = useMemo(
    () => extractRegex(highlightText),
    [highlightText],
  );

  const isRegexValid = useMemo(() => {
    if (!highlightRegex) return true;
    try {
      new RegExp(highlightRegex, 'g');
      return true;
    } catch {
      return false;
    }
  }, [highlightRegex]);

  return (
    <Stack.Item {...rest}>
      <Stack mb={1} color="label" align="baseline">
        <Stack.Item grow>
          <Button.Checkbox
            checked={!!enabled}
            mr="5px"
            onClick={() =>
              updateHighlight({
                id,
                enabled: !enabled,
              })
            }
          >
            Enabled
          </Button.Checkbox>
          <Button
            color="transparent"
            icon="times"
            onClick={() => removeHighlight(id)}
          >
            Delete
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            checked={highlightWholeMessage}
            tooltip="If this option is selected, the entire message will be highlighted in yellow."
            onClick={() =>
              updateHighlight({
                id,
                highlightWholeMessage: !highlightWholeMessage,
              })
            }
          >
            Whole Message
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            checked={matchWord}
            tooltipPosition="bottom-start"
            tooltip="If this option is selected, only exact matches (no extra letters before or after) will trigger. Not compatible with punctuation. Overriden if regex is used."
            disabled={!!highlightRegex}
            onClick={() =>
              updateHighlight({
                id,
                matchWord: !matchWord,
              })
            }
          >
            Exact
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            tooltip="If this option is selected, the highlight will be case-sensitive."
            checked={matchCase}
            onClick={() =>
              updateHighlight({
                id,
                matchCase: !matchCase,
              })
            }
          >
            Case
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <ColorBox mr={1} color={highlightColor} />
          <Input
            width="5em"
            monospace
            placeholder="#ffffff"
            value={highlightColor}
            onBlur={(value) =>
              updateHighlight({
                id,
                highlightColor: value,
              })
            }
          />
        </Stack.Item>
      </Stack>
      <TextArea
        fluid
        height="3em"
        value={highlightText}
        placeholder="Put words to highlight here. Separate terms with commas, i.e. (term1, term2, term3)"
        style={{ border: isRegexValid ? '' : '1px solid red' }}
        onBlur={(value) =>
          updateHighlight({
            id: id,
            highlightText: value,
          })
        }
      />
    </Stack.Item>
  );
}

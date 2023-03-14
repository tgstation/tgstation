import { useBackend } from '../backend';
import { GasmixParser } from './common/GasmixParser';
import type { Gasmix } from './common/GasmixParser';
import { Button, LabeledList, Section, Flex, Slider } from '../components';
import { AtmosHandbookContent, atmosHandbookHooks } from './common/AtmosHandbook';
import { Window } from '../layouts';

export type GasAnalyzerData = {
  gasmixes: Gasmix[];
  autoUpdating: boolean;
  historyLength: number;
  historyIndex: number;
};

export const GasAnalyzerContent = (props, context) => {
  const { act, data } = useBackend<GasAnalyzerData>(context);
  const { gasmixes } = data;
  const [setActiveGasId, setActiveReactionId] = atmosHandbookHooks(context);
  return (
    <>
      {gasmixes.map((gasmix) => (
        <Section title={gasmix.name} key={gasmix.reference}>
          <GasmixParser
            gasmix={gasmix}
            gasesOnClick={setActiveGasId}
            reactionOnClick={setActiveReactionId}
          />
        </Section>
      ))}
      <AtmosHandbookContent vertical />
    </>
  );
};

export const GasAnalyzer = (props, context) => {
  const { act, data } = useBackend<GasAnalyzerData>(context);
  const { autoUpdating, historyLength, historyIndex } = data;
  return (
    <Window width={500} height={450}>
      <Window.Content scrollable>
        <LabeledList.Item label="Auto-Scanning">
          <Button
            icon={autoUpdating ? 'sync-alt' : 'times'}
            content={autoUpdating ? 'Enabled.' : 'Disabled.'}
            onClick={() => act('autoscantoggle')}
            fluid
            textAlign="center"
            selected={autoUpdating}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Scan History">
          <Flex inline width="100%">
            <Flex.Item>
              <Button
                icon={'sync'}
                content={'Clear'}
                onClick={() => act('clearhistory')}
                textAlign="center"
                disabled={historyLength === 0}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                icon={'backward'}
                content={'Previous'}
                onClick={() => act('historybackwards')}
                textAlign="center"
                disabled={historyLength === 0 || historyIndex === historyLength}
              />
            </Flex.Item>
            <Flex.Item grow={1} mx={1}>
              <Slider
                value={historyIndex}
                fillValue={historyIndex}
                minValue={1}
                maxValue={historyLength}
                step={1}
                stepPixelSize={12}
                onDrag={(e, value) =>
                  act('input', {
                    target: value,
                  })
                }
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                icon={'forward'}
                content={'Next'}
                onClick={() => act('historyforward')}
                textAlign="center"
                disabled={historyLength === 0 || historyIndex === 1}
              />
            </Flex.Item>
          </Flex>
        </LabeledList.Item>
        <GasAnalyzerContent />
      </Window.Content>
    </Window>
  );
};

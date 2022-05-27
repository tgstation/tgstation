import { useBackend } from '../../backend';
import { Box, Button, Dimmer, Icon, LabeledList, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { DnaConsoleEnzymes } from './DnaConsoleEnzymes';
import { DnaConsoleSequencer } from './DnaConsoleSequencer';
import { DnaConsoleStorage } from './DnaConsoleStorage';
import { DnaScanner } from './DnaScanner';
import { CONSOLE_MODE_ENZYMES, CONSOLE_MODE_FEATURES, CONSOLE_MODE_SEQUENCER, CONSOLE_MODE_STORAGE, STORAGE_MODE_CONSOLE } from './constants';

export const DnaConsole = (props, context) => {
  const { data } = useBackend(context);
  const {
    isPulsing,
    timeToPulse,
    subjectUNI,
    subjectUF,
  } = data;
  const { consoleMode } = data.view;

  return (
    <Window
      title="DNA Console"
      width={539}
      height={710}>
      {!!isPulsing && (
        <Dimmer
          fontSize="14px"
          textAlign="center">
          <Icon
            mr={1}
            name="spinner"
            spin />
          Pulse in progress...
          <Box mt={1} />
          {timeToPulse}s
        </Dimmer>
      )}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <DnaScanner />
          </Stack.Item>
          <Stack.Item>
            <DnaConsoleCommands />
          </Stack.Item>
          <Stack.Item grow>
            {consoleMode === CONSOLE_MODE_STORAGE && (
              <DnaConsoleStorage />
            )}
            {consoleMode === CONSOLE_MODE_SEQUENCER && (
              <DnaConsoleSequencer />
            )}
            {consoleMode === CONSOLE_MODE_ENZYMES && (
              <DnaConsoleEnzymes
                subjectBlock={subjectUNI}
                type="ui"
                name="Enzymes" />
            )}
            {consoleMode === CONSOLE_MODE_FEATURES && (
              <DnaConsoleEnzymes
                subjectBlock={subjectUF}
                type="uf"
                name="Features" />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DnaConsoleCommands = (props, context) => {
  const { data, act } = useBackend(context);
  const { hasDisk, isInjectorReady, injectorSeconds } = data;
  const { consoleMode } = data.view;

  return (
    <Section
      title="DNA Console"
      buttons={!isInjectorReady && (
        <Box
          lineHeight="20px"
          color="label">
          Injector on cooldown ({injectorSeconds}s)
        </Box>
      )}>
      <LabeledList>
        <LabeledList.Item label="Mode">
          <Button
            content="Storage"
            selected={consoleMode === CONSOLE_MODE_STORAGE}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_STORAGE,
            })} />
          <Button
            content="Sequencer"
            disabled={!data.isViableSubject}
            selected={consoleMode === CONSOLE_MODE_SEQUENCER}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_SEQUENCER,
            })} />
          <Button
            content="Enzymes"
            selected={consoleMode === CONSOLE_MODE_ENZYMES}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_ENZYMES,
            })} />
          <Button
            content="Features"
            selected={consoleMode === CONSOLE_MODE_FEATURES}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_FEATURES,
            })} />
        </LabeledList.Item>
        {!!hasDisk && (
          <LabeledList.Item label="Disk">
            <Button
              icon="eject"
              content="Eject"
              onClick={() => {
                act('eject_disk');
                act('set_view', {
                  storageMode: STORAGE_MODE_CONSOLE,
                });
              }} />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

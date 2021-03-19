import { useBackend } from '../../backend';
import { Box, Button, Dimmer, Icon, LabeledList, Section } from '../../components';
import { Window } from '../../layouts';
import { DnaConsoleEnzymes } from './DnaConsoleEnzymes';
import { DnaConsoleSequencer } from './DnaConsoleSequencer';
import { DnaConsoleStorage } from './DnaConsoleStorage';
import { DnaScanner } from './DnaScanner';
import { CONSOLE_MODE_ENZYMES, CONSOLE_MODE_SEQUENCER, CONSOLE_MODE_STORAGE, STORAGE_MODE_CONSOLE } from './constants';

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

export const DnaConsole = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    isPulsingRads,
    radPulseSeconds,
  } = data;
  const { consoleMode } = data.view;
  return (
    <Window
      title="DNA Console"
      width={539}
      height={710}>
      {!!isPulsingRads && (
        <Dimmer
          fontSize="14px"
          textAlign="center">
          <Icon
            mr={1}
            name="spinner"
            spin />
          Radiation pulse in progress...
          <Box mt={1} />
          {radPulseSeconds}s
        </Dimmer>
      )}
      <Window.Content scrollable>
        <DnaScanner />
        <DnaConsoleCommands />
        {consoleMode === CONSOLE_MODE_STORAGE && (
          <DnaConsoleStorage />
        )}
        {consoleMode === CONSOLE_MODE_SEQUENCER && (
          <DnaConsoleSequencer />
        )}
        {consoleMode === CONSOLE_MODE_ENZYMES && (
          <DnaConsoleEnzymes />
        )}
      </Window.Content>
    </Window>
  );
};

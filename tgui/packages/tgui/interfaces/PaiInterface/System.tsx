import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section, Stack } from 'tgui/components';
import { ICON_MAP } from './constants';
import { PaiData } from './types';

export const SystemDisplay = (props, context) => {
  return (
    <Stack fill vertical>
      <Stack.Item grow={3}>
        <SystemWallpaper />
      </Stack.Item>
      <Stack.Item grow>
        <SystemInfo />
      </Stack.Item>
    </Stack>
  );
};

/** Renders some ASCII art. Changes to red on emag. */
const SystemWallpaper = (props, context) => {
  const { data } = useBackend<PaiData>(context);
  const { emagged } = data;

  const owner = !emagged ? 'NANOTRASEN' : ' SYNDICATE';
  const eyebrows = !emagged ? "/\\ ' /\\" : ' \\\\ // ';

  const paiAscii = [
    ' ________  ________  ___',
    ' |\\   __  \\|\\   __  \\|\\  \\',
    ' \\ \\  \\|\\  \\ \\  \\|\\  \\ \\  \\     Interface',
    '  \\ \\   ____\\ \\   __  \\ \\  \\     Version 2.5',
    '   \\ \\  \\___|\\ \\  \\ \\  \\ \\  \\',
    '    \\ \\__\\    \\ \\__\\ \\__\\ \\__\\     Property of',
    `     \\|__|     \\|__|\\|__|\\|__|      ${owner}`,
    '',
  ].join('\n');

  const floofAscii = [
    '                              .--.       .-.',
    "        ,;;``;;-;,,..___.,,.-/   `;_//,.'   )",
    "      .' ;;  `;  :; `;;  ;;  `.       '/   .'",
    `     ,;  ';   ;   '  ';  ';   ,'    ${eyebrows}';`, // lol
    "    /'     `      \\   `     ;','   ( d\\__b_),",
    "   /   /       .,;;)       ', (    .'     __\\",
    "  ;:.  \\     ,_   /         ', ' .'_      \\/;",
    " ,   ,;'      `;;/       /    ';,\\ `-..__._,'",
    " ;:.  /____  ..-'--.    /-'    ..---. ._._/ ---.",
    " |    ;' ;'|        \\--/;' ,' /      \\   ,      \\",
    " `.fL__;,__/-..__)_)/  `--'--'`-._)_)/ --\\.._)_)/",
  ].join('\n');

  return (
    <Section fill nowrap overflow="hidden">
      <pre>
        <Box color={!emagged ? 'blue' : 'crimson'}>{paiAscii}</Box>
        <Box color={!emagged ? 'gold' : 'limegreen'}>{floofAscii}</Box>
      </pre>
    </Section>
  );
};

/** Displays master info.
 * You can check their DNA and change your image here.
 */
const SystemInfo = (props, context) => {
  const { act, data } = useBackend<PaiData>(context);
  const { image, master_dna, master_name } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            disabled={!master_dna}
            icon="dna"
            onClick={() => act('check dna')}
            tooltip="Verifies your master's DNA. Must be carried in hand.">
            Verify
          </Button>
          <Button
            icon={ICON_MAP[image]}
            onClick={() => act('change image')}
            tooltip="Change your display image.">
            Display
          </Button>
        </>
      }
      fill
      title="System Info">
      <LabeledList>
        <LabeledList.Item label="Master">
          {master_name || 'None.'}
        </LabeledList.Item>
        <LabeledList.Item color={master_dna && 'red'} label="DNA">
          {master_dna || 'None.'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

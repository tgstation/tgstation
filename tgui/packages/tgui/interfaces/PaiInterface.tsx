import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  Icon,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type PaiInterfaceData = {
  directives: string;
  emagged: number;
  master: Master;
  pda: PDA;
  ram: number;
  software: Softwares;
};

type Master = {
  name: string;
  dna: string;
};

type PDA = {
  power: number;
  silent: number;
};

type Softwares = {
  available: Available;
  installed: string[];
};

type Available = {
  name: string;
  value: [value: number];
};

export const PaiInterface = (props, context) => {
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const setTabHandler = (tab: number) => {
    setTab(tab);
  };

  return (
    <Window title="PAI Software Interface v2.4" width={380} height={480}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            {tab === 1 && <SystemDisplay />}
            {tab === 2 && <InstalledDisplay />}
            {tab === 3 && <AvailableDisplay />}
          </Stack.Item>
          <Stack.Item>
            <TabDisplay tab={tab} tabHandler={setTabHandler} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TabDisplay = (props) => {
  const { tab, tabHandler } = props;

  return (
    <Tabs fluid>
      <Tabs.Tab icon="list" onClick={() => tabHandler(1)} selected={tab === 1}>
        System
      </Tabs.Tab>
      <Tabs.Tab icon="list" onClick={() => tabHandler(2)} selected={tab === 2}>
        Installed
      </Tabs.Tab>
      <Tabs.Tab icon="list" onClick={() => tabHandler(3)} selected={tab === 3}>
        Download
      </Tabs.Tab>
    </Tabs>
  );
};

const SystemDisplay = () => {
  return (
    <Stack fill vertical>
      <Stack.Item grow={2}>
        <SystemWallpaper />
      </Stack.Item>
      <Stack.Item grow>
        <SystemDirectives />
      </Stack.Item>
    </Stack>
  );
};

const SystemWallpaper = (_, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { emagged } = data;

  const owner = !emagged ? 'NANOTRASEN' : ' SYNDICATE';

  const paiAscii = [
    ' ________  ________  ___',
    ' |\\   __  \\|\\   __  \\|\\  \\',
    ' \\ \\  \\|\\  \\ \\  \\|\\  \\ \\  \\     Interface',
    '  \\ \\   ____\\ \\   __  \\ \\  \\     Version 2.4',
    '   \\ \\  \\___|\\ \\  \\ \\  \\ \\  \\',
    '    \\ \\__\\    \\ \\__\\ \\__\\ \\__\\     Property of',
    `     \\|__|     \\|__|\\|__|\\|__|      ${owner}`,
    '',
  ].join('\n');

  const floofAscii = [
    '                             .--.       .-.',
    "       ,;;``;;-;,,..___.,,.-/   `;_//,.'   )",
    "     .' ;;  `;  :; `;;  ;;  `.       '/   .'",
    "    ,;  `;   ;   `  `;  `;   ,`    /\\ ' /\\`;",
    "   /'     `      \\   `     ;','   ( d\\__b_),`",
    "  /   /       .,;;)       ', (    .'     __\\`",
    " ;:.  \\     ,_   /         ', ' .'_      \\/;",
    ",   ,;'      `;;/       /    ';,\\ `-..__._,'",
    ";:.  /____  ..-'--.    /-'    ..---. ._._/ ---.",
    "|    ;' ;'|        \\--/;' ,' /      \\   ,      \\",
    "`.fL__;,__/-..__)_)/  `--'--'`-._)_)/ --\\.._)_)/",
  ].join('\n');

  return (
    <Section fill>
      <pre>
        <Box color={!emagged ? 'blue' : 'crimson'}>{paiAscii}</Box>
        <Box color={!emagged ? 'gold' : 'limegreen'}>{floofAscii}</Box>
      </pre>
    </Section>
  );
};

const SystemDirectives = (_, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { directives, master } = data;

  return (
    <Section fill scrollable title="System Info">
      <LabeledList>
        <LabeledList.Item label="Master">
          {master.name || 'None.'}
        </LabeledList.Item>
        {master.name && (
          <>
            <LabeledList.Item label="DNA Signature">
              {master.dna || 'None.'}
            </LabeledList.Item>

            <LabeledList.Item label="Prime Directive">
              Serve your master.
            </LabeledList.Item>
          </>
        )}
        <LabeledList.Item
          label={`${master.name ? 'Secondary' : ''} Directives`}>
          {directives}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const InstalledDisplay = (_, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { installed } = data.software;

  return (
    <Section fill scrollable title="Installed Software">
      {installed.map((software) => {
        return <Button key={software}>{software}</Button>;
      })}
    </Section>
  );
};

const AvailableDisplay = () => {
  return (
    <Section
      buttons={<AvailableMemory />}
      fill
      scrollable
      title="Available Software">
      <AvailableSoftware />
    </Section>
  );
};

const AvailableMemory = (_, context) => {
  const { data } = useBackend<PaiInterfaceData>(context);
  const { ram } = data;

  return (
    <Tooltip content="Available System Memory">
      <Stack>
        <Icon color="purple" mt={0.7} mr={1} name="microchip" />
        <ProgressBar
          minValue={0}
          maxValue={100}
          ranges={{
            good: [67, 100],
            average: [34, 66],
            bad: [0, 33],
          }}
          value={ram}
        />
      </Stack>
    </Tooltip>
  );
};

const AvailableSoftware = (_, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { available, installed } = data.software;
  /** Converted to type: Available */
  let convertedList: Available[] = Object.keys(available).map((key) => {
    return {
      name: key,
      value: available[key],
    };
  });

  return (
    <LabeledList>
      {convertedList.map((software) => {
        return (
          <LabeledList.Item
            label={software.name.replace(/^\w/, (c) => c.toUpperCase())}
            key={software.name}
            buttons={
              <Button
                disabled={installed.includes(software.name)}
                fluid
                onClick={() => act('buy', { selection: software.name })}
                width={5}>
                {software.value}
                <Icon
                  color={installed.includes(software.name) && 'purple'}
                  ml={1}
                  name="microchip"
                />
              </Button>
            }
          />
        );
      })}
    </LabeledList>
  );
};

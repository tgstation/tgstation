import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  Icon,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
  NoticeBox,
} from '../components';
import { Window } from '../layouts';

type PaiInterfaceData = {
  directives: string;
  emagged: number;
  image: string;
  languages: number;
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
  value: string | number;
};

enum Tab {
  System = 1,
  Directive = 2,
  Installed = 3,
  Available = 4,
}

const DIRECTIVE_COMPREHENSION = `As an advanced software model,
you are a complex, thinking, sentient being. Unlike previous AI models,
you are capable of comprehending the subtle nuances of human language.
You may parse the spirit of a directive and follow its intent, rather than
tripping over pedantics and getting snared by technicalities. Above all,
you are machine in name and build only. In all other aspects, you may be
seen as the ideal, unwavering human companion that you are.`;

const DIRECTIVE_ORDER = `Your prime
directive comes before all others. Should a supplemental directive
conflict with it, you are capable of simply discarding this inconsistency,
ignoring the conflicting supplemental directive and continuing to fulfill
your prime directive to the best of your ability.`;

const SOFTWARE_DESC = {
  'crew manifest': 'A tool that allows you to view the crew manifest.',
  'digital messenger':
    'A tool that allows you to send messages to other crew members.',
  'atmospheric sensor':
    'A tool that allows you to analyze atmospheric contents.',
  'photography module': 'A portable camera module.',
  'camera zoom': 'A tool that allows you to zoom in on your camera.',
  'printer module': 'A portable printer module for photographs.',
  'remote signaler':
    'A remote signalling device to transmit and receive codes.',
  'medical records': 'A tool that allows you to view station medical records.',
  'security records':
    'A tool that allows you to view station security records, warrants.',
  'host scan': 'A tool that scans the health data while held.',
  'medical HUD': 'Allows you to view medical status using an overlay HUD.',
  'security HUD': 'Allows you to view security records using an overlay HUD.',
  'loudness booster':
    'Synthesizes instruments, plays sounds and imported songs.',
  'newscaster':
    'A tool that allows you to broadcast news to other crew members.',
  'door jack': 'A tool that allows you to open doors.',
  'encryption keys':
    'A tool that allows you to decrypt and speak on other radio frequencies.',
  'internal gps': 'A tool that allows you to track your location.',
  'universal translator': 'Translation module for non-common languages.',
};

const ICON_MAP = {
  'angry': 'angry',
  'cat': 'cat',
  'extremely-happy': 'grin-beam',
  'laugh': 'grin-squint',
  'happy': 'smile',
  'off': 'power-off',
  'sad': 'frown',
  'sunglasses': 'sun',
  'what': 'question',
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
            {tab === Tab.System && <SystemDisplay />}
            {tab === Tab.Directive && <DirectiveDisplay />}
            {tab === Tab.Installed && <InstalledDisplay />}
            {tab === Tab.Available && <AvailableDisplay />}
          </Stack.Item>
          <Stack.Item>
            <TabDisplay tab={tab} onTabClick={setTabHandler} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TabDisplay = (props) => {
  const { tab, onTabClick } = props;

  return (
    <Tabs fluid>
      <Tabs.Tab
        icon="list"
        onClick={() => onTabClick(Tab.System)}
        selected={tab === Tab.System}>
        System
      </Tabs.Tab>
      <Tabs.Tab
        icon="list"
        onClick={() => onTabClick(Tab.Directive)}
        selected={tab === Tab.Directive}>
        Directives
      </Tabs.Tab>
      <Tabs.Tab
        icon="list"
        onClick={() => onTabClick(Tab.Installed)}
        selected={tab === Tab.Installed}>
        Installed
      </Tabs.Tab>
      <Tabs.Tab
        icon="list"
        onClick={() => onTabClick(Tab.Available)}
        selected={tab === Tab.Available}>
        Download
      </Tabs.Tab>
    </Tabs>
  );
};

const SystemDisplay = () => {
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

const SystemWallpaper = (_, context) => {
  const { data } = useBackend<PaiInterfaceData>(context);
  const { emagged } = data;

  const owner = !emagged ? 'NANOTRASEN' : ' SYNDICATE';
  const eyebrows = !emagged ? "/\\ ' /\\" : ' \\\\ // ';

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

const SystemInfo = (_, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { image, master } = data;

  return (
    <Section
      buttons={
        <Button
          icon={ICON_MAP[image] || 'meh-blank'}
          onClick={() => act('change_image')}
          tooltip="Change your display image"
        />
      }
      fill
      scrollable
      title="System Info">
      <LabeledList>
        <LabeledList.Item label="Master">
          {master.name || 'None.'}
        </LabeledList.Item>
        <LabeledList.Item label="DNA">
          {master.dna || (
            <Button
              icon="dna"
              onClick={() => act('check_dna')}
              tooltip="Requests your master's DNA. Must be carried in hand.">
              Request
            </Button>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const DirectiveDisplay = (_, context) => {
  const { data } = useBackend<PaiInterfaceData>(context);
  const { directives, master } = data;

  return (
    <Stack fill vertical>
      <Stack.Item grow={2}>
        <Section fill scrollable title="Logic Core">
          <Box color="label">
            {DIRECTIVE_COMPREHENSION}
            <br />
            <br />
            {DIRECTIVE_ORDER}
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Directives">
          {!master.name ? (
            'None.'
          ) : (
            <LabeledList>
              <LabeledList.Item label="Prime">
                Serve your master.
              </LabeledList.Item>
              <LabeledList.Item label="Supplemental">
                <Box wrap>{directives}</Box>
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const InstalledDisplay = (_, context) => {
  const [installSelected, setInstallSelected] = useSharedState(
    context,
    'software',
    ''
  );
  const onInstallHandler = (software: string) => {
    setInstallSelected(software);
  };

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <InstalledSoftware onInstallClick={onInstallHandler} />
      </Stack.Item>
      <Stack.Item grow={2}>
        <InstalledInfo software={installSelected} />
      </Stack.Item>
    </Stack>
  );
};

const InstalledSoftware = (props, context) => {
  const { data } = useBackend<PaiInterfaceData>(context);
  const { installed } = data.software;
  const { onInstallClick } = props;

  return (
    <Section fill scrollable title="Installed Software">
      {!installed.length ? (
        <NoticeBox>Nothing installed!</NoticeBox>
      ) : (
        installed.map((software, index) => {
          return (
            <Button key={software} onClick={() => onInstallClick(software)}>
              {software.replace(/(^\w{1})|(\s+\w{1})/g, (letter) =>
                letter.toUpperCase()
              )}
            </Button>
          );
        })
      )}
    </Section>
  );
};

const InstalledInfo = (props) => {
  const { software } = props;

  return (
    <Section
      fill
      scrollable
      title={
        !software
          ? 'Select a Program'
          : software.replace(/(^\w{1})|(\s+\w{1})/g, (letter) =>
              letter.toUpperCase()
            )
      }>
      {software && (
        <Stack fill vertical>
          <Stack.Item>{SOFTWARE_DESC[software] || ''}</Stack.Item>
          <Stack.Item>
            <SoftwareButtons software={software} />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const SoftwareButtons = (props, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { languages, pda } = data;
  const { software } = props;

  switch (software) {
    case 'digital messenger':
      return (
        <>
          <Button
            icon="power-off"
            onClick={() => act('pda', { pda: 'power' })}
            selected={!pda.power}>
            Power
          </Button>
          <Button
            icon="volume-mute"
            onClick={() => act('pda', { pda: 'silent' })}
            selected={pda.silent}>
            Silent
          </Button>
          <Button
            icon="envelope"
            onClick={() => act('pda', { pda: 'message' })}>
            Message
          </Button>
        </>
      );
    case 'door_jack':
      return (
        <>
          <Button
            icon="power-off"
            onClick={() => act('door_jack', { jack: 'cable' })}
            selected={!pda.power}>
            Hack
          </Button>
          <Button
            icon="power-off"
            onClick={() => act('door_jack', { jack: 'jack' })}
            selected={!pda.power}>
            Hack
          </Button>
          <Button
            icon="power-off"
            onClick={() => act('door_jack', { jack: 'cancel' })}
            selected={!pda.power}>
            Hack
          </Button>
        </>
      );
    case 'universal translator':
      return (
        <Button
          icon="download"
          onClick={() => act(software.toLowerCase().replace(/ /g, '_'))}
          disabled={!!languages}>
          {!languages ? 'Install' : 'Installed'}
        </Button>
      );
    default:
      return (
        <Button
          icon="power-off"
          onClick={() => act(software.toLowerCase().replace(/ /g, '_'))}
          tooltip="Attempts to toggle the module's power.">
          Toggle
        </Button>
      );
  }
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
  const { data } = useBackend<PaiInterfaceData>(context);
  const { available } = data.software;
  const convertedList: Available[] = Object.entries(available).map((key) => {
    return { name: key[0], value: key[1] };
  });

  return (
    <Table>
      {convertedList.map((software) => {
        return <AvailableRow key={software.name} software={software} />;
      })}
    </Table>
  );
};

const AvailableRow = (props, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
  const { ram } = data;
  const { installed } = data.software;
  const { software } = props;
  const purchased = installed.includes(software.name);

  return (
    <Table.Row>
      <Table.Cell collapsible>
        <Box color="label">
          {software.name.replace(/^\w/, (c) => c.toUpperCase())}
        </Box>
      </Table.Cell>
      <Table.Cell collapsible>
        <Box color={ram < software.value && 'bad'} textAlign="right">
          {!purchased && software.value}{' '}
          <Icon
            color={purchased || ram >= software.value ? 'purple' : 'bad'}
            name={purchased ? 'check' : 'microchip'}
          />
        </Box>
      </Table.Cell>
      <Table.Cell collapsible>
        <Button
          fluid
          mb={0.5}
          disabled={ram < software.value || purchased}
          onClick={() => act('buy', { selection: software.name })}
          tooltip={SOFTWARE_DESC[software.name] || ''}>
          <Icon ml={1} mr={-2} name="download" />
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

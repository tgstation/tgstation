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
  value: [value: number];
};

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
            {tab === 2 && <DirectiveDisplay />}
            {tab === 3 && <InstalledDisplay />}
            {tab === 4 && <AvailableDisplay />}
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
        Directives
      </Tabs.Tab>
      <Tabs.Tab icon="list" onClick={() => tabHandler(3)} selected={tab === 3}>
        Installed
      </Tabs.Tab>
      <Tabs.Tab icon="list" onClick={() => tabHandler(4)} selected={tab === 4}>
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
    <Section fill>
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
          icon={getIconHelper(image)}
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
      <Stack.Item>
        <Section title="Logic Core">
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
  const [softwareSelected, setSoftwareSelected] = useSharedState(
    context,
    'software',
    ''
  );
  const setSoftwareHandler = (software: string) => {
    setSoftwareSelected(software);
  };

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <InstalledSoftware softwareHandler={setSoftwareHandler} />
      </Stack.Item>
      <Stack.Item grow={2}>
        <InstalledInfo software={softwareSelected} />
      </Stack.Item>
    </Stack>
  );
};

const InstalledSoftware = (props, context) => {
  const { data } = useBackend<PaiInterfaceData>(context);
  const { installed } = data.software;
  const { softwareHandler } = props;

  return (
    <Section fill scrollable title="Installed Software">
      {!installed.length ? (
        <NoticeBox>Nothing installed!</NoticeBox>
      ) : (
        installed.map((software, index) => {
          return (
            <Button key={software} onClick={() => softwareHandler(software)}>
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

const InstalledInfo = (props, context) => {
  const { act, data } = useBackend<PaiInterfaceData>(context);
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
          <Stack.Item>
            <SoftwareInfo software={software} />
          </Stack.Item>
          <Stack.Item>
            <SoftwareButtons software={software} />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const SoftwareInfo = (props) => {
  const { software } = props;

  switch (software) {
    case 'crew manifest':
      return 'A tool that allows you to view the crew manifest.';
    case 'digital messenger':
      return 'A tool that allows you to send messages to other crew members.';
    case 'atmospheric sensor':
      return 'A tool that allows you to analyze atmospheric contents.';
    case 'photography module':
      return 'A portable camera module.';
    case 'camera zoom':
      return 'A tool that allows you to zoom in on your camera.';
    case 'printer module':
      return 'A portable printer module for photographs.';
    case 'remote signaler':
      return 'A remote signalling device to transmit and receive codes.';
    case 'medical records':
      return 'A tool that allows you to view station medical records.';
    case 'security records':
      return 'A tool that allows you to view station security records, warrants.';
    case 'host scan':
      return 'A tool that scans the health data while held.';
    case 'medical HUD':
      return 'Allows you to view medical status using an overlay HUD.';
    case 'security HUD':
      return 'Allows you to view security records using an overlay HUD.';
    case 'loudness booster':
      return 'Synthesizes instruments, plays sounds and imported songs.';
    case 'newscaster':
      return 'A tool that allows you to broadcast news to other crew members.';
    case 'door jack':
      return 'A tool that allows you to open doors.';
    case 'encryption keys':
      return 'A tool that allows you to decrypt and speak on other radio frequencies.';
    case 'internal gps':
      return 'A tool that allows you to track your location.';
    case 'universal translator':
      return 'Translation module for non-common languages.';
    default:
      return 'No information available.';
  }
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
      <Table.Cell>
        <Box color="label">
          {software.name.replace(/^\w/, (c) => c.toUpperCase())}
        </Box>
      </Table.Cell>
      <Table.Cell width={8} />
      <Table.Cell>
        <Box color={ram < software.value && 'bad'} textAlign="right">
          {!purchased && software.value}{' '}
          <Icon
            color={purchased || !(ram < software.value) ? 'purple' : 'bad'}
            name="microchip"
          />
        </Box>
      </Table.Cell>

      <Table.Cell>
        <Button
          disabled={ram < software.value || purchased}
          onClick={() => act('buy', { selection: software.name })}
          tooltip={<SoftwareInfo software={software.name} />}>
          <Icon ml={1} name="download" />
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

const getIconHelper = (image: string) => {
  switch (image) {
    case 'angry':
      return 'angry';
    case 'cat':
      return 'cat';
    case 'extremely-happy':
      return 'grin-beam';
    case 'laugh':
      return 'grin-squint';
    case 'happy':
      return 'smile';
    case 'off':
      return 'power-off';
    case 'sad':
      return 'frown';
    case 'sunglasses':
      return 'sun';
    case 'what':
      return 'question';
    default:
      return 'meh';
  }
};

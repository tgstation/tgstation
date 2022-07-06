import { capitalize } from 'common/string';
import { useBackend, useLocalState } from 'tgui/backend';
import { Button, NoticeBox, Section, Stack } from 'tgui/components';
import { SOFTWARE_DESC } from '../constants';
import { Available, Data } from '../types';
import { RecordsDisplay } from './Records';

/** Renders two sections: A section of buttons and
 * another section that displays the selected installed
 * software info.
 */
export const InstalledDisplay = (props, context) => {
  const [installSelected, setInstallSelected] = useLocalState(
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

/** Iterates over installed software to render buttons. */
const InstalledSoftware = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { installed = [] } = data;
  const { onInstallClick } = props;

  return (
    <Section fill scrollable title="Installed Software">
      {!installed.length ? (
        <NoticeBox>Nothing installed!</NoticeBox>
      ) : (
        installed.map((software) => {
          return (
            <Button key={software} onClick={() => onInstallClick(software)}>
              {capitalize(software)}
            </Button>
          );
        })
      )}
    </Section>
  );
};

/** Software info for buttons clicked. */
const InstalledInfo = (props: { software: Available['name'] }) => {
  const { software } = props;

  /** Records get their own section here */
  if (software === 'medical records') {
    return <RecordsDisplay record_type="medical" />;
  } else if (software === 'security records') {
    return <RecordsDisplay record_type="security" />;
  } else {
    return (
      <Section
        fill
        scrollable
        title={!software ? 'Select a Program' : capitalize(software)}>
        {software && (
          <Stack fill vertical>
            <Stack.Item>{SOFTWARE_DESC[software] || ''}</Stack.Item>
            <Stack.Item grow>
              <SoftwareButtons software={software} />
            </Stack.Item>
          </Stack>
        )}
      </Section>
    );
  }
};

/** Once a software is selected, generates custom buttons or a default
 * power toggle.
 */
const SoftwareButtons = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { door_jack, languages, pda } = data;
  const { software = '' } = props;
  const actString: string = software?.toLowerCase().replace(/ /g, '_');

  switch (software) {
    case 'digital messenger':
      return (
        <>
          <Button
            icon="power-off"
            onClick={() => act('pda', { pda: 'power' })}
            selected={pda.power}>
            Power
          </Button>
          <Button
            icon="volume-mute"
            onClick={() => act('pda', { pda: 'silent' })}
            selected={pda.silent}>
            Silent
          </Button>
          <Button
            disabled={!pda.power}
            icon="envelope"
            onClick={() => act('pda', { pda: 'message' })}>
            Message
          </Button>
        </>
      );
    case 'door jack':
      return (
        <>
          <Button
            disabled={door_jack}
            icon="plug"
            onClick={() => act('door_jack', { jack: 'cable' })}>
            Extend Cable
          </Button>
          <Button
            color="bad"
            disabled={!door_jack}
            icon="door-open"
            onClick={() => act('door_jack', { jack: 'jack' })}>
            Hack Door
          </Button>
          <Button
            disabled={!door_jack}
            icon="unlink"
            onClick={() => act('door_jack', { jack: 'cancel' })}>
            Cancel
          </Button>
        </>
      );
    case 'host scan': {
      return (
        <>
          <Button
            icon="search"
            onClick={() => act('host_scan', { scan: 'scan' })}>
            Host Scan
          </Button>
          <Button
            icon="cog"
            onClick={() => act('host_scan', { scan: 'wounds' })}>
            Toggle Wounds
          </Button>
          <Button
            icon="cog"
            onClick={() => act('host_scan', { scan: 'limbs' })}>
            Toggle Limbs
          </Button>
        </>
      );
    }
    case 'universal translator':
      return (
        <Button
          icon="download"
          onClick={() => act(actString)}
          disabled={!!languages}>
          {!languages ? 'Install' : 'Installed'}
        </Button>
      );
    default:
      return (
        <Button
          icon="power-off"
          onClick={() => act(actString)}
          tooltip="Attempts to toggle the module's power.">
          Toggle
        </Button>
      );
  }
};

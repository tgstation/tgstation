import { capitalizeAny } from 'common/string';
import { useBackend, useLocalState } from 'tgui/backend';
import { Button, NoticeBox, Section, Stack } from 'tgui/components';
import { SOFTWARE_DESC } from '../constants';
import { Data } from '../types';
import { RecordsDisplay } from './Records';

/**
 * Renders two sections: A section of buttons and
 * another section that displays the selected installed
 * software info.
 */
export const InstalledDisplay = (props, context) => {
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <InstalledSoftware />
      </Stack.Item>
      <Stack.Item grow={2}>
        <InstalledInfo />
      </Stack.Item>
    </Stack>
  );
};

/** Iterates over installed software to render buttons. */
const InstalledSoftware = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { installed = [] } = data;
  const [currentSelection, setCurrentSelection] = useLocalState(
    context,
    'software',
    ''
  );

  return (
    <Section fill scrollable title="Installed Software">
      {!installed.length ? (
        <NoticeBox>Nothing installed!</NoticeBox>
      ) : (
        installed.map((software, index) => {
          return (
            <Button key={index} onClick={() => setCurrentSelection(software)}>
              {capitalizeAny(software)}
            </Button>
          );
        })
      )}
    </Section>
  );
};

/** Software info for buttons clicked. */
const InstalledInfo = (props, context) => {
  const [currentSelection, setCurrentSelection] = useLocalState(
    context,
    'software',
    ''
  );
  const title = !currentSelection
    ? 'Select a Program'
    : capitalizeAny(currentSelection);

  /** Records get their own section here */
  if (currentSelection === 'medical records') {
    return <RecordsDisplay record_type="medical" />;
  } else if (currentSelection === 'security records') {
    return <RecordsDisplay record_type="security" />;
  } else {
    return (
      <Section fill scrollable title={title}>
        {currentSelection && (
          <Stack fill vertical>
            <Stack.Item>{SOFTWARE_DESC[currentSelection]}</Stack.Item>
            <Stack.Item grow>
              <SoftwareButtons />
            </Stack.Item>
          </Stack>
        )}
      </Section>
    );
  }
};

/**
 * Once a software is selected, generates custom buttons or a default
 * power toggle.
 */
const SoftwareButtons = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { door_jack, languages } = data;
  const [currentSelection, setCurrentSelection] = useLocalState(
    context,
    'software',
    ''
  );

  switch (currentSelection) {
    case 'door jack':
      return (
        <>
          <Button
            disabled={door_jack}
            icon="plug"
            onClick={() => act(currentSelection, { jack: 'cable' })}>
            Extend Cable
          </Button>
          <Button
            color="bad"
            disabled={!door_jack}
            icon="door-open"
            onClick={() => act(currentSelection, { jack: 'jack' })}>
            Hack Door
          </Button>
          <Button
            disabled={!door_jack}
            icon="unlink"
            onClick={() => act(currentSelection, { jack: 'cancel' })}>
            Cancel
          </Button>
        </>
      );
    case 'universal translator':
      return (
        <Button
          icon="download"
          onClick={() => act(currentSelection)}
          disabled={!!languages}>
          {!languages ? 'Install' : 'Installed'}
        </Button>
      );
    default:
      return (
        <Button
          icon="power-off"
          onClick={() => act(currentSelection)}
          tooltip="Attempts to enable the module.">
          Toggle
        </Button>
      );
  }
};

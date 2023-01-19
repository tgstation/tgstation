import { useBackend, useLocalState } from 'tgui/backend';
import { PRINTOUT, SecureData } from './types';
import { Box, Button, Input, Section, Stack } from 'tgui/components';
import { getCurrentRecord } from './helpers';

/** Handles printing posters and rapsheets */
export const RecordPrint = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <> </>;

  const { crimes, name, ref } = foundRecord;
  const innocent = !crimes?.length;
  const { act } = useBackend<SecureData>(context);

  const [open, setOpen] = useLocalState<boolean>(context, 'printOpen', true);
  const [alias, setAlias] = useLocalState<string>(context, 'printAlias', name);

  const [printType, setPrintType] = useLocalState<PRINTOUT>(
    context,
    'printType',
    PRINTOUT.Missing
  );
  const [header, setHeader] = useLocalState<string>(context, 'printHeader', '');
  const [description, setDescription] = useLocalState<string>(
    context,
    'printDesc',
    ''
  );

  /** Prints the record and resets. */
  const printSheet = () => {
    act('print_record', {
      alias: alias,
      desc: description,
      head: header,
      ref: ref,
      type: printType,
    });
    reset();
  };

  /** Close everything and reset to blank. */
  const reset = () => {
    setAlias('');
    setHeader('');
    setDescription('');
    setPrintType(PRINTOUT.Missing);
    setOpen(false);
  };

  /** Clears the value and sets it to default. */
  const clearField = (field: string) => {
    switch (field) {
      case 'alias':
        setAlias(name);
        break;
      case 'header':
        setHeader(getDefaultHeader(printType));
        break;
      case 'description':
        setDescription(getDefaultDescription(name, printType));
        break;
    }
  };

  /** If they have the fields defaulted to a specific type, change the message */
  const swapTabs = (tab: PRINTOUT) => {
    if (description === getDefaultDescription(name, printType)) {
      setDescription(getDefaultDescription(name, tab));
    }
    if (header === getDefaultHeader(printType)) {
      setHeader(getDefaultHeader(tab));
    }
    setPrintType(tab);
  };

  return (
    <Section
      buttons={
        <>
          <Button
            icon="question"
            onClick={() => swapTabs(PRINTOUT.Missing)}
            selected={printType === PRINTOUT.Missing}
            tooltip="Prints a poster with mugshot and description."
            tooltipPosition="bottom">
            Missing
          </Button>
          <Button
            disabled={innocent}
            icon="file-alt"
            onClick={() => swapTabs(PRINTOUT.Rapsheet)}
            selected={printType === PRINTOUT.Rapsheet}
            tooltip={`Prints a standard paper with the record on it. ${
              innocent && ' (Requires crimes)'
            }`}
            tooltipPosition="bottom">
            Rapsheet
          </Button>
          <Button
            disabled={innocent}
            icon="handcuffs"
            onClick={() => swapTabs(PRINTOUT.Wanted)}
            selected={printType === PRINTOUT.Wanted}
            tooltip={`Prints a poster with mugshot and crimes.${
              innocent && ' (Requires crimes)'
            }`}
            tooltipPosition="bottom">
            Wanted
          </Button>
          <Button color="bad" icon="times" onClick={reset} />
        </>
      }
      fill
      scrollable
      title="Print Record">
      <Stack color="label" fill vertical>
        <Stack.Item>
          <Box>Enter a Header:</Box>
          <Input
            onChange={(event, value) => setHeader(value)}
            maxLength={7}
            value={header}
          />
          <Button
            icon="sync"
            onClick={() => clearField('header')}
            tooltip="Reset"
          />
        </Stack.Item>
        <Stack.Item>
          <Box>Enter an Alias:</Box>
          <Input
            onChange={(event, value) => setAlias(value)}
            maxLength={42}
            value={alias}
            width="55%"
          />
          <Button
            icon="sync"
            onClick={() => clearField('alias')}
            tooltip="Reset"
          />
        </Stack.Item>
        <Stack.Item>
          <Box>Enter a Description:</Box>
          <Stack fill>
            <Stack.Item grow>
              <Input
                fluid
                maxLength={150}
                onChange={(event, value) => setDescription(value)}
                value={description}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="sync"
                onClick={() => clearField('description')}
                tooltip="Reset"
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item mt={2}>
          <Box align="right">
            <Button color="bad" onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button color="good" onClick={printSheet}>
              Print
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Returns a string header based on print type */
const getDefaultHeader = (printType: PRINTOUT) => {
  switch (printType) {
    case PRINTOUT.Rapsheet:
      return 'Record';
    case PRINTOUT.Wanted:
      return 'WANTED';
    case PRINTOUT.Missing:
      return 'MISSING';
  }
};

/** Returns a string description based on print type */
const getDefaultDescription = (name: string, printType: PRINTOUT) => {
  switch (printType) {
    case PRINTOUT.Rapsheet:
      return `A standard security record for ${name}.`;
    case PRINTOUT.Wanted:
      return `A poster declaring ${name} to be a wanted criminal, wanted by Nanotrasen. Report any sightings to security immediately.`;
    case PRINTOUT.Missing:
      return `A poster declaring ${name} to be a missing individual, missed by Nanotrasen. Report any sightings to security immediately.`;
  }
};

import { useState } from 'react';
import { useBackend, useLocalState } from 'tgui/backend';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import {
  getDefaultPrintDescription,
  getDefaultPrintHeader,
  getSecurityRecord,
} from './helpers';
import { PRINTOUT, SecurityRecordsData } from './types';

/** Handles printing posters and rapsheets */
export const RecordPrint = (props) => {
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return <> </>;

  const { crew_ref, crimes, name } = foundRecord;
  const innocent = !crimes?.length;
  const { act } = useBackend<SecurityRecordsData>();

  const [open, setOpen] = useLocalState('printOpen', true);
  const [alias, setAlias] = useState(name);

  const [printType, setPrintType] = useState(PRINTOUT.Missing);
  const [header, setHeader] = useState('');
  const [description, setDescription] = useState('');

  /** Prints the record and resets. */
  const printSheet = () => {
    act('print_record', {
      alias: alias,
      crew_ref: crew_ref,
      desc: description,
      head: header,
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
        setHeader(getDefaultPrintHeader(printType));
        break;
      case 'description':
        setDescription(getDefaultPrintDescription(name, printType));
        break;
    }
  };

  /** If they have the fields defaulted to a specific type, change the message */
  const swapTabs = (tab: PRINTOUT) => {
    if (description === getDefaultPrintDescription(name, printType)) {
      setDescription(getDefaultPrintDescription(name, tab));
    }
    if (header === getDefaultPrintHeader(printType)) {
      setHeader(getDefaultPrintHeader(tab));
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
            tooltipPosition="bottom"
          >
            Missing
          </Button>
          <Button
            disabled={innocent}
            icon="file-alt"
            onClick={() => swapTabs(PRINTOUT.Rapsheet)}
            selected={printType === PRINTOUT.Rapsheet}
            tooltip={`Prints a standard paper with the record on it.${
              innocent ? ' (Requires crimes)' : ''
            }`}
            tooltipPosition="bottom"
          >
            Rapsheet
          </Button>
          <Button
            disabled={innocent}
            icon="handcuffs"
            onClick={() => swapTabs(PRINTOUT.Wanted)}
            selected={printType === PRINTOUT.Wanted}
            tooltip={`Prints a poster with mugshot and crimes.${
              innocent ? ' (Requires crimes)' : ''
            }`}
            tooltipPosition="bottom"
          >
            Wanted
          </Button>
          <Button color="bad" icon="times" onClick={reset} />
        </>
      }
      fill
      scrollable
      title="Print Record"
    >
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

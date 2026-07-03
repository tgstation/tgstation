import { useState } from 'react';
import { useBackend, useLocalState } from 'tgui/backend';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import {
  getDefaultPrintDescription,
  getDefaultPrintHeader,
  getSecurityRecord,
} from './helpers';
import { PRINTOUT, type SecurityRecordsData } from './types';

/** Handles printing posters and rapsheets */
export const RecordPrint = (props) => {
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;

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
            tooltip="Печатает постер с фото и описанием."
            tooltipPosition="bottom"
          >
            Пропажа
          </Button>
          <Button
            disabled={innocent}
            icon="file-alt"
            onClick={() => swapTabs(PRINTOUT.Rapsheet)}
            selected={printType === PRINTOUT.Rapsheet}
            tooltip={`Печатает бумагу с записями охраны.${
              innocent ? ' (Укажите преступления)' : ''
            }`}
            tooltipPosition="bottom"
          >
            Уголовное дело
          </Button>
          <Button
            disabled={innocent}
            icon="handcuffs"
            onClick={() => swapTabs(PRINTOUT.Wanted)}
            selected={printType === PRINTOUT.Wanted}
            tooltip={`Печатает постер с фото и преступлениями.${
              innocent ? ' (Укажите преступления)' : ''
            }`}
            tooltipPosition="bottom"
          >
            Розыск
          </Button>
          <Button color="bad" icon="times" onClick={reset} />
        </>
      }
      fill
      scrollable
      title="Печать записи"
    >
      <Stack color="label" fill vertical>
        <Stack.Item>
          <Box>Введите заголовок:</Box>
          <Input onChange={setHeader} maxLength={7} value={header} />
          <Button
            icon="sync"
            onClick={() => clearField('header')}
            tooltip="Сбросить"
          />
        </Stack.Item>
        <Stack.Item>
          <Box>Введите псевдоним:</Box>
          <Input onChange={setAlias} maxLength={42} value={alias} width="55%" />
          <Button
            icon="sync"
            onClick={() => clearField('alias')}
            tooltip="Сбросить"
          />
        </Stack.Item>
        <Stack.Item>
          <Box>Введите описание:</Box>
          <Stack fill>
            <Stack.Item grow>
              <Input
                fluid
                maxLength={150}
                onChange={setDescription}
                value={description}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="sync"
                onClick={() => clearField('description')}
                tooltip="Сбросить"
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item mt={2}>
          <Box align="right">
            <Button color="bad" onClick={() => setOpen(false)}>
              Отмена
            </Button>
            <Button color="good" onClick={printSheet}>
              Распечатать
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import { useBackend, useLocalState } from 'tgui/backend';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { ReverseJobsRu } from '../../bandastation/ru_jobs'; // BANDASTATION EDIT
import { JOB2ICON } from '../common/JobToIcon';
import { isRecordMatch } from '../SecurityRecords/helpers';
import type { MedicalRecord, MedicalRecordData } from './types';

/** Displays all found records. */
export const MedicalRecordTabs = (props) => {
  const { act, data } = useBackend<MedicalRecordData>();
  const { records = [], station_z } = data;

  const errorMessage = !records.length
    ? 'Записи не найдены.'
    : 'Нет совпадений. Скорректируйте поиск.';

  const [search, setSearch] = useState('');

  const sorted: MedicalRecord[] = sortBy(
    filter(records, (record) => isRecordMatch(record, search)),
    [(record) => record.name?.toLowerCase()],
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          fluid
          onChange={setSearch}
          placeholder="Имя/Должность/ДНК"
          expensive
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Tabs vertical>
            {!sorted.length ? (
              <NoticeBox>{errorMessage}</NoticeBox>
            ) : (
              sorted.map((record, index) => (
                <CrewTab key={index} record={record} />
              ))
            )}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item align="center">
        <Stack fill>
          <Stack.Item>
            <Button
              disabled
              icon="plus"
              tooltip="Вставьте фотографию метр-на-метр в терминал, чтобы добавить запись. Вам не нужно включать экран."
            >
              Создать
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              content="Очистить"
              icon="trash"
              disabled={!station_z}
              onClick={() => act('purge_records')}
              tooltip="Очищает всю базу данных."
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

/** Individual crew tab */
const CrewTab = (props: { record: MedicalRecord }) => {
  const [selectedRecord, setSelectedRecord] = useLocalState<
    MedicalRecord | undefined
  >('medicalRecord', undefined);

  const { act, data } = useBackend<MedicalRecordData>();
  const { assigned_view } = data;
  const { record } = props;
  const { crew_ref, name, trim } = record;

  /** Sets the record to preview */
  const selectRecord = (record: MedicalRecord) => {
    if (selectedRecord?.crew_ref === crew_ref) {
      setSelectedRecord(undefined);
    } else {
      // GOD, I REALLY HATE IT!
      // THIS FUCKING HACK NEEDED CAUSE "WINSET MAP"
      // MAKING UI DISAPPEAR, AND WE NEED RE-RENDER SHIT
      // AFTER BYOND DONE MAKING THEIR SHIT
      // Anyway... that's better than hack before
      if (selectedRecord === undefined) {
        setTimeout(() => {
          act('view_record', {
            assigned_view: assigned_view,
            crew_ref: crew_ref,
          });
        });
      }
      setSelectedRecord(record);
      act('view_record', { assigned_view: assigned_view, crew_ref: crew_ref });
    }
  };

  return (
    <Tabs.Tab
      className="candystripe"
      onClick={() => selectRecord(record)}
      selected={selectedRecord?.crew_ref === crew_ref}
    >
      <Box>
        <Icon name={JOB2ICON[ReverseJobsRu(trim)] || 'question'} /> {name}
      </Box>
    </Tabs.Tab>
  );
};

import { useState } from 'react';
import { Box, Icon, Input, Section } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

export const NtosRecords = (props) => {
  const { act, data } = useBackend();
  const [searchTerm, setSearchTerm] = useState('');
  const { mode, records } = data;

  const isMatchingSearchTerms = createSearch(searchTerm);

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Section textAlign="center">
          КАДРОВЫЕ ДОКУМЕНТЫ NANOTRASEN (СЕКРЕТНО)
        </Section>
        <Section>
          <Input
            placeholder="Фильтровать результаты..."
            value={searchTerm}
            fluid
            textAlign="center"
            onChange={setSearchTerm}
            expensive
          />
        </Section>
        {mode === 'security' &&
          records.map((record) => (
            <Section
              key={record.id}
              hidden={
                !(
                  searchTerm === '' ||
                  isMatchingSearchTerms(
                    record.name +
                      ' ' +
                      record.rank +
                      ' ' +
                      record.species +
                      ' ' +
                      record.gender +
                      ' ' +
                      record.age +
                      ' ' +
                      record.fingerprint,
                  )
                )
              }
            >
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Должность: {record.rank}
              <br />
              Вид: {record.species}
              <br />
              Пол: {record.gender}
              <br />
              Возраст: {record.age}
              <br />
              Хэш отпечатков пальцев: {record.fingerprint}
              <br />
              <br />
              Криминальный статус: {record.wanted || 'DELETED'}
            </Section>
          ))}
        {mode === 'medical' &&
          records.map((record) => (
            <Section
              key={record.id}
              hidden={
                !(
                  searchTerm === '' ||
                  isMatchingSearchTerms(
                    record.name +
                      ' ' +
                      record.bloodtype +
                      ' ' +
                      record.mental_status +
                      ' ' +
                      record.physical_status,
                  )
                )
              }
            >
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Тип крови: {record.bloodtype}
              <br />
              Незначительные нарушения: {record.mi_dis}
              <br />
              Основные нарушения: {record.ma_dis}
              <br />
              <br />
              Заметки: {record.notes}
              <br />
              Заметки. Продолжение: {record.cnotes}
            </Section>
          ))}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

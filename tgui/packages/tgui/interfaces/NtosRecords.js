import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Icon, Input, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosRecords = (props, context) => {
  const { act, data } = useBackend(context);
  const [searchTerm, setSearchTerm] = useLocalState(context, 'search', '');
  const { mode, records } = data;

  const isMatchingSearchTerms = createSearch(searchTerm);

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Section textAlign="center">
          NANOTRASEN PERSONNEL RECORDS (CLASSIFIED)
        </Section>
        <Section>
          <Input
            placeholder={'Filter results...'}
            value={searchTerm}
            fluid
            textAlign="center"
            onInput={(e, value) => setSearchTerm(value)}
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
                      record.fingerprint
                  )
                )
              }>
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Rank: {record.rank}
              <br />
              Species: {record.species}
              <br />
              Gender: {record.gender}
              <br />
              Age: {record.age}
              <br />
              Fingerprint Hash: {record.fingerprint}
              <br />
              <br />
              Criminal Status: {record.wanted || 'DELETED'}
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
                      record.physical_status
                  )
                )
              }>
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Bloodtype: {record.bloodtype}
              <br />
              Minor Disabilities: {record.mi_dis}
              <br />
              Major Disabilities: {record.ma_dis}
              <br />
              <br />
              Notes: {record.notes}
              <br />
              Notes Contd: {record.cnotes}
            </Section>
          ))}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

import { useBackend } from 'tgui/backend';
import { Box, Section, Stack } from 'tgui-core/components';
import { type BookEntry, BookUI, type TOCEntry } from './common/PaginatedBook';
import '../styles/interfaces/DeForestLogo.scss';

type Trauma = {
  full_name: string;
  scan_name: string;
  desc: string;
  symptoms: string;
  id: string;
};

type TraumaData = {
  traumas: Trauma[];
};

function checkIdenticalTraumaNames(trauma: BookEntry<Trauma>) {
  return trauma.full_name.toLowerCase() === trauma.scan_name.toLowerCase();
}

function estimateHeight(entry: BookEntry<Trauma>) {
  const title_height = 40;
  const subttitle_height = checkIdenticalTraumaNames(entry) ? 0 : 20;
  const desc_height = Math.ceil(entry.desc.length / 50) * 12.5;
  const symptoms_height = Math.ceil(entry.symptoms.length / 50) * 12.5;
  const extra_spacing = 40;

  return (
    title_height +
    subttitle_height +
    desc_height +
    symptoms_height +
    extra_spacing
  );
}

function renderDSMEntry(entry: BookEntry<Trauma>) {
  return (
    <Section
      width="100%"
      fitted
      pt={0.2}
      pl={1}
      title={
        <Stack vertical>
          <Stack.Item>{entry.full_name}</Stack.Item>
          {!checkIdenticalTraumaNames(entry) && (
            <Stack.Item fontSize="10px">...aka "{entry.scan_name}"</Stack.Item>
          )}
        </Stack>
      }
    >
      <Stack vertical backgroundColor="white" p={1} width="100%">
        <Stack.Item>
          <Box inline color="label">
            Description:
          </Box>{' '}
          {entry.desc}
        </Stack.Item>
        <Stack.Item>
          <Box inline color="label">
            Diagnosis:
          </Box>{' '}
          {entry.symptoms}
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function renderTOCEntry(tocentry: TOCEntry<Trauma>) {
  return (
    <Stack align="end">
      <Stack.Item>{tocentry.entry.full_name}</Stack.Item>
      {!checkIdenticalTraumaNames(tocentry.entry) && (
        <Stack.Item
          fontSize="10px"
          italic
          maxWidth={`${(50 - tocentry.entry.full_name.length) * 5}px`}
          style={{
            overflow: 'hidden',
            whiteSpace: 'nowrap',
            textOverflow: 'ellipsis',
          }}
        >
          ({tocentry.entry.scan_name})
        </Stack.Item>
      )}
    </Stack>
  );
}

const blankDSMPage = (
  <Stack.Item textAlign="center" grow className="deforest_logo" />
);

export const DSMBook = () => {
  const { data } = useBackend<TraumaData>();
  const { traumas } = data;

  const traumaEntries: BookEntry<Trauma>[] = traumas
    .map((trauma) => ({
      id: trauma.id,
      full_name: trauma.full_name,
      scan_name: trauma.scan_name,
      desc: trauma.desc,
      symptoms: trauma.symptoms,
    }))
    .sort((a, b) => (a.full_name > b.full_name ? 1 : -1));

  return (
    <BookUI
      bookData={traumaEntries}
      title="SDSM-35"
      estimateHeight={estimateHeight}
      renderEntry={renderDSMEntry}
      renderTOCEntry={renderTOCEntry}
      blankPage={blankDSMPage}
    />
  );
};

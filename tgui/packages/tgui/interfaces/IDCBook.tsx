import { useBackend } from 'tgui/backend';
import { Box, Section, Stack } from 'tgui-core/components';
import { type BookEntry, BookUI, type TOCEntry } from './common/PaginatedBook';
import '../styles/interfaces/DeForestLogo.scss';

type Disease = {
  name: string; // used by symptoms and diseases - name of the disease or symptom
  desc: string; // used by symptoms and diseases - description of the disease or symptom
  form: string; // used by symptoms and diseases - something like symptom, virus, bacteria, etc
  agent: string; // used by diseases - the agent that causes the disease, like a virus or bacteria name
  spread_by: string; // used by diseases - how the disease is spread, like "Airborne" or "Contact"
  cured_by: string | null; // used by symptoms and diseases - how the disease or symptom is cured, like a medicine name or "Unknown"
  illness: string; // used by symptoms - the common illness associated with the symptom, like "Flu" for "Fever"
  id: string;
};

type DiseaseData = {
  diseases: Disease[];
};

function isSymptom(entry: BookEntry<Disease>) {
  return entry.form.toLowerCase() === 'symptom';
}

function formToColor(form: string) {
  switch (form.toLowerCase()) {
    case 'symptom':
      return 'lightgreen';
    case 'condition':
    case 'infection':
    case 'parasite':
      return 'lightsalmon';
    case 'virus':
    case 'bacteria':
    case 'fungus':
      return 'lightblue';
    default:
      return 'white';
  }
}

function formatSpreadBy(spread_by: string) {
  switch (spread_by.toLowerCase()) {
    case 'airborne':
      return (
        <Stack align="end">
          <Stack.Item>Airborne</Stack.Item>
          <Stack.Item fontSize="10px" pb={0.2}>
            (e.g. coughing, sneezing)
          </Stack.Item>
        </Stack>
      );
    case 'skin contact':
    case 'contact':
      return (
        <Stack align="end">
          <Stack.Item>Contact</Stack.Item>
          <Stack.Item fontSize="10px" pb={0.2}>
            (e.g. touching infected persons)
          </Stack.Item>
        </Stack>
      );
    case 'fluid contact':
      return (
        <Stack align="end">
          <Stack.Item>Liquids</Stack.Item>
          <Stack.Item fontSize="10px" pb={0.2}>
            (e.g. touching contaminated fluids)
          </Stack.Item>
        </Stack>
      );
    case 'blood':
      return (
        <Stack align="end">
          <Stack.Item>Blood</Stack.Item>
          <Stack.Item fontSize="10px" pb={0.2}>
            (e.g. tranfusion of infected blood)
          </Stack.Item>
        </Stack>
      );
    case 'none':
      return (
        <Stack align="end">
          <Stack.Item>None</Stack.Item>
          <Stack.Item fontSize="10px" pb={0.2}>
            (non-contagious)
          </Stack.Item>
        </Stack>
      );
    default:
      return spread_by;
  }
}

function estimateHeight(entry: BookEntry<Disease>) {
  const title_height = 40;
  const extra_spacing = 40;
  if (isSymptom(entry)) {
    const desc_height = Math.ceil(entry.desc.length / 50) * 14;
    const illness_height = entry.illness !== 'Unidentified' ? 10 : 0;
    const cured_by_height = 10;

    return (
      title_height +
      desc_height +
      illness_height +
      cured_by_height +
      extra_spacing
    );
  }

  const desc_height = Math.ceil(entry.desc.length / 50) * 14;
  const agent_height = 15;
  const spread_by_height = 15;
  const cured_by_height = 15;

  return (
    title_height +
    desc_height +
    agent_height +
    spread_by_height +
    cured_by_height +
    extra_spacing
  );
}

function renderDSMEntry(entry: BookEntry<Disease>) {
  return (
    <Section
      width="100%"
      fitted
      pt={0.2}
      pl={1}
      title={
        <Stack align="end">
          <Stack.Item grow>{entry.name}</Stack.Item>
          <Stack.Item italic fontSize="10px" pb={0.2} pr={0.5}>
            ({entry.form})
          </Stack.Item>
        </Stack>
      }
    >
      <Stack vertical backgroundColor={formToColor(entry.form)} p={1}>
        {isSymptom(entry) ? (
          <>
            <Stack.Item>
              <Box inline color="label">
                Description:
              </Box>{' '}
              {entry.desc}
            </Stack.Item>
            {entry.illness !== 'Unidentified' && (
              <Stack.Item>
                <Box inline color="label">
                  Common associated illness:
                </Box>{' '}
                "{entry.illness}"
              </Stack.Item>
            )}
            {!!entry.cured_by && (
              <Stack.Item>
                <Box inline color="label">
                  Common cures:
                </Box>{' '}
                {entry.cured_by}
              </Stack.Item>
            )}
          </>
        ) : (
          <>
            <Stack.Item>
              <Box inline color="label">
                Agent:
              </Box>{' '}
              {entry.agent}
            </Stack.Item>
            <Stack.Item>
              <Box inline color="label">
                Description:
              </Box>{' '}
              {entry.desc}
            </Stack.Item>
            <Stack.Item>
              <Box inline color="label">
                Spread By:
              </Box>{' '}
              <Box inline>{formatSpreadBy(entry.spread_by)}</Box>
            </Stack.Item>
            <Stack.Item>
              <Box inline color="label">
                Cured By:
              </Box>{' '}
              {entry.cured_by}
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
}

function renderTOCEntry(tocentry: TOCEntry<Disease>) {
  return (
    <Stack align="end">
      <Stack.Item>{tocentry.entry.name}</Stack.Item>
      <Stack.Item
        fontSize="10px"
        italic
        maxWidth={`${(50 - tocentry.entry.name.length) * 5}px`}
        style={{
          overflow: 'hidden',
          whiteSpace: 'nowrap',
          textOverflow: 'ellipsis',
        }}
        pb={0.2}
      >
        ({tocentry.entry.form})
      </Stack.Item>
    </Stack>
  );
}

const blankIDCPage = (
  <Stack.Item textAlign="center" grow className="deforest_logo" />
);

export const IDCBook = () => {
  const { data } = useBackend<DiseaseData>();
  const { diseases } = data;

  const diseaseEntries: BookEntry<Disease>[] = diseases
    .map((disease) => ({
      id: disease.id,
      name: disease.name,
      desc: disease.desc,
      form: disease.form,
      agent: disease.agent,
      spread_by: disease.spread_by,
      cured_by: disease.cured_by,
      illness: disease.illness,
    }))
    .sort((a, b) =>
      a.form > b.form ? 1 : a.form < b.form ? -1 : a.name > b.name ? 1 : -1,
    );

  return (
    <BookUI
      bookData={diseaseEntries}
      title="IDC-27"
      estimateHeight={estimateHeight}
      renderEntry={renderDSMEntry}
      renderTOCEntry={renderTOCEntry}
      blankPage={blankIDCPage}
    />
  );
};

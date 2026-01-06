import { capitalize } from 'es-toolkit';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Section, Stack } from 'tgui-core/components';
import { Window } from '../layouts';

type Trauma = {
  full_name: string;
  scan_name: string;
  desc: string;
  symptoms: string;
  id: string;
  page: number;
};

type TraumaPage = Trauma & { page: number };

type TOCEntry = {
  full_name: string;
  scan_name: string;
  id: string;
  displayed_page: number;
  entry_page: number;
};

type TraumaData = {
  traumas: Trauma[];
};

// fits as many traumas as possible on a page
function getTOCWithPages(traumas: Trauma[], windowheight: number) {
  const page_height = windowheight - 50;
  const pages: TOCEntry[] = [];
  let current_page = 1;
  let current_page_height = 0;

  for (const trauma of traumas) {
    // estimate height of toc entry
    const estimated_height = 30;

    if (current_page_height + estimated_height > page_height) {
      // move to next page
      current_page += 1;
      current_page_height = 0;
    }

    const pageentry: TOCEntry = {
      full_name: trauma.full_name,
      scan_name: trauma.scan_name,
      id: trauma.id,
      displayed_page: current_page,
      entry_page: -1, // to be filled later
    };

    pages.push(pageentry);

    current_page_height += estimated_height;
  }

  return pages;
}

function getTraumasWithPages(
  traumas: Trauma[],
  windowheight: number,
  start_page: number,
) {
  const page_height = windowheight - 50;
  const pages: TraumaPage[] = [];
  let current_page = start_page;
  let current_page_height = 0;

  for (const trauma of traumas) {
    // estimate height of trauma entry
    const title_height = 40;
    const subttitle_height = 20;
    const desc_height = Math.ceil(trauma.desc.length / 50) * 12.5;
    const symptoms_height = Math.ceil(trauma.symptoms.length / 50) * 12.5;
    const extra_spacing = 30;

    const estimated_height =
      title_height +
      subttitle_height +
      desc_height +
      symptoms_height +
      extra_spacing;

    if (current_page_height + estimated_height > page_height) {
      // move to next page
      current_page += 1;
      current_page_height = 0;
    }

    const pageentry: TraumaPage = {
      ...trauma,
      page: current_page,
    };

    pages.push(pageentry);

    current_page_height += estimated_height;
  }

  return pages;
}

const DSMEntryComponent = (props: { trauma: Trauma }) => {
  const { trauma } = props;

  return (
    <Section
      fitted
      title={
        <Stack vertical>
          <Stack.Item>{trauma.full_name}</Stack.Item>
          <Stack.Item fontSize="10px">
            ...aka "{capitalize(trauma.scan_name)}"
          </Stack.Item>
        </Stack>
      }
    >
      <Stack vertical backgroundColor="white" p={1}>
        <Stack.Item>
          <Box inline color="label">
            Description:
          </Box>{' '}
          {trauma.desc}
        </Stack.Item>
        <Stack.Item>
          <Box inline color="label">
            Diagnosis:
          </Box>{' '}
          {trauma.symptoms}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type TocEntryComponentProps = {
  entry: TOCEntry;
  setPage: (page: number) => void;
};

const TOCEntryComponent = (props: TocEntryComponentProps) => {
  const { entry, setPage } = props;

  return (
    <Stack textAlign="center" fontSize="13px">
      <Stack.Item>
        <Stack align="end">
          <Stack.Item>{entry.full_name}</Stack.Item>
          <Stack.Item
            fontSize="10px"
            italic
            maxWidth={`${(50 - entry.full_name.length) * 5}px`}
            style={{
              overflow: 'hidden',
              whiteSpace: 'nowrap',
              textOverflow: 'ellipsis',
            }}
          >
            ({entry.scan_name})
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Box
          height="50%"
          style={{
            borderBottom: '2px dotted rgba(255, 255, 255)',
            borderColor: 'black',
          }}
        />
      </Stack.Item>
      <Stack.Item width="10%">
        <Button
          fluid
          onClick={() => setPage(entry.entry_page - (entry.entry_page % 2))}
        >
          {entry.entry_page}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

type PageTurnProps = {
  page: number;
  setPage: (page: number) => void;
  title?: string;
  maxPage: number;
};

const PageTurn = (props: PageTurnProps) => {
  const { page, setPage, title, maxPage } = props;
  const { act } = useBackend();

  return (
    <Stack>
      <Stack.Item>
        <Button
          icon="angles-left"
          onClick={() => {
            setPage(1);
            act('play_flip_sound');
          }}
          fluid
          disabled={page <= 1}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="angle-left"
          onClick={() => {
            setPage(page - 2);
            act('play_flip_sound');
          }}
          fluid
          disabled={page <= 1}
        />
      </Stack.Item>
      <Stack.Item textAlign="center" grow>
        <Stack fill>
          <Stack.Item grow bold>
            {page}
          </Stack.Item>
          <Stack.Item color="label">{title}</Stack.Item>
          <Stack.Item grow bold>
            {page + 1}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="angle-right"
          onClick={() => {
            setPage(page + 2);
            act('play_flip_sound');
          }}
          fluid
          disabled={page + 1 >= maxPage}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="angles-right"
          onClick={() => {
            setPage(maxPage - (maxPage % 2));
            act('play_flip_sound');
          }}
          fluid
          disabled={page + 1 >= maxPage}
        />
      </Stack.Item>
    </Stack>
  );
};

type FakePageProps = {
  tocDisplay?: TOCEntry[];
  traumaDisplay?: Trauma[];
  setPage: (page: number) => void;
};

const FakePage = (props: FakePageProps) => {
  const { tocDisplay, traumaDisplay, setPage } = props;

  return (
    <Section fill>
      <Stack vertical>
        {tocDisplay?.map((entry) => (
          <Stack.Item key={entry.id}>
            <TOCEntryComponent entry={entry} setPage={setPage} />
          </Stack.Item>
        ))}
        {traumaDisplay?.map((trauma) => (
          <Stack.Item key={trauma.id}>
            <DSMEntryComponent trauma={trauma} />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

type FakePagesProps = {
  tocDisplay?: TOCEntry[];
  traumaDisplay?: Trauma[];
  page: number;
  setPage: (page: number) => void;
};

const FakePages = (props: FakePagesProps) => {
  const { tocDisplay, traumaDisplay, page, setPage } = props;

  const leftTOC = tocDisplay?.filter((entry) => entry.displayed_page === page);
  const rightTOC = tocDisplay?.filter(
    (entry) => entry.displayed_page === page + 1,
  );

  const leftTrauma = traumaDisplay?.filter((trauma) => trauma.page === page);
  const rightTrauma = traumaDisplay?.filter(
    (trauma) => trauma.page === page + 1,
  );

  return (
    <Stack fill>
      <Stack.Item grow>
        <FakePage
          tocDisplay={leftTOC}
          traumaDisplay={leftTrauma}
          setPage={setPage}
        />
      </Stack.Item>
      <Stack.Item grow>
        <FakePage
          tocDisplay={rightTOC}
          traumaDisplay={rightTrauma}
          setPage={setPage}
        />
      </Stack.Item>
    </Stack>
  );
};

export const DSMBook = () => {
  const { data } = useBackend<TraumaData>();
  const { traumas } = data;

  // abc it up
  const traumasSorted = [...traumas].sort((a, b) =>
    a.full_name > b.full_name ? 1 : -1,
  );

  const windowheight = 565; // used in measurements below
  const allTOCWithPages = getTOCWithPages(traumasSorted, windowheight);

  // determine what page toc ends and traumas begin on
  let finalTOCPage = allTOCWithPages.reduce(
    (maxpage, entry) => Math.max(maxpage, entry.displayed_page),
    1,
  );

  // if final toc page is odd, make it even, so traumas start on the left
  if (finalTOCPage % 2 !== 0) {
    finalTOCPage += 2;
  }

  const allTraumaWithPages = getTraumasWithPages(
    traumasSorted,
    windowheight,
    finalTOCPage + 1,
  );

  // determine final page number for each TOC entry
  for (const trauma of traumas) {
    const traumaPage = allTraumaWithPages.find((t) => t.id === trauma.id);
    const tocEntry = allTOCWithPages.find((e) => e.id === trauma.id);
    if (traumaPage && tocEntry) {
      tocEntry.entry_page = traumaPage.page;
    }
  }

  const lastPage = allTraumaWithPages.reduce(
    (maxpage, trauma) => Math.max(maxpage, trauma.page),
    finalTOCPage,
  );

  // two pages are shown at once, so front page is 1+2
  const [page, setPage] = useState(1);

  return (
    <Window
      height={windowheight}
      width={765}
      title="SDSM-35"
      theme="ntos_lightmode"
    >
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <PageTurn
                page={page}
                setPage={setPage}
                maxPage={lastPage}
                title={page <= finalTOCPage ? `Table of Contents` : `SDSM 35`}
              />
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <FakePages
              tocDisplay={allTOCWithPages}
              traumaDisplay={allTraumaWithPages}
              page={page}
              setPage={setPage}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

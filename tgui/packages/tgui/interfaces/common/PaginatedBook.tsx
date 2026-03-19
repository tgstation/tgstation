import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Section, Stack } from 'tgui-core/components';
import { Window } from '../../layouts';

export type BookEntry<Type> = {
  id: string;
} & Type;

export type TOCEntry<Type> = {
  entry: BookEntry<Type>;
  displayedPage: number;
  entryPage: number;
};

type PageEntry<Type> = BookEntry<Type> & {
  page: number;
};

function getTOCWithPages<Type>(
  entries: BookEntry<Type>[],
  windowHeight: number,
) {
  const pageHeight = windowHeight - 50;
  const pages: TOCEntry<Type>[] = [];
  let currentPage = 1;
  let currentPageHeight = 0;

  for (const entry of entries) {
    const estimatedHeight = 30;

    if (currentPageHeight + estimatedHeight > pageHeight) {
      currentPage += 1;
      currentPageHeight = 0;
    }

    pages.push({
      entry,
      displayedPage: currentPage,
      entryPage: -1,
    });

    currentPageHeight += estimatedHeight;
  }

  return pages;
}

function getEntriesWithPages<Type>(
  entries: BookEntry<Type>[],
  windowHeight: number,
  startPage: number,
  estimateHeight: (entry: BookEntry<Type>) => number,
) {
  const pageHeight = windowHeight - 50;
  const pages: PageEntry<Type>[] = [];
  let currentPage = startPage;
  let currentPageHeight = 0;

  for (const entry of entries) {
    const estimatedHeight = estimateHeight(entry);

    if (currentPageHeight + estimatedHeight > pageHeight) {
      currentPage += 1;
      currentPageHeight = 0;
    }

    pages.push({
      ...entry,
      page: currentPage,
    });

    currentPageHeight += estimatedHeight;
  }

  return pages;
}

type EntryComponentProps<Type> = {
  entry: PageEntry<Type>;
  renderEntry: (entry: PageEntry<Type>) => React.ReactNode;
};

const EntryComponent = <Type,>(props: EntryComponentProps<Type>) => {
  const { entry, renderEntry } = props;
  return <Section fitted>{renderEntry(entry)}</Section>;
};

type TOCEntryComponentProps<Type> = {
  entry: TOCEntry<Type>;
  setPage: (page: number) => void;
  renderTOCEntry: (entry: TOCEntry<Type>) => React.ReactNode;
};

const TOCEntryComponent = <Type,>(props: TOCEntryComponentProps<Type>) => {
  const { entry, setPage, renderTOCEntry } = props;
  return (
    <Stack textAlign="center" fontSize="13px">
      <Stack.Item>{renderTOCEntry(entry)}</Stack.Item>
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
          onClick={() =>
            setPage(
              entry.entryPage % 2 === 0 ? entry.entryPage - 1 : entry.entryPage,
            )
          }
        >
          {entry.entryPage}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

type FakePageProps<Type> = {
  tocDisplay?: TOCEntry<Type>[];
  entryDisplay?: PageEntry<Type>[];
  setPage: (page: number) => void;
  renderEntry: (entry: PageEntry<Type>) => React.ReactNode;
  renderTOCEntry: (entry: TOCEntry<Type>) => React.ReactNode;
  blankPage?: React.ReactNode;
};

const FakePage = <Type,>(props: FakePageProps<Type>) => {
  const {
    tocDisplay,
    entryDisplay,
    setPage,
    renderEntry,
    renderTOCEntry,
    blankPage,
  } = props;

  return (
    <Section fill fitted pt={1} pl={1} pb={0.5}>
      <Stack vertical fill>
        {tocDisplay?.map((entry) => (
          <Stack.Item key={entry.entry.id} mr={1}>
            <TOCEntryComponent
              entry={entry}
              setPage={setPage}
              renderTOCEntry={renderTOCEntry}
            />
          </Stack.Item>
        ))}
        {entryDisplay?.map((entry) => (
          <Stack.Item key={entry.id}>
            <EntryComponent entry={entry} renderEntry={renderEntry} />
          </Stack.Item>
        ))}
        {!tocDisplay?.length &&
          !entryDisplay?.length &&
          (blankPage || (
            <Stack.Item>This page intentionally left blank.</Stack.Item>
          ))}
      </Stack>
    </Section>
  );
};

type FakePagesProps<Type> = {
  tocDisplay?: TOCEntry<Type>[];
  entryDisplay?: PageEntry<Type>[];
  page: number;
  setPage: (page: number) => void;
  renderEntry: (entry: PageEntry<Type>) => React.ReactNode;
  renderTOCEntry: (entry: TOCEntry<Type>) => React.ReactNode;
  blankPage?: React.ReactNode;
};

const FakePages = <Type,>(props: FakePagesProps<Type>) => {
  const {
    tocDisplay,
    entryDisplay,
    page,
    setPage,
    renderEntry,
    renderTOCEntry,
    blankPage,
  } = props;

  const leftTOC = tocDisplay?.filter((entry) => entry.displayedPage === page);
  const rightTOC = tocDisplay?.filter(
    (entry) => entry.displayedPage === page + 1,
  );

  const leftEntries = entryDisplay?.filter((entry) => entry.page === page);
  const rightEntries = entryDisplay?.filter((entry) => entry.page === page + 1);

  return (
    <Stack fill>
      <Stack.Item grow>
        <FakePage
          tocDisplay={leftTOC}
          entryDisplay={leftEntries}
          setPage={setPage}
          renderEntry={renderEntry}
          renderTOCEntry={renderTOCEntry}
          blankPage={blankPage}
        />
      </Stack.Item>
      <Stack.Item grow>
        <FakePage
          tocDisplay={rightTOC}
          entryDisplay={rightEntries}
          setPage={setPage}
          renderEntry={renderEntry}
          renderTOCEntry={renderTOCEntry}
          blankPage={blankPage}
        />
      </Stack.Item>
    </Stack>
  );
};

type PageTurnProps = {
  page: number;
  setPage: (page: number) => void;
  title: string;
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
        <Stack fill fontSize="15px">
          <Stack.Item grow bold>
            {page}
          </Stack.Item>
          <Stack.Item color="label">~ {title} ~</Stack.Item>
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

type BookUIProps<Type> = {
  bookData: BookEntry<Type>[];
  title: string;
  theme?: string;
  estimateHeight: (entry: BookEntry<Type>) => number;
  renderEntry: (entry: PageEntry<Type>) => React.ReactNode;
  renderTOCEntry: (entry: TOCEntry<Type>) => React.ReactNode;
  blankPage?: React.ReactNode;
};

/**
 * Provides a basic paginated book UI
 *
 * @prop bookData The data to be displayed in the book. Must be a list of BookEntry objects.
 * @prop title The title of the book, displayed on the page turner.
 * @prop theme The theme of the book window. Defaults to 'ntos_lightmode'.
 * @prop estimateHeight A function that estimates the height of a given entry. Used for pagination.
 * @prop renderEntry A function that renders a given entry. Used for displaying entries on pages.
 * @prop renderTOCEntry A function that renders a given entry for the table of contents. Used for displaying entries in the TOC.
 * @prop blankPage An optional React node to display on blank pages. If not provided, blank pages will display "This page intentionally left blank."
 *
 */
export const BookUI = <Type,>(props: BookUIProps<Type>) => {
  const {
    bookData,
    title,
    theme,
    estimateHeight,
    renderEntry,
    renderTOCEntry,
    blankPage,
  } = props;

  const windowHeight = 565;
  const allTOCWithPages = getTOCWithPages(bookData, windowHeight);

  let finalTOCPage = allTOCWithPages.reduce(
    (maxPage, entry) => Math.max(maxPage, entry.displayedPage),
    1,
  );

  if (finalTOCPage % 2 !== 0) {
    finalTOCPage += 1;
  }

  const allEntriesWithPages = getEntriesWithPages(
    bookData,
    windowHeight,
    finalTOCPage + 1,
    estimateHeight,
  );

  for (const entry of bookData) {
    const entryPage = allEntriesWithPages.find((e) => e.id === entry.id);
    const tocEntry = allTOCWithPages.find((e) => e.entry.id === entry.id);
    if (entryPage && tocEntry) {
      tocEntry.entryPage = entryPage.page;
    }
  }

  const lastPage = allEntriesWithPages.reduce(
    (maxPage, entry) => Math.max(maxPage, entry.page),
    finalTOCPage,
  );

  const [page, setPage] = useState(1);

  return (
    <Window
      height={windowHeight}
      width={765}
      title={title}
      theme={theme || 'ntos_lightmode'}
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
                title={page <= finalTOCPage ? `Table of Contents` : title}
              />
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <FakePages
              tocDisplay={allTOCWithPages}
              entryDisplay={allEntriesWithPages}
              page={page}
              setPage={setPage}
              renderEntry={renderEntry}
              renderTOCEntry={renderTOCEntry}
              blankPage={blankPage}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

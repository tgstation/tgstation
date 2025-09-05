import { useBackend } from 'tgui/backend';
import {
  Button,
  Dropdown,
  Input,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import type { LibraryConsoleData } from '../types';

export function SearchAndDisplay(props) {
  return (
    <Stack fill vertical>
      <Stack.Item>
        <SearchTabs />
      </Stack.Item>
      <Stack.Item grow>
        <SearchResults />
      </Stack.Item>
    </Stack>
  );
}

function SearchTabs(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const {
    author,
    book_id,
    can_db_request,
    category,
    params_changed,
    search_categories = [],
    title,
  } = data;

  return (
    <Section fill>
      <Stack justify="space-between">
        <Stack.Item pb={0.6}>
          <Stack>
            <Stack.Item>
              <Input
                value={book_id}
                placeholder={book_id === null ? 'ID' : book_id}
                mt={0.5}
                width="70px"
                onBlur={(value) =>
                  act('set_search_id', {
                    id: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Dropdown
                width="120px"
                options={search_categories}
                selected={category}
                onSelected={(value) =>
                  act('set_search_category', {
                    category: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Input
                value={title}
                placeholder={title || 'Title'}
                mt={0.5}
                onBlur={(value) =>
                  act('set_search_title', {
                    title: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Input
                value={author}
                placeholder={author || 'Author'}
                mt={0.5}
                onBlur={(value) =>
                  act('set_search_author', {
                    author: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={!can_db_request}
            textAlign="right"
            onClick={() => act('search')}
            color={params_changed ? 'good' : ''}
            icon="book"
          >
            Search
          </Button>
          <Button
            disabled={!can_db_request}
            textAlign="right"
            onClick={() => act('clear_data')}
            color="bad"
            icon="fire"
          >
            Reset Search
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function SearchResults(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { pages } = data;

  const sorted = pages
    .map((record, i) => ({
      ...record,
      // Generate a unique id
      key: i,
    }))
    .sort((a, b) => a.key - b.key);

  return (
    <Section fill scrollable>
      <Table>
        <Table.Row className="candystripe">
          <Table.Cell fontSize={1.5}>#</Table.Cell>
          <Table.Cell fontSize={1.5}>Category</Table.Cell>
          <Table.Cell fontSize={1.5}>Title</Table.Cell>
          <Table.Cell fontSize={1.5}>Author</Table.Cell>
        </Table.Row>
        {sorted.map((record) => (
          <Table.Row key={record.key} className="candystripe">
            <Table.Cell>
              <Button
                onClick={() =>
                  act('print_book', {
                    book_id: record.id,
                  })
                }
                icon="print"
              >
                {record.id}
              </Button>
            </Table.Cell>
            <Table.Cell>{record.category}</Table.Cell>
            <Table.Cell>{record.title}</Table.Cell>
            <Table.Cell>{record.author}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}

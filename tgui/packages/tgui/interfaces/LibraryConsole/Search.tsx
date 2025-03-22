import { map, sortBy } from 'common/collections';
import { Box, Button, Input, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { LibraryConsoleData } from './types';

export function SearchAndDisplay(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const {
    search_categories = [],
    book_id,
    title,
    category,
    author,
    params_changed,
    can_db_request,
  } = data;

  const records = sortBy(
    map(data.pages, (record, i) => ({
      ...record,
      // Generate a unique id
      key: i,
    })),
    (record) => record.key,
  );

  return (
    <Box>
      <Stack justify="space-between">
        <Stack.Item pb={0.6}>
          <Stack>
            <Stack.Item>
              <Input
                value={book_id}
                placeholder={book_id === null ? 'ID' : book_id}
                mt={0.5}
                width="70px"
                onChange={(e, value) =>
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
                onChange={(e, value) =>
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
                onChange={(e, value) =>
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
      <Table>
        <Table.Row>
          <Table.Cell fontSize={1.5}>#</Table.Cell>
          <Table.Cell fontSize={1.5}>Category</Table.Cell>
          <Table.Cell fontSize={1.5}>Title</Table.Cell>
          <Table.Cell fontSize={1.5}>Author</Table.Cell>
        </Table.Row>
        {records.map((record) => (
          <Table.Row key={record.key}>
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
    </Box>
  );
}

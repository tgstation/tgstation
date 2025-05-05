import {
  Button,
  Dropdown,
  Input,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { useModifyState } from './hooks';
import { Book, LibraryAdminData, ModifyTypes } from './types';

type AdminBook = Book & {
  author_ckey: string;
  deleted: BooleanLike;
};

type DisplayAdminBook = AdminBook & {
  key: number;
};

export function SearchAndDisplay(props) {
  const { act, data } = useBackend<LibraryAdminData>();

  const { modifyMethodState, modifyTargetState } = useModifyState();
  const [modifyMethod, setModifyMethod] = modifyMethodState;
  const [modifyTarget, setModifyTarget] = modifyTargetState;

  const {
    can_db_request,
    search_categories = [],
    book_id,
    title,
    category,
    author,
    author_ckey,
    pages,
    params_changed,
    view_raw,
    show_deleted,
  } = data;

  const books = pages
    .map((book, i) => ({
      ...book,
      // Generate a unique id
      key: i,
    }))
    .sort((a, b) => a.key - b.key) as DisplayAdminBook[];

  return (
    <Section>
      <Stack justify="space-between">
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Input
                value={book_id?.toString()}
                placeholder={book_id === null ? 'ID' : String(book_id)}
                width="70px"
                expensive
                onChange={(value) =>
                  act('set_search_id', {
                    id: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Dropdown
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
                expensive
                onChange={(value) =>
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
                expensive
                onChange={(value) =>
                  act('set_search_author', {
                    author: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Input
                value={author_ckey}
                placeholder={author_ckey || 'Ckey'}
                mt={0.5}
                expensive
                onChange={(value) =>
                  act('set_search_ckey', {
                    ckey: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Button
                disabled={!can_db_request}
                textAlign="right"
                onClick={() => act('refresh')}
                color={params_changed ? 'good' : ''}
                icon="rotate-right"
              >
                Refresh
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
            <Stack.Item>
              <Button
                textAlign="right"
                onClick={() => act('toggle_raw')}
                color={view_raw ? 'purple' : 'blue'}
                icon={view_raw ? 'theater-masks' : 'glasses'}
              >
                {view_raw ? 'Raw' : 'Normal'}
              </Button>
              <Button
                textAlign="right"
                onClick={() => act('toggle_deleted')}
                color={show_deleted ? 'purple' : 'green'}
                icon={show_deleted ? 'trash' : 'mountain-sun'}
              >
                {show_deleted ? 'All' : 'Undeleted'}
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <Table>
        <Table.Row>
          <Table.Cell fontSize={1.5}>#</Table.Cell>
          <Table.Cell fontSize={1.5}>Category</Table.Cell>
          <Table.Cell fontSize={1.5}>Title</Table.Cell>
          <Table.Cell fontSize={1.5}>Author</Table.Cell>
          <Table.Cell fontSize={1.5}>C-Key</Table.Cell>
          <Table.Cell fontSize={1.5}>Un/Delete</Table.Cell>
        </Table.Row>
        {books.map((book) => (
          <Table.Row key={book.key}>
            <Table.Cell>
              <Button
                onClick={() =>
                  act('view_book', {
                    book_id: book.id,
                  })
                }
                icon="book-reader"
              >
                {book.id}
              </Button>
            </Table.Cell>
            <Table.Cell>{book.category}</Table.Cell>
            <Table.Cell>{book.title}</Table.Cell>
            <Table.Cell>{book.author}</Table.Cell>
            <Table.Cell>{book.author_ckey}</Table.Cell>
            <Table.Cell>
              {book.deleted ? (
                <Button
                  onClick={() => {
                    setModifyTarget(book.id);
                    setModifyMethod(ModifyTypes.Restore);
                    act('get_history', {
                      book_id: book.id,
                    });
                  }}
                  icon="undo"
                  color="blue"
                >
                  Restore
                </Button>
              ) : (
                <Button
                  onClick={() => {
                    setModifyTarget(book.id);
                    setModifyMethod(ModifyTypes.Delete);
                    act('get_history', {
                      book_id: book.id,
                    });
                  }}
                  icon="hammer"
                  color="violet"
                >
                  Delete
                </Button>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}

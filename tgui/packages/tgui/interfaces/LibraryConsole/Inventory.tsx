import { Button, NoticeBox, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { PageSelect, ScrollableSection } from './components';
import { LibraryConsoleData } from './types';

export function Inventory(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { inventory_page_count, inventory_page, has_inventory } = data;

  if (!has_inventory) {
    return (
      <NoticeBox>No Book Records detected. Update your inventory!</NoticeBox>
    );
  }

  return (
    <Stack vertical justify="space-between" height="100%">
      <Stack.Item grow>
        <ScrollableSection
          header="Library Inventory"
          contents={<InventoryDetails />}
        />
      </Stack.Item>
      <Stack.Item align="center">
        <PageSelect
          minimum_page_count={1}
          page_count={inventory_page_count}
          current_page={inventory_page}
          call_on_change={(value) =>
            act('switch_inventory_page', {
              page: value,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
}

function InventoryDetails(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { inventory } = data;

  const sorted = inventory
    .map((book, i) => ({
      ...book,
      // Generate a unique id
      key: i,
    }))
    .sort((a, b) => a.key - b.key);

  return (
    <Section>
      <Table>
        <Table.Row header>
          <Table.Cell>Remove</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Author</Table.Cell>
        </Table.Row>
        {sorted.map((book) => (
          <Table.Row key={book.key}>
            <Table.Cell>
              <Button
                color="bad"
                onClick={() =>
                  act('inventory_remove', {
                    book_id: book.ref,
                  })
                }
                icon="times"
              >
                Clear Record
              </Button>
            </Table.Cell>
            <Table.Cell>{book.title}</Table.Cell>
            <Table.Cell>{book.author}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}

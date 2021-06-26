import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend } from '../backend';
import { Box, Button, Dropdown, Input, NoticeBox, Section, Stack, Table } from '../components';
import { TableCell } from '../components/Table';
import { Window } from '../layouts';

export const LibraryVisitor = (props, context) => {
  return (
    <Window
      title="Library Lookup Console"
      width={702}
      height={410}>
      <BookListing />
    </Window>
  );
};

export const BookListing = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    can_connect,
  } = data;
  if (can_connect) {
    return (
      <Stack
        fill={1}
        vertical={1}
        justify={"space-between"}>
        <Stack.Item>
          <Box fillPositionedParent bottom="20px">
            <Window.Content
              scrollable={1}>
              <SearchAndDisplay />
            </Window.Content>
          </Box>
        </Stack.Item>
        <Stack.Item
          align={"center"}>
          <PageSelect />
        </Stack.Item>
      </Stack>
    );
  }
  return (
    <NoticeBox>
      Unable to retrieve book listings.
      Please contact your system administrator for assistance.
    </NoticeBox>
  );
};

export const SearchAndDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    categories = [],
    title,
    category,
    author,
    params_changed,
  } = data;
  const records = flow([
    map((record, i) => ({
      ...record,
      // Generate a unique id
      key: i,
    })),
    sortBy(record => record.key),
  ])(data.pages);
  return (
    <Section>
      <Stack>
        <Stack.Item grow={1}>
          <Dropdown
            options={categories}
            selected={category}
            onSelected={(value) => act('set-category', {
              category: value,
            })} />
        </Stack.Item>
        <Stack.Item grow={1}>
          <Stack>
            <Stack.Item>
              <Box
                fontSize={1.4}>
                Title:
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Input
                value={title}
                placeholder={title || "Title"}
                mt={0.5}
                onChange={(e, value) => act("set-title", {
                  title: value,
                })} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow={1}>
          <Stack>
            <Stack.Item>
              <Box
                fontSize={1.4}>
                Author:
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Input
                value={author}
                placeholder={author || "Author"}
                mt={0.5}
                onChange={(e, value) => act("set-author", {
                  author: value,
                })} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item
          grow={1}
          align={"end"}>
          <Button
            disabled={!params_changed}
            textAlign={'right'}
            onClick={() => act('search')}
            color={'good'}
            icon={'book'}>
            Search
          </Button>
        </Stack.Item>
        <Stack.Item
          grow={1}
          align={"end"}>
          <Button
            textAlign={'right'}
            onClick={() => act('clear-data')}
            color={'bad'}
            icon={'fire'}>
            Reset Search
          </Button>
        </Stack.Item>
      </Stack>
      <Table>
        <Table.Row>
          <Table.Cell
            fontSize={1.5}>
            #
          </Table.Cell>
          <TableCell
            fontSize={1.5}>
            Category
          </TableCell>
          <Table.Cell
            fontSize={1.5}>
            Title
          </Table.Cell>
          <Table.Cell
            fontSize={1.5}>
            Author
          </Table.Cell>
        </Table.Row>
        {records.map(record => (
          <Table.Row key={record.key}>
            <Table.Cell>
              {record.id}
            </Table.Cell>
            <Table.Cell>
              {record.category}
            </Table.Cell>
            <Table.Cell>
              {record.title}
            </Table.Cell>
            <Table.Cell>
              {record.author}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

export const PageSelect = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    page_count,
    our_page,
  } = data;
  return (
    <Stack>
      <Stack.Item>
        <Button
          icon={'angle-double-left'}
          onClick={() => act('switch-page', {
            page: 0,
          })} />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon={'chevron-left'}
          onClick={() => act('switch-page', {
            page: our_page - 1,
          })} />
      </Stack.Item>
      <Stack.Item>
        <Input
          placeholder={our_page + "/" + page_count}
          onChange={(e, value) => act('switch-page', {
            page: value,
          })} />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon={'chevron-right'}
          onClick={() => act('switch-page', {
            page: our_page + 1,
          })} />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon={'angle-double-right'}
          onClick={() => act('switch-page', {
            page: page_count,
          })} />
      </Stack.Item>
    </Stack>
  );
};

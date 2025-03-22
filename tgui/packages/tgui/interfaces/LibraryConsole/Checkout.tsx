import { sortBy } from 'common/collections';
import { map } from 'common/collections';
import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  Modal,
  NumberInput,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import { PageSelect, ScrollableSection } from './components';
import { LibraryConsoleData } from './types';

export function Checkout(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { checkout_page, checkout_page_count } = data;

  const [checkoutBook, setCheckoutBook] = useLocalState('CheckoutBook', false);

  return (
    <Stack vertical height="100%" justify="space-between">
      <Stack.Item grow>
        <Stack vertical height="100%">
          <Stack.Item grow>
            <ScrollableSection
              header="Checked Out Books"
              contents={<CheckoutEntries />}
            />
          </Stack.Item>
          <Stack.Item align="center">
            <PageSelect
              minimum_page_count={1}
              page_count={checkout_page_count}
              current_page={checkout_page}
              call_on_change={(value) =>
                act('switch_checkout_page', {
                  page: value,
                })
              }
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          icon="barcode"
          content="Check-Out Book"
          fontSize="20px"
          onClick={() => setCheckoutBook(true)}
        />
      </Stack.Item>
      {!!checkoutBook && <CheckoutModal />}
    </Stack>
  );
}

function CheckoutModal(props) {
  const { act, data } = useBackend();
  const inventory = sortBy(
    map(data.inventory, (book, i) => ({
      ...book,
      // Generate a unique id
      key: i,
    })),
    (book) => book.key,
  );

  const [checkoutBook, setCheckoutBook] = useLocalState('CheckoutBook', false);
  const [bookName, setBookName] = useState('Insert Book name...');
  const [checkoutee, setCheckoutee] = useState('Recipient');
  const [checkoutPeriod, setCheckoutPeriod] = useState(5);

  return (
    <Modal width="500px">
      <Box fontSize="20px" pb={1}>
        Are you sure you want to loan out this book?
      </Box>
      <Dropdown
        over
        mb={1.7}
        width="100%"
        selected={bookName}
        options={inventory.map((book) => book.title)}
        onSelected={(e) => setBookName(e)}
      />
      <LabeledList>
        <LabeledList.Item label="Loan To">
          <Input
            width="160px"
            value={checkoutee}
            onChange={(e, value) => setCheckoutee(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Loan Period">
          <NumberInput
            value={checkoutPeriod}
            unit=" Minutes"
            minValue={1}
            maxValue={1440}
            step={1}
            stepPixelSize={10}
            onChange={(value) => setCheckoutPeriod(value)}
          />
        </LabeledList.Item>
      </LabeledList>
      <Stack justify="center" align="center" pt={1}>
        <Stack.Item>
          <Button
            icon="upload"
            content="Loan Out"
            fontSize="16px"
            color="good"
            onClick={() => {
              setCheckoutBook(false);
              act('checkout', {
                book_name: bookName,
                loaned_to: checkoutee,
                checkout_time: checkoutPeriod,
              });
            }}
            lineHeight={2}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            content="Return"
            fontSize="16px"
            color="bad"
            onClick={() => setCheckoutBook(false)}
            lineHeight={2}
          />
        </Stack.Item>
      </Stack>
    </Modal>
  );
}

export function CheckoutEntries(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { checkouts, has_checkout } = data;

  if (!has_checkout) return;

  return (
    <Table>
      <Table.Row header>
        <Table.Cell>Check-In</Table.Cell>
        <Table.Cell>Title</Table.Cell>
        <Table.Cell>Author</Table.Cell>
        <Table.Cell>Borrower</Table.Cell>
        <Table.Cell>Time Left</Table.Cell>
      </Table.Row>
      {checkouts.map((entry) => (
        <Table.Row key={entry.id}>
          <Table.Cell>
            <Button
              onClick={() =>
                act('checkin', {
                  checked_out_id: entry.ref,
                })
              }
              icon="box-open"
            />
          </Table.Cell>
          <Table.Cell>{entry.title}</Table.Cell>
          <Table.Cell>{entry.author}</Table.Cell>
          <Table.Cell>{entry.borrower}</Table.Cell>
          <Table.Cell backgroundColor={entry.overdue ? 'bad' : 'good'}>
            {entry.overdue ? 'Overdue' : entry.due_in_minutes + ' Minutes'}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}

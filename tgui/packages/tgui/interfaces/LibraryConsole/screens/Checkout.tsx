import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Button,
  Dropdown,
  Input,
  LabeledList,
  Modal,
  NoticeBox,
  NumberInput,
  Stack,
  Table,
} from 'tgui-core/components';

import { PageSelect } from '../components/PageSelect';
import { ScrollableSection } from '../components/ScrollableSection';
import type { LibraryConsoleData } from '../types';
import { useLibraryContext } from '../useLibraryContext';

export function Checkout(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { checkout_page, checkout_page_count } = data;

  const { checkoutBookState } = useLibraryContext();
  const [checkoutBook, setCheckoutBook] = checkoutBookState;

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
          fontSize="20px"
          onClick={() => setCheckoutBook(true)}
        >
          Check-Out Book
        </Button>
      </Stack.Item>
      {!!checkoutBook && <CheckoutModal />}
    </Stack>
  );
}

function CheckoutModal(props) {
  const { act, data } = useBackend<LibraryConsoleData>();

  const inventory = data.inventory
    .map((book, i) => ({
      ...book,
      // Generate a unique id
      key: i,
    }))
    .sort((a, b) => a.key - b.key);

  const { checkoutBookState } = useLibraryContext();
  const [checkoutBook, setCheckoutBook] = checkoutBookState;

  const [bookName, setBookName] = useState('Insert Book name...');
  const [checkoutee, setCheckoutee] = useState('Recipient');
  const [checkoutPeriod, setCheckoutPeriod] = useState(5);

  return (
    <Modal width="500px" py={4}>
      <Stack fill vertical>
        <Stack.Item fontSize="20px">
          Are you sure you want to loan out this book?
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            over
            width="100%"
            selected={bookName}
            options={inventory.map((book) => book.title)}
            onSelected={(e) => setBookName(e)}
          />
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Loan To">
              <Input
                width="160px"
                value={checkoutee}
                onChange={setCheckoutee}
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
        </Stack.Item>
        <Stack.Item>
          <Stack justify="center" align="center" pt={1}>
            <Stack.Item>
              <Button
                icon="upload"
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
              >
                Loan Out
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="times"
                fontSize="16px"
                color="bad"
                onClick={() => setCheckoutBook(false)}
                lineHeight={2}
              >
                Return
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}

export function CheckoutEntries(props) {
  const { act, data } = useBackend<LibraryConsoleData>();
  const { checkouts = [] } = data;

  return (
    <Table>
      <Table.Row header className="candystripe">
        <Table.Cell>Title</Table.Cell>
        <Table.Cell>Author</Table.Cell>
        <Table.Cell>Borrower</Table.Cell>
        <Table.Cell>Time Left</Table.Cell>
        <Table.Cell>Check-In</Table.Cell>
      </Table.Row>
      {checkouts.length === 0 ? (
        <Table.Row>
          <Table.Cell textAlign="center" colSpan={5}>
            <NoticeBox>No books checked out.</NoticeBox>
          </Table.Cell>
        </Table.Row>
      ) : (
        checkouts.map((entry) => (
          <Table.Row key={entry.id} className="candystripe">
            <Table.Cell>{entry.title}</Table.Cell>
            <Table.Cell>{entry.author}</Table.Cell>
            <Table.Cell>{entry.borrower}</Table.Cell>
            <Table.Cell backgroundColor={entry.overdue ? 'bad' : 'good'}>
              {entry.overdue ? 'Overdue' : `${entry.due_in_minutes} Minutes`}
            </Table.Cell>
            <Table.Cell width="70px" textAlign="center">
              <Button
                mb={1}
                onClick={() =>
                  act('checkin', {
                    checked_out_id: entry.ref,
                  })
                }
                icon="box-open"
              />
            </Table.Cell>
          </Table.Row>
        ))
      )}
    </Table>
  );
}

import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Input, Modal, NoticeBox, NumberInput, LabeledList, Section, Stack, Flex, Table } from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

export const LibraryConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { display_lore } = data;
  return (
    <Window
      theme={display_lore ? 'spookyconsole' : ''}
      title="Library Terminal"
      width={880}
      height={520}>
      <Window.Content m="0">
        <Flex height="100%">
          <Flex.Item>
            <PopoutMenu />
          </Flex.Item>
          <Flex.Item grow position="relative" pl={1}>
            <PageDisplay />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

export const PopoutMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { screen_state, show_dropdown, display_lore } = data;
  return (
    <Section fill maxWidth={show_dropdown ? '150px' : '36px'}>
      <Stack vertical fill>
        <Stack.Item>
          <Button
            fluid
            fontSize="13px"
            onClick={() => act('toggle_dropdown')}
            icon={show_dropdown === 1 ? 'chevron-left' : 'chevron-right'}
            tooltip={!show_dropdown && 'Expand'}
            content={!!show_dropdown && 'Collapse'}
          />
        </Stack.Item>
        <PopoutEntry id={1} icon="list" text="Inventory" />
        <PopoutEntry id={2} icon="calendar" text="Checkout" />
        <PopoutEntry id={3} icon="server" text="Archive" />
        <PopoutEntry id={4} icon="upload" text="Upload" />
        <PopoutEntry id={5} icon="print" text="Print" />
        {!!display_lore && (
          <PopoutEntry
            id={6}
            icon="question"
            text={screen_state === 6 ? 'Gur Fbeprere' : 'Forbidden Lore'}
            color="black"
            font="copperplate"
          />
        )}
      </Stack>
    </Section>
  );
};

export const PageDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const { screen_state } = data;
  /* eslint-disable indent */
  /* eslint-disable operator-linebreak */
  return screen_state === 1 ? (
    <Inventory />
  ) : screen_state === 2 ? (
    <Checkout />
  ) : screen_state === 3 ? (
    <Archive />
  ) : screen_state === 4 ? (
    <Upload />
  ) : screen_state === 5 ? (
    <Print />
  ) : screen_state === 6 ? (
    <Forbidden />
  ) : null;
  /* eslint-enable indent */
  /* eslint-enable operator-linebreak */
};

export const Inventory = (props, context) => {
  const { act, data } = useBackend(context);
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
};

export const InventoryDetails = (props, context) => {
  const { act, data } = useBackend(context);
  const inventory = flow([
    map((book, i) => ({
      ...book,
      // Generate a unique id
      key: i,
    })),
    sortBy((book) => book.key),
  ])(data.inventory);
  return (
    <Section>
      <Table>
        <Table.Row header>
          <Table.Cell>Remove</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Author</Table.Cell>
        </Table.Row>
        {inventory.map((book) => (
          <Table.Row key={book.key}>
            <Table.Cell>
              <Button
                color="bad"
                onClick={() =>
                  act('inventory_remove', {
                    book_id: book.ref,
                  })
                }
                icon="times">
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
};

export const Checkout = (props, context) => {
  const { act, data } = useBackend(context);
  const { checkout_page, checkout_page_count } = data;

  const [checkoutBook, setCheckoutBook] = useLocalState(
    context,
    'CheckoutBook',
    false
  );
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
};

export const CheckoutEntries = (props, context) => {
  const { act, data } = useBackend(context);
  const { checkouts, has_checkout } = data;

  if (!has_checkout) {
    return null;
  }
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
};

const CheckoutModal = (props, context) => {
  const { act, data } = useBackend(context);

  const { checking_out } = data;
  const [checkoutBook, setCheckoutBook] = useLocalState(
    context,
    'CheckoutBook',
    false
  );
  const [bookName, setBookName] = useLocalState(
    context,
    'CheckoutBookName',
    checking_out || 'Book'
  );
  const [checkoutee, setCheckoutee] = useLocalState(
    context,
    'Checkoutee',
    'Recipient'
  );
  const [checkoutPeriod, setCheckoutPeriod] = useLocalState(
    context,
    'CheckoutPeriod',
    5
  );

  return (
    <Modal width="500px">
      <Box fontSize="20px" pb={1}>
        Are you sure you want to loan out this book?
      </Box>
      <LabeledList>
        <LabeledList.Item label="Book Name">
          <Input
            width="250px"
            value={bookName}
            onChange={(e, value) => setBookName(value)}
          />
        </LabeledList.Item>
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
            stepPixelSize={10}
            onChange={(e, value) => setCheckoutPeriod(value)}
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
};

export const Archive = (props, context) => {
  const { act, data } = useBackend(context);
  const { can_connect, can_db_request, page_count, our_page } = data;
  if (!can_connect) {
    return (
      <NoticeBox>
        Unable to retrieve book listings. Please contact your system
        administrator for assistance.
      </NoticeBox>
    );
  }
  return (
    <Stack vertical justify="space-between" height="100%">
      <Stack.Item grow>
        <ScrollableSection
          header="Remote Archive"
          contents={<SearchAndDisplay />}
        />
      </Stack.Item>
      <Stack.Item align="center">
        <PageSelect
          minimum_page_count={1}
          page_count={page_count}
          current_page={our_page}
          disabled={!can_db_request}
          call_on_change={(value) =>
            act('switch_page', {
              page: value,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
};

export const SearchAndDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    search_categories = [],
    title,
    category,
    author,
    params_changed,
    can_db_request,
  } = data;
  const records = flow([
    map((record, i) => ({
      ...record,
      // Generate a unique id
      key: i,
    })),
    sortBy((record) => record.key),
  ])(data.pages);

  return (
    <Box>
      <Stack justify="space-between">
        <Stack.Item pb={0.6}>
          <Stack>
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
            icon="book">
            Search
          </Button>
          <Button
            disabled={!can_db_request}
            textAlign="right"
            onClick={() => act('clear_data')}
            color="bad"
            icon="fire">
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
                icon="print">
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
};

export const Upload = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active_newscaster_cooldown,
    cache_author,
    cache_content,
    cache_title,
    can_db_request,
    has_cache,
    has_scanner,
    cooldown_string,
  } = data;
  const [uploadToDB, setUploadToDB] = useLocalState(context, 'UploadDB', false);
  if (!has_scanner) {
    return (
      <NoticeBox>
        No nearby scanner detected, construct one to continue.
      </NoticeBox>
    );
  }
  if (!has_cache) {
    return <NoticeBox>Scan in a book to upload.</NoticeBox>;
  }
  const contentHtml = {
    __html: sanitizeText(cache_content),
  };
  return (
    <>
      <Stack vertical height="100%">
        <Stack.Item>
          <Box fontSize="20px" textAlign="center" pt="6px">
            Current Scan Cache
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <Stack vertical height="100%">
            <Stack.Item>
              <Stack justify="center">
                <Stack.Item>
                  <Box pt={1} fontSize={'20px'}>
                    Title:
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    fontSize="20px"
                    value={cache_title}
                    placeholder={cache_title || 'Title'}
                    mt={0.5}
                    width={22}
                    onChange={(e, value) =>
                      act('set_cache_title', {
                        title: value,
                      })
                    }
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box pt={1} fontSize="20px">
                    Author:
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    fontSize="20px"
                    value={cache_author}
                    placeholder={cache_author || 'Author'}
                    mt={0.5}
                    onChange={(e, value) =>
                      act('set_cache_author', {
                        author: value,
                      })
                    }
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Section
                fill
                scrollable
                preserveWhitespace
                fontSize="15px"
                title="Content:">
                <Box dangerouslySetInnerHTML={contentHtml} />
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                disabled={!active_newscaster_cooldown}
                fluid
                tooltip={
                  active_newscaster_cooldown
                    ? "Send your book to the station's newscaster's channel."
                    : 'Please wait ' +
                    cooldown_string +
                    ' before sending your book to the newscaster!'
                }
                tooltipPosition="top"
                icon="newspaper"
                content="Newscaster"
                fontSize="30px"
                lineHeight={2}
                textAlign="center"
                onClick={() => act('news_post')}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                disabled={!can_db_request}
                fluid
                icon="server"
                content="Archive"
                fontSize="30px"
                lineHeight={2}
                textAlign="center"
                onClick={() => setUploadToDB(true)}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      {!!uploadToDB && <UploadModal />}
    </>
  );
};

const UploadModal = (props, context) => {
  const { act, data } = useBackend(context);

  const { upload_categories, default_category, can_db_request } = data;
  const [uploadToDB, setUploadToDB] = useLocalState(context, 'UploadDB', false);
  const [uploadCategory, setUploadCategory] = useLocalState(
    context,
    'ModalUpload',
    ''
  );

  const display_category = uploadCategory || default_category;
  return (
    <Modal width="650px">
      <Box fontSize="20px" pb={2}>
        Are you sure you want to upload this book to the database?
      </Box>
      <LabeledList>
        <LabeledList.Item label="Category">
          <Dropdown
            options={upload_categories}
            selected={display_category}
            onSelected={(value) => setUploadCategory(value)}
          />
        </LabeledList.Item>
      </LabeledList>
      <Stack justify="center" align="center" pt={2}>
        <Stack.Item>
          <Button
            disabled={!can_db_request}
            icon="upload"
            content="Upload To DB"
            fontSize="18px"
            color="good"
            onClick={() => {
              setUploadToDB(false);
              act('upload', {
                category: display_category,
              });
            }}
            lineHeight={2}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            content="Return"
            fontSize="18px"
            color="bad"
            onClick={() => setUploadToDB(false)}
            lineHeight={2}
          />
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

export const Print = (props, context) => {
  const { act, data } = useBackend(context);
  const { deity, religion, bible_name, bible_sprite, posters } = data;
  const [selectedPoster, setSelectedPoster] = useLocalState(
    context,
    'selected_poster',
    posters[0]
  );

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item width="50%">
            <Section fill scrollable>
              {posters.map((poster) => (
                <div
                  key={poster}
                  title={poster}
                  className={classes([
                    'Button',
                    'Button--fluid',
                    'Button--color--transparent',
                    'Button--ellipsis',
                    selectedPoster &&
                      poster === selectedPoster &&
                      'Button--selected',
                  ])}
                  onClick={() => setSelectedPoster(poster)}>
                  {poster}
                </div>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack vertical height="100%">
              <Stack.Item
                textAlign="center"
                fontSize="25px"
                italic
                bold
                textColor="#0b94c4">
                {bible_name}
              </Stack.Item>
              <Stack.Item textAlign="center" fontSize="22px" textColor="purple">
                In the Name of {deity}
              </Stack.Item>
              <Stack.Item textAlign="center" fontSize="22px" textColor="purple">
                For the Sake of {religion}
              </Stack.Item>
              <Stack.Item align="center">
                <Box className={classes(['bibles224x224', bible_sprite])} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack justify="space-between">
          <Stack.Item grow>
            <Button
              fluid
              icon="scroll"
              content="Poster"
              fontSize="30px"
              lineHeight={2}
              textAlign="center"
              onClick={() =>
                act('print_poster', {
                  poster_name: selectedPoster,
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              icon="cross"
              content="Bible"
              fontSize="30px"
              lineHeight={2}
              textAlign="center"
              onClick={() => act('print_bible')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const ForbiddenModal = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Modal>
      <Box className="LibraryComputer__CultText" fontSize="28px">
        Accessing Forbidden Lore Vault v 1.3:
      </Box>
      <Box className="LibraryComputer__CultText" pt={0.4}>
        Are you absolutely sure you want to proceed?
      </Box>
      <Box className="LibraryComputer__CultText" pt={0.2} bold>
        EldritchRelics Inc. will take no responsibility for this choice
      </Box>
      <Stack justify="center" align="center">
        <Stack.Item>
          <Button
            className="LibraryComputer__CultText"
            fluid
            icon="check"
            content="Assent"
            color="good"
            fontSize="20px"
            onClick={() => act('lore_spawn')}
            lineHeight={2}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            className="LibraryComputer__CultText"
            fluid
            icon="times"
            content="Decline"
            color="bad"
            fontSize="20px"
            onClick={() => act('lore_deny')}
            lineHeight={2}
          />
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

export const Forbidden = (props, context) => {
  const description =
    'Abf vqrnz cebprffhf pbzchgngvbanyvf fghqrer vapvcvrzhf\nCebprffhf pbzchgngvbanyrf fhag erf nofgenpgnr dhnr pbzchgngberf vapbyhag\nHg ribyihag, cebprffhf nyvn nofgenpgn dhnr qngn znavchyner qvphaghe\nRibyhgvbavf cebprffhf qvevtvghe cre rkrzcyhz erthynr cebtenzzngvf ibpngv\nUbzvarf cebtenzzngn nq cebprffhf erpgbf rssvpvhag\nEriren fcvevghf pbzchgngbevv phz vapnagnzragvf pbavhatvzhf\nCebprffhf pbzchgngvbanyvf rfg zhyghz fvzvyvf vqrnr irarsvpnr fcvevghf\nivqrev nhg gnatv aba cbgrfg\nAba rfg rk zngrevn pbzcbfvgn\nFrq vq cynpreng vcfhz\nAba cbgrfg bcrenev bchf vagryyrpghnyr\nErfcbaqrev cbgrfg\nZhaqhz nssvprer cbgrfg rebtnaqb crphavnz nq evcnz iry cre oenppuvhz \nebobgv snoevpnaqb zbqrenaqb\nPbafvyvvf hgvzhe cebprffvohf nhthenaqv fhag fvphg vapnagnzragn irarsvpvv';
  return (
    <Box className="LibraryComputer__CultNonsense" preserveWhitespace>
      {description}
      <ForbiddenModal />
    </Box>
  );
};

export const ScrollableSection = (props, context) => {
  const { header, contents } = props;

  return (
    <Section fill scrollable>
      <Box fontSize="20px" textAlign="center">
        {header}
      </Box>
      <Box position="relative" top="10px">
        {contents}
      </Box>
    </Section>
  );
};

export const PopoutEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const { id, text, icon, color, font } = props;
  const { show_dropdown, screen_state } = data;
  const selected_color = color || 'good';
  const deselected_color = color || '';

  return (
    <Stack.Item>
      <Button
        fluid
        fontSize="13px"
        onClick={() =>
          act('set_screen', {
            screen_index: id,
          })
        }
        color={id === screen_state ? selected_color : deselected_color}
        fontFamily={font}
        icon={icon}
        tooltip={!show_dropdown && text}
        content={!!show_dropdown && text}
      />
    </Stack.Item>
  );
};

export const PageSelect = (props, context) => {
  const {
    minimum_page_count,
    page_count,
    current_page,
    call_on_change,
    disabled,
  } = props;

  if (page_count === 1) {
    return;
  }

  return (
    <Stack>
      <Stack.Item>
        <Button
          disabled={current_page === minimum_page_count || disabled}
          icon="angle-double-left"
          onClick={() => call_on_change(minimum_page_count)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={current_page === minimum_page_count || disabled}
          icon="chevron-left"
          onClick={() => call_on_change(current_page - 1)}
        />
      </Stack.Item>
      <Stack.Item>
        <Input
          placeholder={current_page + '/' + page_count}
          onChange={(e, value) => {
            // I am so sorry
            if (value !== '') {
              call_on_change(value);
              e.target.value = null;
            }
          }}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={current_page === page_count || disabled}
          icon="chevron-right"
          onClick={() => call_on_change(current_page + 1)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={current_page === page_count || disabled}
          icon="angle-double-right"
          onClick={() => call_on_change(page_count)}
        />
      </Stack.Item>
    </Stack>
  );
};

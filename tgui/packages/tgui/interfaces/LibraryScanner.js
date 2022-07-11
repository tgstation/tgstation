import { useBackend } from '../backend';
import { Button, Stack, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const LibraryScanner = (props, context) => {
  return (
    <Window title="Library Scanner" width={350} height={150}>
      <BookScanning />
    </Window>
  );
};

const BookScanning = (props, context) => {
  const { act, data } = useBackend(context);
  const { has_book, has_cache, book } = data;
  if (!has_book && !has_cache) {
    return <NoticeBox>Insert a book to scan</NoticeBox>;
  }
  return (
    <Stack direction="column" height="100%" justify="flex-end">
      <Stack.Item grow>
        <Section textAlign="center" height="100%" title={book.author}>
          {book.title}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="eject"
              onClick={() => act('eject')}
              disabled={!has_book}>
              Eject Book
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              onClick={() => act('scan')}
              color="good"
              icon="qrcode"
              disabled={!has_book}>
              Scan Book
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="fire"
              onClick={() => act('clear')}
              color="bad"
              disabled={!has_cache}>
              Clear Cache
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

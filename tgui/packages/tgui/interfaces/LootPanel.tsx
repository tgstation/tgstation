import { KEY } from 'common/keys';
import { BooleanLike } from 'common/react';
import { capitalizeAll, createSearch } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Button,
  Icon,
  Image,
  Input,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type Data = {
  contents: Atom[];
  searching: BooleanLike;
  total: number;
};

type Atom = {
  icon?: string;
  name: string;
  ref: string;
};

export function LootPanel(props) {
  const { act, data } = useBackend<Data>();
  const { contents = [], searching, total = 0 } = data;

  const [searchText, setSearchText] = useState('');

  const filteredContents = contents.filter(
    createSearch(searchText, (atom) => atom.name),
  );

  return (
    <Window height={250} width={190} title={`Contents: ${total - 1}`}>
      <Window.Content
        onKeyDown={(event) => {
          if (event.key === KEY.Enter && filteredContents.length > 0) {
            act('grab', { ref: filteredContents[0].ref });
          }
        }}
      >
        <Section
          fill
          scrollable
          title={
            <Stack>
              <Stack.Item grow>
                <Input
                  autoFocus
                  fluid
                  onInput={(event, value) => setSearchText(value)}
                  placeholder="Search"
                />
              </Stack.Item>
              <Button
                disabled={!!searching}
                icon="sync"
                onClick={() => act('refresh')}
              />
            </Stack>
          }
        >
          <Stack fill wrap>
            {filteredContents.map((atom, index) => (
              <Stack.Item key={index} m={1}>
                <SearchItem atom={atom} />
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
}

function SearchItem({ atom }: { atom: Atom }) {
  const { act } = useBackend();

  return (
    <Tooltip content={capitalizeAll(atom.name)}>
      <div
        className="SearchItem"
        onClick={(event) =>
          act('grab', {
            ctrl: event.ctrlKey,
            ref: atom.ref,
            shift: event.shiftKey,
          })
        }
        onContextMenu={(event) => {
          event.preventDefault();
          act('grab', {
            middle: true,
            ref: atom.ref,
            shift: true,
          });
        }}
      >
        {!atom.icon ? (
          <Icon name="spinner" spin size={1.9} color="grey" />
        ) : (
          <Image src={atom.icon} />
        )}
      </div>
    </Tooltip>
  );
}

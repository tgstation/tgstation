import { KEY } from 'common/keys';
import { BooleanLike } from 'common/react';
import { capitalizeAll, createSearch } from 'common/string';
import { useMemo, useState } from 'react';

import { useBackend } from '../backend';
import {
  Button,
  Flex,
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
  path?: string;
  ref: string;
};

export function LootPanel(props) {
  const { act, data } = useBackend<Data>();
  const { contents = [], searching, total = 0 } = data;

  const [searchText, setSearchText] = useState('');

  // limitations: stacks of items with uneven amounts
  const contentsByPath = useMemo(() => {
    const acc: Record<string, Atom[]> = {};

    for (let i = 0; i < contents.length; i++) {
      const atom = contents[i];
      if (atom.path) {
        if (!acc[atom.path]) {
          acc[atom.path] = [];
        }
        acc[atom.path].push(atom);
      } else {
        acc[atom.ref] = [atom];
      }
    }
    return acc;
  }, [contents]);

  const filteredContents: Group[] = Object.entries(contentsByPath)
    .filter(([path, atoms]) =>
      createSearch(searchText, () => atoms[0].name)(path),
    )
    .map(([_, atoms]) => ({ atom: atoms[0], amount: atoms.length }));

  return (
    <Window height={250} width={190} title={`Contents: ${total - 1}`}>
      <Window.Content
        onKeyDown={(event) => {
          if (event.key === KEY.Enter && filteredContents.length > 0) {
            act('grab', { ref: filteredContents[0].atom.ref });
          }
          if (event.key === KEY.Escape) {
            Byond.sendMessage('close');
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
          <Flex wrap>
            {filteredContents.map((group, index) => (
              <Flex.Item key={index} m={1}>
                <SearchItem group={group} />
              </Flex.Item>
            ))}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
}
type SearchItemProps = {
  group: Group;
};

type Group = {
  atom: Atom;
  amount: number;
};

function SearchItem(props: SearchItemProps) {
  const { act } = useBackend();

  const {
    group: { atom, amount },
  } = props;

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
          <Icon name="spinner" size={2.4} spin color="gray" />
        ) : (
          <Image fixErrors src={atom.icon} />
        )}
        {amount > 1 && <div className="SearchItem--amount">{amount}</div>}
      </div>
    </Tooltip>
  );
}

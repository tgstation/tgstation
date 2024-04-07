import { BooleanLike } from 'common/react';
import { capitalizeAll, createSearch } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
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
};

type Atom = {
  image: string;
  name: string;
  ref: string;
};

export function LootPanel(props) {
  const { act, data } = useBackend<Data>();
  const { contents = [] } = data;

  const [searchText, setSearchText] = useState('');

  const filteredContents = contents.filter(
    createSearch(searchText, (atom) => atom.name),
  );

  return (
    <Window height={250} width={180} title="Contents">
      <Window.Content>
        <Section
          buttons={
            <Input
              autoFocus
              onInput={(event, value) => setSearchText(value)}
              placeholder="Search"
              width="11rem"
            />
          }
          fill
          scrollable
          title={<Icon name="search" />}
        >
          <Stack fill wrap>
            {filteredContents.map((atom, index) => (
              <Stack.Item key={index} m={1}>
                <Tooltip content={capitalizeAll(atom.name)}>
                  <Box
                    onClick={() => act('grab', { ref: atom.ref })}
                    style={{
                      border: 'thin solid #212121',
                      background: 'black',
                    }}
                  >
                    <Image src={atom.image} />
                  </Box>
                </Tooltip>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
}

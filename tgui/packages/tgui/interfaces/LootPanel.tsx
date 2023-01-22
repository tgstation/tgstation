import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Box, Icon, Input, Section, Stack, Tooltip } from '../components';
import { capitalizeAll, createSearch } from 'common/string';

type Data = {
  contents: Atom[];
};

type Atom = {
  ref: string;
  name: string;
  image: string;
};

export const LootPanel = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { contents = [] } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const filteredContents = contents.filter(
    createSearch(searchText, (atom: Atom) => atom.name)
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
          title={<Icon name="search" />}>
          <Stack fill wrap>
            {filteredContents.map((atom, index) => (
              <Stack.Item key={index} m={1}>
                <Tooltip content={capitalizeAll(atom.name)}>
                  <Box
                    onClick={() => act('grab', { ref: atom.ref })}
                    style={{
                      border: 'thin solid #212121',
                      background: 'black',
                    }}>
                    <img src={atom.image} />
                  </Box>
                </Tooltip>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

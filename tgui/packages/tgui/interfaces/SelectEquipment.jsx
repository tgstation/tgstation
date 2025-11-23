import { sortBy, uniq } from 'es-toolkit';
import { filter, map } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Image,
  Input,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';

// here's an important mental define:
// custom outfits give a ref keyword instead of path
function getOutfitKey(outfit) {
  return outfit.path || outfit.ref;
}

export function SelectEquipment(props) {
  const { act, data } = useBackend();
  const { name, icon64, current_outfit, favorites } = data;

  const outfits = map([...data.outfits, ...data.custom_outfits], (entry) => ({
    ...entry,
    favorite: favorites?.includes(entry.path),
  }));

  // even if no custom outfits were sent, we still want to make sure there's
  // at least a 'Custom' tab so the button to create a new one pops up
  const categories = uniq([
    ...outfits.map((entry) => entry.category),
    'Custom',
  ]);
  const [tab, setTab] = useState(categories[0]);
  const [searchText, setSearchText] = useState('');
  const searchFilter = createSearch(
    searchText,
    (entry) => entry.name + entry.path,
  );

  const visibleOutfits = sortBy(
    filter(
      filter(outfits, (entry) => entry.category === tab),
      searchFilter,
    ),
    [
      (entry) => !entry.favorite,
      (entry) => !entry.priority,
      (entry) => entry.name,
    ],
  );

  const currentOutfitEntry = outfits.find(
    (outfit) => getOutfitKey(outfit) === current_outfit,
  );

  return (
    <Window width={650} height={415} theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item>
            <Stack fill vertical>
              <Stack.Item>
                <Input
                  fluid
                  autoFocus
                  placeholder="Search"
                  value={searchText}
                  onChange={setSearchText}
                />
              </Stack.Item>
              <Stack.Item>
                <DisplayTabs
                  categories={categories}
                  tab={tab}
                  onSelect={setTab}
                />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <OutfitDisplay entries={visibleOutfits} currentTab={tab} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack fill vertical>
              <Stack.Item>
                <Section>
                  <CurrentlySelectedDisplay entry={currentOutfitEntry} />
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section fill title={name} textAlign="center">
                  <Image
                    m={0}
                    src={`data:image/jpeg;base64,${icon64}`}
                    height="100%"
                  />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function DisplayTabs(props) {
  const { categories, tab, onSelect } = props;

  return (
    <Tabs textAlign="center">
      {categories.map((category) => (
        <Tabs.Tab
          key={category}
          selected={tab === category}
          onClick={() => onSelect(category)}
        >
          {category}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
}

function OutfitDisplay(props) {
  const { act, data } = useBackend();
  const { current_outfit, categories } = data;
  const { entries, currentTab } = props;

  return (
    <Section fill scrollable>
      {entries.map((entry) => (
        <Button
          key={getOutfitKey(entry)}
          fluid
          ellipsis
          icon={entry.favorite && 'star'}
          iconColor="gold"
          content={entry.name}
          title={entry.path || entry.name}
          selected={getOutfitKey(entry) === current_outfit}
          onClick={() =>
            act('preview', {
              path: getOutfitKey(entry),
            })
          }
          onDoubleClick={() =>
            act('applyoutfit', {
              path: getOutfitKey(entry),
            })
          }
        />
      ))}
      {currentTab === 'Custom' && (
        <Button
          color="transparent"
          icon="plus"
          fluid
          onClick={() => act('customoutfit')}
        >
          Create a custom outfit...
        </Button>
      )}
    </Section>
  );
}

function CurrentlySelectedDisplay(props) {
  const { act, data } = useBackend();
  const { current_outfit } = data;
  const { entry } = props;

  return (
    <Stack align="center">
      {entry?.path && (
        <Stack.Item>
          <Icon
            size={1.6}
            name={entry.favorite ? 'star' : 'star-o'}
            color="gold"
            style={{ cursor: 'pointer' }}
            onClick={() =>
              act('togglefavorite', {
                path: entry.path,
              })
            }
          />
        </Stack.Item>
      )}
      <Stack.Item grow basis={0}>
        <Box color="label">Currently selected:</Box>
        <Box
          title={entry?.path}
          style={{
            overflow: 'hidden',
            whiteSpace: 'nowrap',
            textOverflow: 'ellipsis',
          }}
        >
          {entry?.name}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          mr={0.8}
          lineHeight={2}
          color="green"
          onClick={() =>
            act('applyoutfit', {
              path: current_outfit,
            })
          }
        >
          Confirm
        </Button>
      </Stack.Item>
    </Stack>
  );
}

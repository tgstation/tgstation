import { paginate } from 'common/collections';
import { createContext, useContext, useState } from 'react';
import {
  Button,
  Icon,
  Input,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const CATEGORY_PAGE_ITEMS = 4;
const EVENT_PAGE_ITEMS = 2;
const EVENT_PAGE_MAXCHARS = 48;

/**
 * Same as paginate, but respecting event names with a character max length
 * that will also create a new page if created
 */
function paginateEvents(events: Event[], maxPerPage: number): Event[][] {
  const pages: Event[][] = [];
  let page: Event[] = [];
  // conditions that make a new page
  let itemsToAdd = maxPerPage;
  let maxChars = EVENT_PAGE_MAXCHARS;

  for (const event of events) {
    if (event.name && typeof event.name === 'string') {
      maxChars -= event.name.length;
      if (maxChars <= 0) {
        // would overflow the next line over
        itemsToAdd = maxPerPage;
        maxChars = EVENT_PAGE_MAXCHARS - event.name.length;
        pages.push(page);
        page = [];
      }
    }
    page.push(event);
    itemsToAdd--;
    if (!itemsToAdd) {
      // max amount of items we allow
      itemsToAdd = maxPerPage;
      maxChars = EVENT_PAGE_MAXCHARS;
      pages.push(page);
      page = [];
    }
  }
  if (page.length) {
    pages.push(page);
  }
  return pages;
}

type Event = {
  name: string;
  description: string;
  type: string;
  category: string;
  has_customization: BooleanLike;
};

type Category = {
  name: string;
  icon: string;
};

type ForceEventData = {
  categories: Category[];
  events: Event[];
};

export function ForceEvent(props) {
  const { data } = useBackend<ForceEventData>();
  const { categories } = data;

  const announceState = useState(true);
  const categoryState = useState(categories[0]);
  const searchQueryState = useState('');

  return (
    <Window theme="admin" title="Force Event" width={450} height={450}>
      <Window.Content>
        <ForceEventContext.Provider
          value={{ announceState, categoryState, searchQueryState }}
        >
          <Stack vertical fill>
            <Stack.Item>
              <EventTabs />
            </Stack.Item>
            <Stack.Item grow>
              <EventSection />
            </Stack.Item>
          </Stack>
        </ForceEventContext.Provider>
      </Window.Content>
    </Window>
  );
}

function PanelOptions(props) {
  const { searchQueryState, announceState } = useForceEventContext();

  const [searchQuery, setSearchQuery] = searchQueryState;

  const [announce, setAnnounce] = announceState;

  return (
    <Stack width="240px">
      <Stack.Item>
        <Icon name="search" />
      </Stack.Item>
      <Stack.Item grow>
        <Input
          autoFocus
          fluid
          onChange={setSearchQuery}
          placeholder="Search..."
          value={searchQuery}
          expensive
        />
      </Stack.Item>
      <Stack.Item>
        <Button.Checkbox
          fluid
          checked={announce}
          onClick={() => setAnnounce(!announce)}
        >
          Announce
        </Button.Checkbox>
      </Stack.Item>
    </Stack>
  );
}

function EventSection(props) {
  const { data, act } = useBackend<ForceEventData>();
  const { events } = data;

  const { categoryState, searchQueryState, announceState } =
    useForceEventContext();

  const [category] = categoryState;
  const [searchQuery] = searchQueryState;
  const [announce] = announceState;

  const preparedEvents = paginateEvents(
    events.filter((event) => {
      // remove events not in the category you're looking at
      if (!searchQuery && event.category !== category.name) {
        return false;
      }
      // remove events not being searched for, if a search is active
      if (
        searchQuery &&
        event.name &&
        typeof event.name === 'string' &&
        searchQuery &&
        typeof searchQuery === 'string' &&
        !event.name.toLowerCase().includes(searchQuery.toLowerCase())
      ) {
        return false;
      }
      return true;
    }),
    EVENT_PAGE_ITEMS,
  );

  const sectionTitle = searchQuery ? 'Searching...' : category.name + ' Events';

  return (
    <Section scrollable fill title={sectionTitle} buttons={<PanelOptions />}>
      <Stack vertical>
        {preparedEvents.map((eventPage, i) => (
          <Stack.Item key={i}>
            <Stack>
              {eventPage.map((event) => (
                <Stack.Item grow key={event.type}>
                  <Button
                    className="Button__rightIcon"
                    tooltip={
                      event.description +
                      (event.has_customization
                        ? ' Includes admin customization.'
                        : '')
                    }
                    fluid
                    icon={event.has_customization ? 'gear' : undefined}
                    iconPosition="right"
                    onClick={() =>
                      act('forceevent', {
                        type: event.type,
                        announce: announce,
                      })
                    }
                  >
                    {event.name}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

function EventTabs(props) {
  const { data } = useBackend<ForceEventData>();
  const { categories } = data;

  const { categoryState } = useForceEventContext();
  const [category, setCategory] = categoryState;

  const layerCats = paginate(categories, CATEGORY_PAGE_ITEMS);

  return (
    <Section mb="-6px">
      {layerCats.map((page, i) => (
        <Tabs mb="-3px" fluid key={i}>
          {page.map((cat) => (
            <Tabs.Tab
              selected={category === cat}
              icon={cat.icon}
              key={cat.icon}
              onClick={() => setCategory(cat)}
            >
              {cat.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      ))}
    </Section>
  );
}

type ForceEventContextType = {
  announceState: [boolean, (value: boolean) => void];
  categoryState: [Category, (value: Category) => void];
  searchQueryState: [string, (value: string) => void];
};

const ForceEventContext = createContext<ForceEventContextType>({
  announceState: [true, () => {}],
  categoryState: [{ icon: '', name: '' }, () => {}],
  searchQueryState: ['', () => {}],
});

/** Local state hook for ForceEvent */
function useForceEventContext() {
  return useContext(ForceEventContext);
}

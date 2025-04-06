import { sortBy } from 'common/collections';
import { useState } from 'react';
import { Flex, Input, Section, Tabs, VirtualList } from 'tgui-core/components';

import { useRemappedBackend } from './helpers';
import { TechNode } from './nodes/TechNode';

enum Tab {
  RESEARCHED,
  AVAILABLE,
  FUTURE,
}

export function TechwebOverview(props) {
  const { data } = useRemappedBackend();
  const { nodes, node_cache, design_cache } = data;
  const [tabIndex, setTabIndex] = useState(Tab.AVAILABLE);
  const [searchText, setSearchText] = useState('');

  // Only search when 3 or more characters have been input
  const searching = searchText && searchText.trim().length > 1;

  let displayedNodes = nodes;
  if (searching) {
    displayedNodes = displayedNodes.filter((x) => {
      const n = node_cache[x.id];
      return (
        n.name.toLowerCase().includes(searchText) ||
        n.description.toLowerCase().includes(searchText) ||
        n.design_ids.some((e) =>
          design_cache[e].name.toLowerCase().includes(searchText),
        )
      );
    });
  } else {
    displayedNodes = sortBy(
      tabIndex < 2
        ? nodes.filter((x) => x.tier === tabIndex)
        : nodes.filter((x) => x.tier >= tabIndex),
      (x) => node_cache[x.id].name,
    );
  }

  function switchTab(tab) {
    setTabIndex(tab);
    setSearchText('');
  }

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Web View
          </Flex.Item>
          <Flex.Item grow>
            <Tabs>
              <Tabs.Tab
                selected={!searching && tabIndex === Tab.RESEARCHED}
                onClick={() => switchTab(0)}
              >
                Researched
              </Tabs.Tab>
              <Tabs.Tab
                selected={!searching && tabIndex === Tab.AVAILABLE}
                onClick={() => switchTab(1)}
              >
                Available
              </Tabs.Tab>
              <Tabs.Tab
                selected={!searching && tabIndex === Tab.FUTURE}
                onClick={() => switchTab(2)}
              >
                Future
              </Tabs.Tab>
              {!!searching && <Tabs.Tab selected>Search Results</Tabs.Tab>}
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            <Input
              value={searchText}
              onInput={(e, value) => setSearchText(value)}
              placeholder="Search..."
            />
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__OverviewNodes" height="100%">
        <Section fill scrollable>
          <VirtualList>
            {displayedNodes.map((n) => (
              <TechNode node={n} key={n.id} />
            ))}
          </VirtualList>
        </Section>
      </Flex.Item>
    </Flex>
  );
}

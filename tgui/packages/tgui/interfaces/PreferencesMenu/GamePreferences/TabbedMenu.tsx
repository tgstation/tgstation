import { type ReactNode, useState } from 'react';
import { Input, Section, Stack, Tabs } from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';

import type { PreferenceChild } from './GamePreferencesPage';

type PreferencesTabsProps = {
  buttons?: ReactNode;
  categories: [string, PreferenceChild[]][];
};

export function TabbedMenu(props: PreferencesTabsProps) {
  const { buttons, categories } = props;

  const [selectedCategory, setSelectedCategory] = useState(categories[0][0]);
  const categoryContent = categories.find(
    ([category]) => category === selectedCategory,
  )?.[1];

  const allPrefsNames = categories.flatMap(([_, children]) =>
    children.map((child) => child.name),
  );
  const { query, setQuery, results } = useFuzzySearch({
    searchArray: allPrefsNames,
    matchStrategy: 'smart',
    getSearchString: (name) => name,
  });

  return (
    <Stack fill vertical g={0} fontSize={1.25}>
      <Stack.Item className="PreferencesMenu__Section">
        <Section
          fill
          fitted
          title={
            <Stack fill>
              <Stack.Item className="PreferencesMenu__SectionSearch">
                <Input
                  expensive
                  value={query}
                  width={22.5}
                  placeholder="Поиск по всем настройкам..."
                  onChange={setQuery}
                />
              </Stack.Item>
              <Stack.Item grow>
                {query
                  ? `Результаты поиска: ${results.length}`
                  : selectedCategory}
              </Stack.Item>
            </Stack>
          }
        />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill g={0}>
          <Stack.Item basis={13} className="PreferencesMenu__Section Sidebar">
            <Section fill fontSize={1.2}>
              <Stack fill vertical>
                <Stack.Item grow>
                  <Tabs vertical>
                    {categories.map(([category]) => (
                      <Tabs.Tab
                        key={category}
                        selected={!query && category === selectedCategory}
                        onClick={() => setSelectedCategory(category)}
                      >
                        {category}
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Stack.Item>
                <Stack.Item>{buttons}</Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow className="PreferencesMenu__Content">
            <Section fill scrollable>
              <Stack vertical>
                {query
                  ? categories.flatMap(([category, children]) =>
                      children
                        .filter((child) => results.includes(child.name))
                        .map((child) => child.children),
                    )
                  : categoryContent?.map((child) => child.children)}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

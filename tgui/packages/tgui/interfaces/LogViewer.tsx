import { useBackend, useLocalState } from '../backend';
import { Button, Collapsible, Input, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

type LogViewerData = {
  round_id: number;
  logging_start_timestamp: string;
  tree: LogViewerCategoryTree;
  last_data_update: number;
  categories: Record<string, LogViewerCategoryData>;
};

type LogViewerCategoryTree = {
  enabled: string[];
  disabled: string[];
};

type LogViewerCategoryData = {
  entry_count: number;
  entries: LogEntryData[];
};

type LogEntryData = {
  id: number;
  message: string;
  timestamp: string;
  semver?: Record<string, string>;
  data?: any[];
};

export const LogViewer = (_: any, context: any) => {
  const { data, act } = useBackend<LogViewerData>(context);

  const [activeCategory, setActiveCategory] = useLocalState(
    context,
    'activeCategory',
    ''
  );

  return (
    <Window width={720} height={720}>
      <Window.Content scrollable>
        <Section>
          <Button icon="sync" onClick={() => act('refresh')} />
        </Section>
        <CategoryBar
          options={data.tree.enabled}
          active={activeCategory}
          setActive={setActiveCategory}
        />
        <CategoryViewer
          activeCategory={activeCategory}
          data={data.categories[activeCategory]}
        />
      </Window.Content>
    </Window>
  );
};

type CategoryBarProps = {
  options: string[];
  active: string;
  setActive: (active: string) => void;
};

const CategoryBar = (props: CategoryBarProps, context: any) => {
  const sorted = [...props.options].sort();
  const [categorySearch, setCategorySearch] = useLocalState(
    context,
    'categorySearch',
    ''
  );

  return (
    <Section
      title="Categories"
      scrollableHorizontal
      buttons={
        <Input
          grow
          placeholder="Search"
          value={categorySearch}
          onChange={(_: any, value: string) => setCategorySearch(value)}
        />
      }>
      <Stack scrollableHorizontal>
        {sorted.map((category) => {
          if (!category.toLowerCase().includes(categorySearch.toLowerCase())) {
            return null;
          }
          return (
            <Stack.Item key={category}>
              <Button
                textAlign="left"
                content={category}
                selected={category === props.active}
                onClick={() => props.setActive(category)}
              />
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );
};

type CategoryViewerProps = {
  activeCategory: string;
  data?: LogViewerCategoryData;
};

const validateRegExp = (str: string) => {
  try {
    new RegExp(str);
    return true;
  } catch (e) {
    return false;
  }
};

const CategoryViewer = (props: CategoryViewerProps, context: any) => {
  const [search, setSearch] = useLocalState(context, 'search', '');
  let [searchRegex, setSearchRegex] = useLocalState(
    context,
    'searchRegex',
    false
  );
  if (!search && searchRegex) {
    setSearchRegex(false);
    searchRegex = false;
  }

  return (
    <Section
      title={`Category Viewer${
        props.activeCategory
          ? ` - ${props.activeCategory}[${props.data?.entry_count}]`
          : ''
      }`}
      buttons={
        <>
          <Input
            grow
            fill
            placeholder="Search"
            value={search}
            onChange={(_: any, value: string) => setSearch(value)}
          />
          <Button
            icon={searchRegex ? 'check-square' : 'square'}
            content="Regex"
            selected={searchRegex}
            onClick={() => setSearchRegex(!searchRegex)}
          />
          <Button
            icon="trash"
            content="Clear"
            onClick={() => {
              setSearch('');
              setSearchRegex(false);
            }}
          />
        </>
      }>
      <Stack vertical>
        {!searchRegex || validateRegExp(search) ? (
          props.data?.entries.map((entry) => {
            if (search) {
              if (searchRegex) {
                try {
                  const regex = new RegExp(search);
                  if (!regex.test(entry.message)) {
                    return null;
                  }
                } catch (e) {
                  return <NoticeBox danger>RegEx failure</NoticeBox>;
                }
              } else {
                if (!entry.message.includes(search)) {
                  return null;
                }
              }
            }

            return (
              <>
                <Stack.Item key={entry.id}>
                  <Collapsible
                    fitted
                    tooltip={entry.timestamp}
                    title={`[${entry.id}] - ${entry.message.substring(0, 50)}${
                      entry.message.length > 50 ? '...' : ''
                    }`}>
                    <Stack vertical fill>
                      <Stack.Item>
                        <p font-family="Courier">{entry.message}</p>
                      </Stack.Item>
                      <Stack.Item>
                        {entry.semver && (
                          <Stack.Item>
                            <JsonViewer data={entry.semver} title="Semver" />
                          </Stack.Item>
                        )}
                      </Stack.Item>
                      {entry.data && (
                        <Stack.Item>
                          <JsonViewer data={entry.data} title="Data" />
                        </Stack.Item>
                      )}
                    </Stack>
                  </Collapsible>
                </Stack.Item>
                <Stack.Divider />
              </>
            );
          })
        ) : (
          <NoticeBox danger>Invalid RegEx</NoticeBox>
        )}
      </Stack>
    </Section>
  );
};

const JsonViewer = (props: { data: any; title: string }) => {
  return (
    <Collapsible title={props.title}>
      <pre>{JSON.stringify(props.data, null, 2)}</pre>
    </Collapsible>
  );
};

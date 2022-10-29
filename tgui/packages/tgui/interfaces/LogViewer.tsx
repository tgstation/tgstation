import { useBackend, useLocalState } from '../backend';
import { Button, Dropdown, Flex, Input, Section } from '../components';
import { Window } from '../layouts';

type LogEntry = {
  key: number;
  text: string;
  version: string;
  unix_timestamp: number;
  world_timestamp: number;
  round_id: number;
  server_name: string;
  category: string;
  message: string;
  private: boolean;
  location?: number[];
  tags?: string[];
  source_name?: string;
  source_ckey?: string;
  target_name?: string;
  target_ckey?: string;
  extended_data?: {};
};

type LogCategory = {
  [key: string]: LogEntry;
};

type LogEntries = {
  [key: string]: LogCategory;
};

type LogViewerData = {
  entries: LogEntries;
};

enum FilterType {
  None = 'None',
  CKey = 'CKey',
  Name = 'Name',
  Message = 'Message',
}

enum FilterFlags {
  None = 0,
  CaseSensitive = 1,
  ExactMatch = 2,
  Regex = 4,
}

export const LogViewer = (props: any, context: any) => {
  const { act, data } = useBackend<LogViewerData>(context);
  const { entries } = data;
  const categories = Object.keys(entries);
  const [selectedCategory, setSelectedCategory] = useLocalState<string | null>(
    context,
    'selectedCategory',
    null
  );
  const [filterType, setFilter] = useLocalState(
    context,
    'filter',
    FilterType.None
  );
  const [filterText, setFilterText] = useLocalState(context, 'filterText', '');
  const [filterFlags, setFilterFlags] = useLocalState(
    context,
    'filterFlags',
    FilterFlags.None
  );
  const [displayFilterOptions, setDisplayFilterOptions] = useLocalState(
    context,
    'displayFilterOptions',
    false
  );
  const [selectedEntry, setSelectedEntry] = useLocalState<LogEntry | null>(
    context,
    'selectedEntry',
    null
  );

  const updateSelectedCategory = (category: string) => {
    setSelectedEntry(null);
    setSelectedCategory(category);
  };
  const updateFilterType = (type: FilterType) => {
    if (type === FilterType.None) {
      setFilterText('');
    }
    setFilter(type);
  };

  let filtered_entries: LogEntry[] | null = null;
  let entriesList: LogEntry[] = [];
  if (selectedCategory) {
    const categoryEntries = entries[selectedCategory];
    const entryKeys = Object.keys(categoryEntries);
    entriesList = entryKeys.map((key) => KeyToEntry(key, categoryEntries));

    filtered_entries = filter_entries(
      entriesList,
      filterType,
      filterText,
      filterFlags
    );
  }

  return (
    <Window
      width={800}
      height={600}
      title="Log Viewer"
      theme="admin"
      buttons={
        <>
          <Button
            icon="filter"
            tooltip={displayFilterOptions ? 'Enable Filter' : 'Disable Filter'}
            tooltipPosition="bottom"
            color={displayFilterOptions ? 'good' : 'average'}
            onClick={() => {
              setDisplayFilterOptions(!displayFilterOptions);
              setFilter(FilterType.None);
              setFilterText('');
              setFilterFlags(FilterFlags.None);
            }}
          />
          <Button
            icon="sync"
            tooltip="Refresh"
            tooltipPosition="bottom"
            color="good"
            onClick={() => act('refresh')}
          />
        </>
      }>
      <Window.Content scrollable>
        {displayFilterOptions && (
          <FilterOptions
            type={filterType}
            text={filterText}
            flags={filterFlags}
            onTypeChange={(type) => updateFilterType(type)}
            onTextChange={(text) => setFilterText(text)}
            onFlagsChange={(flags) => setFilterFlags(flags)}
          />
        )}
        <LogCategoryBar
          categories={categories}
          selectedCategory={selectedCategory}
          onCategoryChange={updateSelectedCategory}
        />
        {selectedCategory && <LogViewerContent entries={filtered_entries!} />}
      </Window.Content>
    </Window>
  );
};

const KeyToEntry = (key: string, entryMap): LogEntry => {
  return entryMap[key];
};

type FilterOptionsProps = {
  type: FilterType;
  text: string;
  flags: FilterFlags;
  onTypeChange: (type: FilterType) => void;
  onTextChange: (text: string) => void;
  onFlagsChange: (flags: FilterFlags) => void;
};

const FilterOptions = (props: FilterOptionsProps, context: any) => {
  const { type, text, flags, onTypeChange, onTextChange, onFlagsChange } =
    props;

  return (
    <Section
      title="Filter Options"
      buttons={
        <>
          <Button
            icon="angles-up"
            tooltip="Case Sensitive"
            tooltipPosition="bottom"
            color={flags & FilterFlags.CaseSensitive ? 'good' : 'average'}
            disabled={type === FilterType.None}
            onClick={() => {
              onFlagsChange(flags ^ FilterFlags.CaseSensitive);
            }}
          />
          <Button
            icon="equals"
            tooltip="Exact Match"
            tooltipPosition="bottom"
            color={flags & FilterFlags.ExactMatch ? 'good' : 'average'}
            disabled={type === FilterType.None}
            onClick={() => {
              onFlagsChange(flags ^ FilterFlags.ExactMatch);
            }}
          />
          <Button
            icon="asterisk"
            tooltip="Regex"
            tooltipPosition="bottom"
            color={flags & FilterFlags.Regex ? 'good' : 'average'}
            disabled={type === FilterType.None}
            onClick={() => {
              onFlagsChange(flags ^ FilterFlags.Regex);
            }}
          />
        </>
      }>
      <Flex direction="column">
        <Flex.Item>
          <Dropdown
            width="200px"
            options={Object.values(FilterType)}
            selected={type}
            onSelected={onTypeChange}
          />
        </Flex.Item>
        {type !== FilterType.None && (
          <>
            <br />
            <Flex.Item>
              <Input
                fluid
                value={text}
                placeholder={flags & FilterFlags.Regex ? 'Regex' : 'Filter'}
                onInput={(_, value) => onTextChange(value)}
              />
            </Flex.Item>
          </>
        )}
      </Flex>
    </Section>
  );
};

type LogCategoryBarProps = {
  categories: string[];
  selectedCategory: string | null;
  onCategoryChange: (category: string) => void;
};

const LogCategoryBar = (props: LogCategoryBarProps, context: any) => {
  const { categories, selectedCategory, onCategoryChange } = props;

  return (
    <Section>
      <Flex wrap="wrap">
        {categories.map((category) => (
          <Flex.Item key={category}>
            <Button
              fluid
              selected={category === selectedCategory}
              onClick={() => onCategoryChange(category)}>
              {category}
            </Button>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

type LogViewerContentProps = {
  entries: LogEntry[];
};

const LogViewerContent = (props: LogViewerContentProps, context: any) => {
  const { act } = useBackend(context);
  const { entries } = props;
  return (
    <Section fluid scrollable title={entries.length + ' Entries'}>
      <Flex direction="column">
        {entries.map((entry) => (
          <Flex.Item key={entry.key}>
            <Button
              icon="file-alt"
              tooltip="Inspect"
              tooltipPosition="bottom"
              color="average"
              onClick={() => act('inspect', { entry: entry.key })}
            />
            - {entry.text}
            <br />
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const filter_entries = (
  entries: LogEntry[],
  filter: FilterType,
  filterText: string,
  filterFlags: FilterFlags
) => {
  if (filter === FilterType.None) {
    return entries;
  }

  const regex = new RegExp(
    filterText,
    filterFlags & FilterFlags.CaseSensitive ? '' : 'i'
  );

  return entries.filter((entry) => {
    let text: string | undefined = '';
    switch (filter) {
      case FilterType.CKey:
        text = entry.source_ckey;
        break;
      case FilterType.Name:
        text = entry.source_name;
        break;
      case FilterType.Message:
        text = entry.message;
        break;
    }

    if (!text) {
      return false;
    }

    if (filterFlags & FilterFlags.Regex) {
      const match = text.match(regex);
      if (filterFlags & FilterFlags.ExactMatch) {
        return match && match[0] === text;
      }
      return !!match;
    }

    if (filterFlags & FilterFlags.ExactMatch) {
      return text === filterText;
    }

    return text.includes(filterText);
  });
};

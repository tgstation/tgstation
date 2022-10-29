import { useBackend, useLocalState } from '../backend';
import { Button, Dropdown, Flex, Input, Section } from '../components';
import { SectionProps } from '../components/Section';
import { Window } from '../layouts';

type LogEntry = {
  key: string;
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

  const [extendedTarget, setExtendedTarget] = useLocalState<string | null>(
    context,
    'extendedTarget',
    null
  );

  return (
    <Window
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
      <Window.Content fitted>
        <Flex direction="column" height="100%">
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
            onCategoryChange={setSelectedCategory}
          />
          {selectedCategory && (
            <LogViewerContent
              fill
              scrollable
              entries={filtered_entries!}
              extendedTarget={extendedTarget}
              setExtendedTarget={setExtendedTarget}
            />
          )}
        </Flex>
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
  const { categories, selectedCategory, onCategoryChange, ...rest } = props;

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

type LogViewerContentProps = SectionProps & {
  entries: LogEntry[];
  extendedTarget: string | null;
  setExtendedTarget?: (target: string | null) => void;
};

const LogViewerContent = (props: LogViewerContentProps, context: any) => {
  const { act } = useBackend(context);
  const { entries, extendedTarget, setExtendedTarget, ...rest } = props;
  return (
    <Section title={entries.length + ' Entries'} {...rest}>
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
            <Button
              icon="question"
              tooltip="More Info"
              tooltipPosition="bottom"
              color={extendedTarget === entry.key ? 'good' : 'average'}
              disabled={
                !entry.extended_data ||
                Object.keys(entry.extended_data).length === 0
              }
              onClick={() => {
                if (extendedTarget === entry.key) {
                  setExtendedTarget!(null);
                } else {
                  setExtendedTarget!(entry.key);
                }
              }}
            />
            &nbsp;{entry.text}
            {extendedTarget === entry.key && <RecursiveData data={entry} />}
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const RecursiveData = (props: any, context: any) => {
  const { data, inner_level } = props;
  const level = inner_level || 1;
  const inner = (
    <Flex direction="column">
      {Object.entries(data).map(([key, value]) => {
        if (typeof value === 'object' && value !== null) {
          return (
            <Flex.Item key={key}>
              <b>{key}:</b>
              <RecursiveData data={value} inner_level={level + 1} />
            </Flex.Item>
          );
        }
        return (
          <Flex.Item key={key}>
            {'-'.repeat(level)}&nbsp;
            <b>{key}</b>: {value || 'null'}
          </Flex.Item>
        );
      })}
    </Flex>
  );
  return !inner_level ? (
    <Section title="Extended Data">{inner}</Section>
  ) : (
    inner
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

    if (!(filterFlags & FilterFlags.CaseSensitive)) {
      text = text.toLowerCase();
      filterText = filterText.toLowerCase();
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

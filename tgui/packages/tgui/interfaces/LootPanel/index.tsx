import { useState } from 'react';
import { useMemo } from 'react';
import { Button, Input, Section, Stack } from 'tgui-core/components';
import { isEscape } from 'tgui-core/keys';
import { clamp } from 'tgui-core/math';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { GroupedContents } from './GroupedContents';
import { RawContents } from './RawContents';
import { SearchItem } from './types';

type Data = {
  contents: SearchItem[];
  searching: BooleanLike;
};

export function LootPanel(props) {
  const { act, data } = useBackend<Data>();
  const { contents = [], searching } = data;

  // limitations: items with different stack counts, charges etc.
  const contentsByPathName = useMemo(() => {
    const acc: Record<string, SearchItem[]> = {};

    for (let i = 0; i < contents.length; i++) {
      const item = contents[i];
      if (item.path) {
        if (!acc[item.path + item.name]) {
          acc[item.path + item.name] = [];
        }
        acc[item.path + item.name].push(item);
      } else {
        acc[item.ref] = [item];
      }
    }
    return acc;
  }, [contents]);

  const [grouping, setGrouping] = useState(true);
  const [searchText, setSearchText] = useState('');

  const headerHeight = 38;
  const itemHeight = 38;
  const minHeight = headerHeight + itemHeight;
  const maxHeight = headerHeight + itemHeight * 10;
  const height: number = clamp(
    headerHeight +
      (!grouping ? contents.length : Object.keys(contentsByPathName).length) *
        itemHeight,
    minHeight,
    maxHeight,
  );

  return (
    <Window
      width={300}
      height={height}
      buttons={
        <Stack align="center">
          <Input
            onChange={setSearchText}
            placeholder="Search items..."
            value={searchText}
            expensive
          />
          <Button
            m={0}
            icon={grouping ? 'layer-group' : 'object-ungroup'}
            selected={grouping}
            onClick={() => setGrouping(!grouping)}
            tooltip="Toggle Grouping"
          />
          <Button
            icon="sync"
            onClick={() => act('refresh')}
            tooltip="Refresh"
          />
        </Stack>
      }
    >
      <Window.Content
        fitted
        scrollable={height === maxHeight}
        onKeyDown={(event) => {
          if (isEscape(event.key)) {
            Byond.sendMessage('close');
          }
        }}
      >
        <Section>
          {grouping ? (
            <GroupedContents
              contents={contentsByPathName}
              searchText={searchText}
            />
          ) : (
            <RawContents contents={contents} searchText={searchText} />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
}

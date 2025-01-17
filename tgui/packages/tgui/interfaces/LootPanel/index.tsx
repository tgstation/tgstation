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
  const contentsByPath = useMemo(() => {
    const acc: Record<string, SearchItem[]> = {};

    for (let i = 0; i < contents.length; i++) {
      const item = contents[i];
      if (item.path) {
        if (!acc[item.path]) {
          acc[item.path] = [];
        }
        acc[item.path].push(item);
      } else {
        acc[item.ref] = [item];
      }
    }
    return acc;
  }, [contents]);

  const [grouping, setGrouping] = useState(true);
  const [searchText, setSearchText] = useState('');

  const total = contents.length ? contents.length - 1 : 0;

  const minHeight = 126;
  const maxHeight = 660;
  const headerHeight = 88;
  const itemHeight = 38;
  const height: number = clamp(
    headerHeight +
      (!grouping ? contents.length : Object.keys(contentsByPath).length) *
        itemHeight,
    minHeight,
    maxHeight,
  );

  return (
    <Window width={300} height={height} title={`Contents: ${total}`}>
      <Window.Content
        onKeyDown={(event) => {
          if (isEscape(event.key)) {
            Byond.sendMessage('close');
          }
        }}
      >
        <Section
          scrollable={height === maxHeight}
          fill
          title={
            <Stack>
              <Stack.Item grow>
                <Input
                  fluid
                  onInput={(event, value) => setSearchText(value)}
                  placeholder="Search"
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={grouping ? 'layer-group' : 'object-ungroup'}
                  selected={grouping}
                  onClick={() => setGrouping(!grouping)}
                  tooltip="Toggle Grouping"
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  disabled={!!searching}
                  icon="sync"
                  onClick={() => act('refresh')}
                  tooltip="Refresh"
                />
              </Stack.Item>
            </Stack>
          }
        >
          {grouping ? (
            <GroupedContents
              contents={contentsByPath}
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

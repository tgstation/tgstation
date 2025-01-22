import { useState } from 'react';
import { useMemo } from 'react';
import { Box, Button, Section } from 'tgui-core/components';
import { isEscape } from 'tgui-core/keys';
import { clamp } from 'tgui-core/math';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { GroupedContents } from './GroupedContents';
import { RawContents } from './RawContents';
import { SearchItem } from './types';

type Data = {
  contents: SearchItem[];
};

export function LootPanel(props) {
  const { act, data } = useBackend<Data>();
  const { contents = [] } = data;

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

  const total = contents.length ? contents.length - 1 : 0;

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
      title={`Contents: ${total}`}
      buttons={
        <Box align={'left'}>
          <Button
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
        </Box>
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
            <GroupedContents contents={contentsByPathName} />
          ) : (
            <RawContents contents={contents} />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
}

import { KEY } from 'common/keys';
import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../../backend';
import { Button, Input, Section, Stack } from '../../components';
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

  const [grouping, setGrouping] = useState(true);
  const [searchText, setSearchText] = useState('');

  const total = contents.length ? contents.length - 1 : 0;

  return (
    <Window height={275} width={190} title={`Contents: ${total}`}>
      <Window.Content
        onKeyDown={(event) => {
          if (event.key === KEY.Escape) {
            Byond.sendMessage('close');
          }
        }}
      >
        <Section
          fill
          scrollable
          title={
            <Stack>
              <Stack.Item grow>
                <Input
                  autoFocus
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
            <GroupedContents contents={contents} searchText={searchText} />
          ) : (
            <RawContents contents={contents} searchText={searchText} />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
}

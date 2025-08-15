import { Button, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { IconDisplay } from './IconDisplay';
import type { SearchGroup, SearchItem } from './types';

type Data = {
  is_blind: BooleanLike;
};

type Props =
  | {
      item: SearchItem;
    }
  | {
      group: SearchGroup;
    };

export function LootBox(props: Props) {
  const { act, data } = useBackend<Data>();
  const { is_blind } = data;

  let amount = 0;
  let item: SearchItem;
  if ('group' in props) {
    amount = props.group.amount;
    item = props.group.item;
  } else {
    item = props.item;
  }

  const name = !item.name ? '???' : capitalizeFirst(item.name);

  const content = (
    <Button
      p={0}
      fluid
      color="transparent"
      onClick={(event) =>
        act('grab', {
          alt: event.altKey,
          ctrl: event.ctrlKey,
          ref: item.ref,
          shift: event.shiftKey,
        })
      }
      onContextMenu={(event) => {
        event.preventDefault();
        act('grab', {
          right: true,
          ref: item.ref,
        });
      }}
    >
      <Stack>
        <Stack.Item mb={-1} minWidth={'36px'} minHeight={'42px'}>
          <IconDisplay item={item} size={{ height: 3, width: 3 }} />
        </Stack.Item>
        <Stack.Item
          lineHeight="34px"
          overflow="hidden"
          style={{ textOverflow: 'ellipsis' }}
        >
          {!is_blind && name}
        </Stack.Item>
        <Stack.Item lineHeight="34px" pr={1}>
          {amount > 1 && `x${amount}`}
        </Stack.Item>
      </Stack>
    </Button>
  );

  if (is_blind) return content;

  return content;
}

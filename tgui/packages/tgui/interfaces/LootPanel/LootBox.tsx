import { BooleanLike } from 'common/react';
import { capitalizeAll, capitalizeFirst } from 'common/string';

import { useBackend } from '../../backend';
import { Tooltip } from '../../components';
import { IconDisplay } from './IconDisplay';
import { SearchGroup, SearchItem } from './types';

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

  const name = !item.name
    ? '???'
    : capitalizeFirst(item.name.split(' ')[0]).slice(0, 5);

  // So we can conditionally wrap tooltip
  const content = (
    <div className="SearchItem">
      <div
        className="SearchItem--box"
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
        <IconDisplay item={item} size={{ height: 3, width: 3 }} />
        {amount > 1 && <div className="SearchItem--amount">{amount}</div>}
      </div>
      {!is_blind && <span className="SearchItem--text">{name}</span>}
    </div>
  );

  if (is_blind) return content;

  return <Tooltip content={capitalizeAll(item.name)}>{content}</Tooltip>;
}

import { capitalizeAll } from 'common/string';

import { useBackend } from '../../backend';
import { Tooltip } from '../../components';
import { IconDisplay } from './IconDisplay';
import { SearchGroup, SearchItem } from './types';

type Props =
  | {
      item: SearchItem;
    }
  | {
      group: SearchGroup;
    };

export function LootBox(props: Props) {
  const { act } = useBackend();

  let amount = 0;
  let item: SearchItem;
  if ('group' in props) {
    amount = props.group.amount;
    item = props.group.item;
  } else {
    item = props.item;
  }

  return (
    <Tooltip content={capitalizeAll(item.name)}>
      <div
        className="SearchItem"
        onClick={(event) =>
          act('grab', {
            ctrl: event.ctrlKey,
            ref: item.ref,
            shift: event.shiftKey,
          })
        }
        onContextMenu={(event) => {
          event.preventDefault();
          act('grab', {
            middle: true,
            ref: item.ref,
            shift: true,
          });
        }}
      >
        <IconDisplay item={item} />
        {amount > 1 && <div className="SearchItem--amount">{amount}</div>}
      </div>
    </Tooltip>
  );
}

import { capitalizeAll, capitalizeFirst } from 'common/string';

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

  const name = !item.name
    ? '???'
    : capitalizeFirst(item.name.split(' ')[0]).slice(0, 5);

  return (
    <Tooltip content={capitalizeAll(item.name)}>
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
          <IconDisplay item={item} />
          {amount > 1 && <div className="SearchItem--amount">{amount}</div>}
        </div>
        <span className="SearchItem--text">{name}</span>
      </div>
    </Tooltip>
  );
}

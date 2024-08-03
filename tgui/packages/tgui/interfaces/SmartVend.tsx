import { BooleanLike } from 'common/react';
import { createSearch } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import { Button, ImageButton, Input, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

type Item = {
  path: string;
  name: string;
  amount: number;
  icon: string;
  icon_state: string;
};

type Data = {
  contents: Record<string, Item>;
  name: string;
  isdryer: BooleanLike;
  drying: BooleanLike;
  default_list_view: BooleanLike;
};

enum MODE {
  tile,
  list,
}

export const SmartVend = (props) => {
  const { act, data } = useBackend<Data>();
  const [searchText, setSearchText] = useState('');
  const [displayMode, setDisplayMode] = useState(
    data.default_list_view ? MODE.list : MODE.tile,
  );
  const search = createSearch(searchText, (item: Item) => item.name);
  const contents =
    searchText.length > 0
      ? Object.values(data.contents).filter(search)
      : Object.values(data.contents);

  return (
    <Window width={431} height={565}>
      <Window.Content>
        <Section
          fill
          scrollable
          title="Storage"
          buttons={
            data.isdryer ? (
              <Button
                icon={data.drying ? 'stop' : 'tint'}
                onClick={() => act('Dry')}
              >
                {data.drying ? 'Stop drying' : 'Dry'}
              </Button>
            ) : (
              <>
                <Input
                  autoFocus
                  placeholder={'Search...'}
                  value={searchText}
                  onInput={(e, value) => setSearchText(value)}
                />
                <Button
                  icon={displayMode === MODE.tile ? 'list' : 'border-all'}
                  tooltip={
                    displayMode === MODE.tile
                      ? 'Display as a list'
                      : 'Display as a grid'
                  }
                  tooltipPosition="bottom"
                  onClick={() =>
                    setDisplayMode(
                      displayMode === MODE.tile ? MODE.list : MODE.tile,
                    )
                  }
                />
                <Button
                  icon="question"
                  tooltip={
                    <span>
                      LMB - Vend 1 product
                      <br />
                      RMB - Vend custom amount
                    </span>
                  }
                  tooltipPosition="bottom-end"
                />
              </>
            )
          }
        >
          {!contents.length ? (
            <NoticeBox>Nothing found.</NoticeBox>
          ) : (
            contents.map((item) => {
              const vendAmount = (e) => {
                act('Release', {
                  path: item.path,
                  amount: item.amount,
                });
                e.stopPropagation();
              };

              return (
                <ImageButton
                  key={item.path}
                  fluid={displayMode === MODE.list}
                  imageSize={displayMode === MODE.list ? 32 : 64}
                  dmIcon={item.icon}
                  dmIconState={item.icon_state}
                  tooltip={displayMode === MODE.tile && item.name}
                  tooltipPosition="bottom"
                  textAlign="left"
                  disabled={item.amount < 1}
                  buttons={
                    displayMode === MODE.tile ? (
                      item.amount > 1 && (
                        <Button bold color="transparent" onClick={vendAmount}>
                          {item.amount}
                        </Button>
                      )
                    ) : (
                      <Button disabled={item.amount <= 1} onClick={vendAmount}>
                        Amount
                      </Button>
                    )
                  }
                  onClick={() =>
                    act('Release', {
                      path: item.path,
                      amount: 1,
                    })
                  }
                  onRightClick={vendAmount}
                >
                  <span>{item.name}</span>
                  {displayMode === MODE.list && (
                    <span>{`x${item.amount}`}</span>
                  )}
                </ImageButton>
              );
            })
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

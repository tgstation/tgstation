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
};

export const SmartVend = (props) => {
  const { act, data } = useBackend<Data>();
  const [searchText, setSearchText] = useState('');
  const search = createSearch(searchText, (item: Item) => item.name);
  const contents =
    searchText.length > 0
      ? Object.values(data.contents).filter(search)
      : Object.values(data.contents);

  return (
    <Window width={431} height={570}>
      <Window.Content>
        <Section
          fill
          scrollable
          style={{
            textTransform: 'capitalize',
          }}
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
              <Input
                autoFocus
                placeholder={'Search...'}
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
              />
            )
          }
        >
          {!contents.length ? (
            <NoticeBox>Nothing found.</NoticeBox>
          ) : (
            contents.map((item) => {
              const customAmount = (e) => {
                act('Release', {
                  path: item.path,
                  amount: item.amount,
                });
                e.stopPropagation();
              };

              return (
                <ImageButton
                  key={item.path}
                  dmIcon={item.icon}
                  dmIconState={item.icon_state}
                  tooltip={item.name}
                  tooltipPosition="bottom"
                  disabled={item.amount < 1}
                  onClick={() =>
                    act('Release', {
                      path: item.path,
                      amount: 1,
                    })
                  }
                  onRightClick={customAmount}
                  buttons={
                    item.amount > 1 && (
                      <Button
                        compact
                        color="transparent"
                        fontWeight="bold"
                        tooltip="Pick up custom amount"
                        tooltipPosition="top"
                        onClick={customAmount}
                      >
                        {item.amount}
                      </Button>
                    )
                  }
                >
                  {item.name}
                </ImageButton>
              );
            })
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

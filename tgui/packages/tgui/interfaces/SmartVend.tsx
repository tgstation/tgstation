import { BooleanLike } from 'common/react';
import { createSearch } from 'common/string';
import { useState } from 'react';
import { DmIcon, Icon } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Button, Input, NoticeBox, Section } from '../components';
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

  const fallback = (
    <Icon name="spinner" lineHeight="64px" size={3} spin color="gray" />
  );
  return (
    <Window width={498} height={550}>
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
            contents.map((item) => (
              <Button
                key={item.path}
                m={1}
                p={0}
                height="64px"
                width="64px"
                tooltip={item.name}
                tooltipPosition="bottom"
                textAlign="right"
                disabled={item.amount < 1}
                onClick={() =>
                  act('Release', {
                    path: item.path,
                    amount: 1,
                  })
                }
              >
                <DmIcon
                  fallback={fallback}
                  icon={item.icon}
                  icon_state={item.icon_state}
                  height="64px"
                  width="64px"
                />
                {item.amount > 1 && (
                  <Button
                    color="transparent"
                    minWidth="24px"
                    height="24px"
                    lineHeight="24px"
                    textAlign="center"
                    position="absolute"
                    left="0"
                    bottom="0"
                    fontWeight="bold"
                    fontSize="14px"
                    onClick={(e) => {
                      act('Release', {
                        path: item.path,
                        amount: item.amount,
                      });
                      e.stopPropagation();
                    }}
                  >
                    {item.amount}
                  </Button>
                )}
              </Button>
            ))
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

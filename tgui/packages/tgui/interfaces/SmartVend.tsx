import { BooleanLike } from 'common/react';
import { DmIcon, Icon } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Button, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

type Item = {
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
  const { contents = [] } = data;
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
            !!data.isdryer && (
              <Button
                icon={data.drying ? 'stop' : 'tint'}
                onClick={() => act('Dry')}
              >
                {data.drying ? 'Stop drying' : 'Dry'}
              </Button>
            )
          }
        >
          {contents.length === 0 ? (
            <NoticeBox>{data.name} is empty.</NoticeBox>
          ) : (
            Object.keys(contents).map((key) => (
              <Button
                color="transparent"
                key={key}
                m={1}
                p={0}
                height="64px"
                width="64px"
                tooltip={contents[key].name}
                tooltipPosition="bottom"
                textAlign="right"
                disabled={contents[key].amount < 1}
                onClick={() =>
                  act('Release', {
                    key: key,
                    amount: 1,
                  })
                }
              >
                <DmIcon
                  fallback={fallback}
                  icon={contents[key].icon}
                  icon_state={contents[key].icon_state}
                  height="64px"
                  width="64px"
                />
                {contents[key].amount > 1 && (
                  <Button
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
                        key: key,
                      });
                      e.stopPropagation();
                    }}
                  >
                    {contents[key].amount}
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

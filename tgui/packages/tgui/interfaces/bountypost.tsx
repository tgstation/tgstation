import { createSearch, toTitleCase } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import { Button, Flex, Image, Section, Stack, Tabs, Box } from '../components';
import { Window } from '../layouts';

type Bounty = {
  bounty_id: string;
  bounty_name: string;
  bounty_reward: number;
  bounty_icon: string;
};

type Shop_item = {
  item_name: string;
  item_price: number;
  item_icon: string;
  item_description: string;
  item_ref: string;
};

type Data = {
  bounty: Bounty[];
  shop_item: Shop_item[];
  coins_icon: string;
  user_points: number;
};

enum Tab {
  Bounties,
  Shop,
}

export const bountypost = (props) => {
  const { act, data } = useBackend<Data>();
  const { bounty = [] } = data;
  const [tab, setTab] = useState(Tab.Bounties);

  return (
    <Window title="Bounty Post" width={470} height={455} theme="oldpaper">
      <Window.Content>
        <Stack fill vertical fontFamily="playbill">
          <Stack.Item
            style={{
              borderBottom: '2px solid #642600',
            }}
          >
            <Tabs
              fontFamily="MV Boli"
              style={{
                fontSize: '20px',
                background: '#ffc877',
              }}
            >
              <Tabs.Tab
                style={{
                  color: '#642600',
                }}
                selected={tab === Tab.Bounties}
                onClick={() => setTab(Tab.Bounties)}
              >
                Bounty
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Shop}
                onClick={() => setTab(Tab.Shop)}
                style={{
                  color: '#642600',
                }}
              >
                Shop
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === Tab.Shop && <Shop />}
            {tab === Tab.Bounties && <Bounties />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const Shop = (props) => {
  const { act, data } = useBackend<Data>();
  const { shop_item = [], coins_icon, user_points } = data;
  return (
    <Section fill scrollable>
      <Stack vertical>
        <Stack.Item
          style={{
            fontSize: '18px',
            color: '#642600',
          }}
        >
          <Flex textAlign="right" mt={-1} ml="90%">
            <Flex.Item>{user_points}</Flex.Item>
            <Flex.Item>
              <Image
                mt={-1}
                src={`data:image/jpeg;base64,${coins_icon}`}
                height="32px"
                width="32px"
              />
            </Flex.Item>
          </Flex>
        </Stack.Item>
        {shop_item.map((shop_item, index) => (
          <Stack.Item
            fontFamily="MV Boli"
            ml={2}
            mt={1}
            key={index}
            style={{
              margin: '10px 20px',
              padding: '10px',
              border: '2px solid #8B4513',
              borderRadius: '10px',
              background: '#fff6e5',
              color: '#642600',
              boxShadow: '0px 8px 16px rgba(0, 0, 0, 0.3)',
            }}
          >
            <Flex textAlign="center">
              <Flex.Item>
                <Image
                  m={1}
                  src={`data:image/jpeg;base64,${shop_item.item_icon}`}
                  height="64px"
                  width="64px"
                  style={{
                    verticalAlign: 'middle',
                    border: '2px solid #642600',
                  }}
                />
              </Flex.Item>
              <Flex.Item textAlign="left" grow>
                <Box
                  style={{
                    display: 'block',
                    fontSize: '18px',
                    fontWeight: 'bold',
                  }}
                >
                  {shop_item.item_name.toUpperCase()}
                </Box>
                <Box mt={1} width="90%" style={{ display: 'block' }}>
                  {shop_item.item_description}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Stack vertical>
                  <Stack.Item>
                    <Flex>
                      <Flex.Item mt={2.5}>{shop_item.item_price}</Flex.Item>
                      <Flex.Item>
                        <Image
                          m={1}
                          src={`data:image/jpeg;base64,${coins_icon}`}
                          height="32px"
                          width="32px"
                        />
                      </Flex.Item>
                    </Flex>
                  </Stack.Item>
                  <Stack.Item mt={-1}>
                    <Button
                      style={{
                        borderRadius: '1em',
                        background: '#642600',
                        color: 'white',
                      }}
                      fontFamily="serif"
                      color="#fffff"
                      onClick={() =>
                        act('purchase', {
                          reference: shop_item.item_ref,
                        })
                      }
                    >
                      BUY
                    </Button>
                  </Stack.Item>
                </Stack>
              </Flex.Item>
            </Flex>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

export const Bounties = (props) => {
  const { act, data } = useBackend<Data>();
  const { bounty = [] } = data;
  return (
    <Section fill scrollable>
      <Stack wrap fontFamily="playbill">
        {bounty.map((bounty) => (
          <Flex.Item
            ml={2}
            mt={1}
            key={bounty.bounty_id}
            style={{
              verticalAlign: 'middle',
              // borderRadius: '1em',
              border: '1px solid #642600',
              color: '#642600',
              fontSize: '18px',
            }}
          >
            <Flex direction="column" m={0.5} textAlign="center">
              <Flex.Item
                style={{
                  borderBottom: '2px solid #642600',
                  fontSize: '20px',
                }}
              >
                WANTED
              </Flex.Item>
              <Flex.Item>
                <Image
                  m={1}
                  src={`data:image/jpeg;base64,${bounty.bounty_icon}`}
                  height="72px"
                  width="72px"
                  style={{
                    verticalAlign: 'middle',
                  }}
                />
              </Flex.Item>
              <Flex.Item>${bounty.bounty_reward}</Flex.Item>
              <Flex.Item>
                <Button
                  style={{
                    borderRadius: '1em',
                    background: '#642600',
                    color: 'white',
                  }}
                  fontFamily="serif"
                  color="#fffff"
                  onClick={() =>
                    act('claim', {
                      reference: bounty.bounty_id,
                    })
                  }
                >
                  CLAIM
                </Button>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        ))}
      </Stack>
    </Section>
  );
};

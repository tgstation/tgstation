import { useState } from 'react';
import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Import = {
  ref: string;
  name: string;
  category: string;
  cost: number;
  maximum: number;
  remaining: number;
  buyable: BooleanLike;
};

type Data = {
  marques: number;
  puritan_lock: BooleanLike;
  can_toggle_lock: BooleanLike;
  categories: string[];
  items: Import[];
};

/** The MARQUETTE: the Otavan Inquisition's shop inside the HERMES (Ratwood display_marquette()). */
export const RogueMarquette = () => {
  const { act, data } = useBackend<Data>();
  const [picked, setPicked] = useState('');
  const category = data.categories.includes(picked)
    ? picked
    : data.categories[0];
  const shown = data.items
    .filter((item) => item.category === category)
    .sort((a, b) => a.name.localeCompare(b.name));
  return (
    <Window width={560} height={560}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="L'INQUISITION MARQUETTE D'OTAVA"
              buttons={
                <Button
                  icon="eject"
                  disabled={data.marques <= 0}
                  onClick={() => act('eject')}
                >
                  Marques loaded: {data.marques}
                </Button>
              }
            >
              <Box italic>
                Pour l'éradication de l'hérésie, tant que Psydon endure.
              </Box>
              <Box mt={1}>
                Puritan's Lock: {data.puritan_lock ? 'OUI' : 'NON'}{' '}
                {!!data.can_toggle_lock && (
                  <Button onClick={() => act('toggle_lock')}>Toggle</Button>
                )}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              {data.categories.map((name) => (
                <Tabs.Tab
                  key={name}
                  selected={name === category}
                  onClick={() => setPicked(name)}
                >
                  {name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              {shown.length === 0 && <NoticeBox>Nothing in stock.</NoticeBox>}
              <Table>
                {shown.map((item) => (
                  <Table.Row key={item.ref} className="candystripe">
                    <Table.Cell>{item.name}</Table.Cell>
                    <Table.Cell collapsing>
                      {item.maximum > 0
                        ? item.remaining > 0
                          ? `${item.remaining}/${item.maximum}`
                          : 'OUT OF STOCK'
                        : ''}
                    </Table.Cell>
                    <Table.Cell collapsing>ᛉ {item.cost}</Table.Cell>
                    <Table.Cell collapsing>
                      <Button
                        disabled={!item.buyable}
                        onClick={() => act('buy', { ref: item.ref })}
                      >
                        Buy
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

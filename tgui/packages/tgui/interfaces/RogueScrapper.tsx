import {
  Box,
  Button,
  NumberInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Material = {
  path: string;
  name: string;
  price: number;
  cap: number;
  held: number;
  items: number;
  left: number;
  advertise: BooleanLike;
  enabled: BooleanLike;
};

type Data = {
  budget: number;
  is_keyholder: BooleanLike;
  materials: Material[];
  total_items: number;
};

/** Scrapper: the guild's buyer of raw stock (Ratwood Scrapper.tsx). */
export const RogueScrapper = () => {
  const { act, data } = useBackend<Data>();
  const keyholder = !!data.is_keyholder;
  return (
    <Window width={keyholder ? 640 : 420} height={460}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Coffer"
              buttons={
                keyholder && (
                  <>
                    <Button
                      icon="coins"
                      disabled={data.budget <= 0}
                      onClick={() => act('withdraw')}
                    >
                      Withdraw
                    </Button>
                    <Button
                      icon="box-open"
                      disabled={data.total_items <= 0}
                      onClick={() => act('dump_all')}
                    >
                      Empty hoppers
                    </Button>
                  </>
                )
              }
            >
              <b>{data.budget}</b> mammons to pay with.{' '}
              {keyholder
                ? `${data.total_items} pieces in the hoppers.`
                : 'Strike the machine with an item to offer it.'}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Wanted">
              <Table>
                <Table.Row header>
                  <Table.Cell>Material</Table.Cell>
                  <Table.Cell collapsing>Price</Table.Cell>
                  <Table.Cell collapsing>Room</Table.Cell>
                  {keyholder && (
                    <>
                      <Table.Cell collapsing>Cap</Table.Cell>
                      <Table.Cell collapsing>Held</Table.Cell>
                      <Table.Cell collapsing />
                    </>
                  )}
                </Table.Row>
                {data.materials
                  .filter((material) => keyholder || material.enabled)
                  .map((material) => (
                    <Table.Row key={material.path} className="candystripe">
                      <Table.Cell>
                        <Box color={material.enabled ? undefined : 'label'}>
                          {material.name}
                        </Box>
                      </Table.Cell>
                      <Table.Cell collapsing>
                        {keyholder ? (
                          <NumberInput
                            value={material.price}
                            minValue={0}
                            maxValue={10000}
                            step={1}
                            width="45px"
                            onChange={(value) =>
                              act('set_price', {
                                path: material.path,
                                value,
                              })
                            }
                          />
                        ) : (
                          `${material.price}m`
                        )}
                      </Table.Cell>
                      <Table.Cell collapsing>
                        {material.left < 0 ? 'no cap' : material.left}
                      </Table.Cell>
                      {keyholder && (
                        <>
                          <Table.Cell collapsing>
                            <NumberInput
                              value={material.cap}
                              minValue={0}
                              maxValue={10000}
                              step={1}
                              width="45px"
                              onChange={(value) =>
                                act('set_cap', { path: material.path, value })
                              }
                            />
                          </Table.Cell>
                          <Table.Cell collapsing>
                            {material.held} ({material.items})
                          </Table.Cell>
                          <Table.Cell collapsing>
                            <Button.Checkbox
                              checked={!!material.enabled}
                              onClick={() =>
                                act('toggle_enable', { path: material.path })
                              }
                            >
                              Buy
                            </Button.Checkbox>
                            <Button.Checkbox
                              checked={!!material.advertise}
                              onClick={() =>
                                act('toggle_advertise', {
                                  path: material.path,
                                })
                              }
                            >
                              Call
                            </Button.Checkbox>
                            <Button
                              icon="eject"
                              disabled={material.items <= 0}
                              onClick={() =>
                                act('dump_held', { path: material.path })
                              }
                            />
                          </Table.Cell>
                        </>
                      )}
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

import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  DmIcon,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { createSearch, toTitleCase } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

export const OreRedemptionMachine = (props) => {
  const { act, data } = useBackend();
  const { disconnected, unclaimedPoints, materials, user } = data;
  const [tab, setTab] = useSharedState('tab', 'material');
  const [searchItem, setSearchItem] = useState('');
  const [compact, setCompact] = useState(false);
  const search = createSearch(searchItem, (materials) => materials.name);
  const material_filtered =
    searchItem.length > 0
      ? data.materials.filter(search)
      : materials.filter((material) => material && material.category === tab);

  return (
    <Window title="Ore Redemption Machine" width={435} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Section>
            <Stack.Item>
              <Section>
                <Stack>
                  <Stack.Item>
                    <Icon
                      name="id-card"
                      size={3}
                      mr={1}
                      color={user ? 'green' : 'red'}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="Name">
                        {user?.name || 'No Name Detected'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Balance">
                        {user?.cash || 'No Balance Detected'}
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      textAlign="center"
                      color={compact ? 'red' : 'green'}
                      content="Compact"
                      onClick={() => setCompact(!compact)}
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Section>
          <Section>
            <Stack.Item>
              <Box>
                <Icon name="coins" color="gold" />
                <Box inline color="label" ml={1}>
                  Unclaimed points:
                </Box>
                {unclaimedPoints}
                <Button
                  ml={2}
                  content="Claim"
                  disabled={unclaimedPoints === 0 || disconnected}
                  tooltip={disconnected}
                  onClick={() => act('Claim')}
                />
              </Box>
            </Stack.Item>
          </Section>
          <Section>
            <Stack.Item>
              <BlockQuote>
                This machine only accepts ore. Gibtonite and Slag are not
                accepted.
              </BlockQuote>
            </Stack.Item>
          </Section>
          <Tabs>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'material'}
              onClick={() => {
                setTab('material');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              Materials
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 'alloy'}
              onClick={() => {
                setTab('alloy');

                if (searchItem.length > 0) {
                  setSearchItem('');
                }
              }}
            >
              Alloys
            </Tabs.Tab>
            <Input
              autofocus
              position="relative"
              left="25%"
              bottom="5%"
              height="20px"
              width="150px"
              placeholder="Search Material..."
              value={searchItem}
              onInput={(e, value) => {
                setSearchItem(value);

                if (value.length > 0) {
                  setTab(1);
                }
              }}
              fluid
            />
          </Tabs>
          <Stack.Item grow>
            <Section fill scrollable>
              <Table>
                {material_filtered.map((material) => (
                  <MaterialRow
                    compact={compact}
                    key={material.id}
                    material={material}
                    onRelease={(amount) => {
                      if (material.category === 'material') {
                        act('Release', {
                          id: material.id,
                          sheets: amount,
                        });
                      } else {
                        act('Smelt', {
                          id: material.id,
                          sheets: amount,
                        });
                      }
                    }}
                  />
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MaterialRow = (props) => {
  const { compact, material, onRelease } = props;

  const sheet_amounts = Math.floor(material.amount);
  const print_amount = 5;
  const max_sheets = 50;

  return (
    <Table.Row className="candystripe" collapsing>
      {!compact && (
        <Table.Cell collapsing>
          <DmIcon
            height={'18px'}
            width={'18px'}
            icon={material.icon}
            icon_state={material.icon_state}
            fallback={<Icon name="spinner" size={2} spin />}
          />
        </Table.Cell>
      )}
      <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Box color="label">
          {formatSiUnit(sheet_amounts, 0)}{' '}
          {material.amount === 1 ? 'sheet' : 'sheets'}
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Button
          content="x1"
          color="transparent"
          tooltip={material.value ? material.value + ' cr' : 'No cost'}
          onClick={() => onRelease(1)}
        />
        <Button
          content={'x' + print_amount}
          color="transparent"
          tooltip={
            material.value ? material.value * print_amount + ' cr' : 'No cost'
          }
          onClick={() => onRelease(print_amount)}
        />
        <Button.Input
          content={
            '[Max: ' +
            (sheet_amounts < max_sheets ? sheet_amounts : max_sheets) +
            ']'
          }
          color={'transparent'}
          maxValue={max_sheets}
          onCommit={(e, value) => {
            onRelease(value);
          }}
        />
      </Table.Cell>
    </Table.Row>
  );
};

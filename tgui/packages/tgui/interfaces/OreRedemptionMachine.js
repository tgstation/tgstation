import { createSearch, toTitleCase } from 'common/string';
import { useBackend, useLocalState, useSharedState } from '../backend';
import { BlockQuote, Box, Button, Table, Tabs, Input, Stack, Icon, Section, LabeledList } from '../components';
import { Window } from '../layouts';
import { formatSiUnit } from '../format';

export const OreRedemptionMachine = (props, context) => {
  const { act, data } = useBackend(context);
  const { unclaimedPoints, materials, user } = data;
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const [searchItem, setSearchItem] = useLocalState(context, 'searchItem', '');
  const search = createSearch(searchItem, (materials) => materials.name);
  let mats =
    searchItem.length > 0
      ? data.materials.filter(search)
      : materials.filter((mat) => mat && mat.cat === tab);
  return (
    <Window title="Ore Redemption Machine" width={435} height={725}>
      <Window.Content>
        <Stack fill vertical>
          <Section>
            <Stack.Item>
              <Section>
                <Stack>
                  <Stack.Item>
                    <Icon name="id-card" size={3} mr={1} color="green" />
                  </Stack.Item>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="Name">
                        {user.name || 'No name detected'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Balance">
                        {user.cash + ' cr' || 'No balance detected'}
                      </LabeledList.Item>
                    </LabeledList>
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
                  disabled={unclaimedPoints === 0}
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
              }}>
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
              }}>
              Alloys
            </Tabs.Tab>
            <Input
              ml={22}
              mb={0.8}
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
            <Table>
              {mats.map((material) => (
                <MaterialRow
                  key={material.id}
                  material={material}
                  onRelease={(amount) => {
                    if (material.cat === 'material') {
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
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MaterialRow = (props, context) => {
  const { material, onRelease } = props;

  return (
    <Table.Row className="candystripe" collapsing>
      <Table.Cell collapsing>
        <Box
          as="img"
          m={1}
          src={`data:image/jpeg;base64,${material.product_icon}`}
          height="32px"
          width="32px"
          style={{
            '-ms-interpolation-mode': 'nearest-neighbor',
            'vertical-align': 'middle',
          }}
        />
      </Table.Cell>
      <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Box color="label">{formatSiUnit(material.amount, 0)} sheets</Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="left">
        <Button
          content="x1"
          color="transparent"
          tooltip={material.value ? material.value + ' cr' : 'No cost'}
          onClick={() => onRelease(1)}
        />
        <Button
          content="x5"
          color="transparent"
          tooltip={material.value ? material.value * 5 + ' cr' : 'No cost'}
          onClick={() => onRelease(5)}
        />
        <Button.Input
          content={
            '[Max: ' + (material.amount < 50 ? material.amount : 50) + ']'
          }
          color={'transparent'}
          maxValue={50}
          onCommit={(e, value) => {
            onRelease(value);
          }}
        />
      </Table.Cell>
    </Table.Row>
  );
};

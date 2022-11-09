import { BooleanLike } from 'common/react';
import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Section, NumberInput, Table, Tabs, LabeledList, NoticeBox, Button, ProgressBar, Stack } from '../components';

type BiogeneratorData = {
  processing: BooleanLike;
  beaker: BooleanLike;
  biomass: number;
  can_process: BooleanLike;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  categories: Category[];
};

type Category = {
  name: string;
  items: Design[];
};

type Design = {
  id: number;
  name: string;
  disable: BooleanLike;
  cost: number;
  amount: number;
};

export const Biogenerator = (props, context) => {
  const { act, data } = useBackend<BiogeneratorData>(context);
  const {
    processing,
    beaker,
    biomass,
    can_process,
    beakerCurrentVolume,
    beakerMaxVolume,
    categories,
  } = data;
  const [selectedCategory, setSelectedCategory] = useLocalState<string>(
    context,
    'category',
    data.categories[0]?.name
  );
  const items =
    categories.find((category) => category.name === selectedCategory)?.items ||
    [];
  return (
    <Window width={400} height={460}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item
                label="Biomass"
                buttons={
                  <Button
                    width={7}
                    align="center"
                    icon="cog"
                    iconSpin={processing ? 1 : 0}
                    content="Generate"
                    disabled={!can_process || processing}
                    onClick={() => act('activate')}
                  />
                }>
                <ProgressBar
                  value={biomass}
                  minValue={0}
                  maxValue={1000}
                  color="good">
                  {`${biomass} of ${1000} units`}
                </ProgressBar>
              </LabeledList.Item>
              {!!beaker && (
                <LabeledList.Item
                  label="Container"
                  buttons={
                    <Button
                      width={7}
                      align="center"
                      icon="eject"
                      content="Eject"
                      onClick={() => act('eject')}
                    />
                  }>
                  <ProgressBar
                    value={beakerCurrentVolume}
                    minValue={0}
                    maxValue={beakerMaxVolume}>
                    {`${beakerCurrentVolume} of ${beakerMaxVolume} units`}
                  </ProgressBar>
                </LabeledList.Item>
              )}
              {!beaker && (
                <LabeledList.Item label="Container">
                  <NoticeBox m={0} height="19px" fontSize="11px">
                    No liquid container
                  </NoticeBox>
                </LabeledList.Item>
              )}
            </LabeledList>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill style={{ 'overflow': 'auto' }}>
              <Tabs fluid>
                {categories.map((category) => (
                  <Tabs.Tab
                    align="center"
                    key={category.name}
                    selected={category.name === selectedCategory}
                    onClick={() => setSelectedCategory(category.name)}>
                    {category.name} ({category.items?.length || 0})
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Table>
                <ItemList biomass={biomass} items={items} />
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemList = (props, context) => {
  const { act } = useBackend(context);
  const [hoveredItem, setHoveredItem] = useLocalState<Design | null>(
    context,
    'hoveredItem',
    null
  );
  const hoveredCost = hoveredItem?.cost || 0;
  // Append extra hover data to items
  const items = props.items.map((item) => {
    const [amount, setAmount] = useLocalState(context, 'amount' + item.name, 1);
    const notSameItem = hoveredItem?.name !== item.name;
    // const notEnoughHovered =
    //   props.biomass - hoveredCost * hoveredItem?.amount < item.cost * amount;
    // const disabledDueToHovered = notSameItem && notEnoughHovered;
    // const disabled = props.biomass < item.cost * amount || disabledDueToHovered;
    return {
      ...item,
      // disabled,
      amount,
      setAmount,
    };
  });
  return items.map((item) => (
    <Table.Row key={item.id}>
      <Table.Cell>
        <span
          className={classes(['design32x32', item.id])}
          style={{
            'vertical-align': 'middle',
          }}
        />{' '}
        <b>{item.name}</b>
      </Table.Cell>
      <Table.Cell collapsing>
        <NumberInput
          value={Math.round(item.amount)}
          width="35px"
          minValue={1}
          maxValue={10}
          onChange={(e, value) => item.setAmount(value)}
        />
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          fluid
          align="right"
          content={item.cost * item.amount + ' ' + 'BIO'}
          disabled={item.disabled}
          onmouseover={() => setHoveredItem(item)}
          onmouseout={() => setHoveredItem(null)}
          onClick={() =>
            act('create', {
              id: item.id,
              amount: item.amount,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  ));
};

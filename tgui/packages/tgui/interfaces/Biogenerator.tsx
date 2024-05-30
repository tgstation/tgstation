import { BooleanLike } from 'common/react';
import { classes } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type BiogeneratorData = {
  processing: BooleanLike;
  beaker: BooleanLike;
  reagent_color: string;
  biomass: number;
  max_visual_biomass: number;
  can_process: BooleanLike;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  max_output: number;
  efficiency: number;
  categories: Category[];
};

type Category = {
  name: string;
  items: Design[];
};

type Design = {
  id: number;
  name: string;
  is_reagent: BooleanLike;
  disable: BooleanLike;
  cost: number;
  amount: number;
};

export const Biogenerator = (props) => {
  const { act, data } = useBackend<BiogeneratorData>();
  const {
    processing,
    beaker,
    reagent_color,
    biomass,
    max_visual_biomass,
    can_process,
    beakerCurrentVolume,
    beakerMaxVolume,
    max_output,
    efficiency,
    categories,
  } = data;
  const [selectedCategory, setSelectedCategory] = useState(
    data.categories[0]?.name,
  );
  const items =
    categories.find((category) => category.name === selectedCategory)?.items ||
    [];
  return (
    <Window width={400} height={500}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
              <LabeledList>
                <LabeledList.Item
                  label="Biomass"
                  buttons={
                    <Button
                      width={7}
                      lineHeight={2}
                      align="center"
                      icon="cog"
                      iconSpin={processing ? 1 : 0}
                      content="Generate"
                      disabled={!can_process || processing}
                      onClick={() => act('activate')}
                    />
                  }
                >
                  <ProgressBar
                    value={biomass}
                    minValue={0}
                    maxValue={max_visual_biomass}
                    color="good"
                  >
                    <Box
                      lineHeight={1.9}
                      style={{
                        textShadow: '1px 1px 0 black',
                      }}
                    >
                      {`${parseFloat(biomass.toFixed(2))} units`}
                    </Box>
                  </ProgressBar>
                </LabeledList.Item>
                {!!beaker && (
                  <LabeledList.Item
                    label="Container"
                    buttons={
                      <Button
                        width={7}
                        lineHeight={2}
                        align="center"
                        icon="eject"
                        content="Eject"
                        onClick={() => act('eject')}
                      />
                    }
                  >
                    <ProgressBar
                      value={beakerCurrentVolume}
                      minValue={0}
                      height={2}
                      maxValue={beakerMaxVolume}
                      color={reagent_color}
                    >
                      <Box
                        lineHeight={1.9}
                        style={{
                          textShadow: '1px 1px 0 black',
                        }}
                      >
                        {`${beakerCurrentVolume} of ${beakerMaxVolume} units`}
                      </Box>
                    </ProgressBar>
                  </LabeledList.Item>
                )}
                {!beaker && (
                  <LabeledList.Item label="Container">
                    <NoticeBox m={0} height={2}>
                      No liquid container
                    </NoticeBox>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid>
              {categories.map((category) => (
                <Tabs.Tab
                  align="center"
                  key={category.name}
                  selected={category.name === selectedCategory}
                  onClick={() => setSelectedCategory(category.name)}
                >
                  {category.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow mt={'2px'}>
            <Section fill scrollable>
              <Table>
                <ItemList
                  processing={processing}
                  biomass={biomass}
                  items={items}
                  beaker={beaker}
                  efficiency={efficiency}
                  max_output={max_output}
                  space={beaker ? beakerMaxVolume - beakerCurrentVolume : 1}
                />
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemList = (props) => {
  const { act } = useBackend();
  const items = props.items.map((item) => {
    const [amount, setAmount] = useState(
      item.is_reagent ? Math.min(Math.max(props.space, 1), 10) : 1,
    );
    const disabled =
      props.processing ||
      (item.is_reagent && !props.beaker) ||
      (item.is_reagent && props.space < amount) ||
      props.biomass < Math.ceil((item.cost * amount) / props.efficiency);
    const max_possible = Math.floor(
      (props.efficiency * props.biomass) / item.cost,
    );
    const max_capacity = item.is_reagent ? props.space : props.max_output;
    const max_amount = Math.max(1, Math.min(max_capacity, max_possible));
    return {
      ...item,
      disabled,
      max_amount,
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
            verticalAlign: 'middle',
          }}
        />{' '}
        <b>{item.name}</b>
      </Table.Cell>
      <Table.Cell collapsing>
        <NumberInput
          value={item.amount}
          step={1}
          width="35px"
          minValue={1}
          maxValue={item.max_amount}
          onChange={(value) => item.setAmount(value)}
        />
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          fluid
          align="right"
          content={parseFloat((item.cost * item.amount).toFixed(2)) + ' BIO'}
          disabled={item.disabled}
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

import { BooleanLike, classes } from 'common/react';
import { capitalizeAll } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import { AirLockMainSection } from './AirlockElectronics';

type Data = {
  matterLeft: number;
  silo_upgraded: BooleanLike;
  silo_enabled: BooleanLike;
  root_categories: string[];
  selected_root: string;
  categories: Category[];
  selected_category: string;
  selected_design: string;
  selected_direction: string;
  display_tabs: BooleanLike;
};

type Category = {
  cat_name: string;
  designs: Design[];
};

type Design = {
  title: string;
  icon: string;
  icon_id: string;
};

export const MatterItem = (props) => {
  const { data } = useBackend<Data>();
  const { matterLeft } = data;
  return (
    <LabeledList.Item label="Units Left">
      &nbsp;{matterLeft} Units
    </LabeledList.Item>
  );
};

export const DirectionsList = (props) => {
  const { data, act } = useBackend<Data>();
  const { matterLeft, selected_direction } = data;
  return (
    <Flex>
      <Flex.Item mt={2}>
        <Button
          selected={selected_direction === 'west'}
          color="transparent"
          icon="arrow-left"
          width="20px"
          onClick={() =>
            act('select_direction', {
              selected_direction: 'west',
            })
          }
        />
      </Flex.Item>
      <Flex.Item>
        <Stack vertical>
          <Stack.Item>
            <Button
              selected={selected_direction === 'north'}
              color="transparent"
              icon="arrow-up"
              width="20px"
              onClick={() =>
                act('select_direction', {
                  selected_direction: 'north',
                })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              selected={selected_direction === 'south'}
              color="transparent"
              width="20px"
              icon="arrow-down"
              onClick={() =>
                act('select_direction', {
                  selected_direction: 'south',
                })
              }
            />
          </Stack.Item>
        </Stack>
      </Flex.Item>
      <Flex.Item mt={2}>
        <Button
          selected={selected_direction === 'east'}
          color="transparent"
          icon="arrow-right"
          width="20px"
          onClick={() =>
            act('select_direction', {
              selected_direction: 'east',
            })
          }
        />
      </Flex.Item>
    </Flex>
  );
};

export const SiloItem = (props) => {
  const { act, data } = useBackend<Data>();
  const { silo_enabled } = data;
  return (
    <LabeledList.Item label="Silo Link">
      <Button.Checkbox
        content={silo_enabled ? 'Silo Online' : 'Silo Offline'}
        checked={silo_enabled}
        color="transparent"
        onClick={() => act('toggle_silo')}
      />
    </LabeledList.Item>
  );
};

const CategoryItem = (props) => {
  const { act, data } = useBackend<Data>();
  const { root_categories = [], selected_root } = data;
  return (
    <LabeledList.Item label="Category">
      {root_categories.map((root) => (
        <Button
          key={root}
          content={root}
          selected={selected_root === root}
          color="transparent"
          onClick={() => act('root_category', { root_category: root })}
        />
      ))}
    </LabeledList.Item>
  );
};

export const InfoSection = (props) => {
  const { data } = useBackend<Data>();
  const { silo_upgraded } = data;

  return (
    <Section>
      <Flex>
        <Flex.Item>
          <LabeledList>
            <MatterItem />
            {silo_upgraded ? <SiloItem /> : ''}
            <CategoryItem />
          </LabeledList>
        </Flex.Item>
        <Flex.Item mt={-1}>
          <DirectionsList />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const DesignSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [], selected_category, selected_design } = data;
  const [categoryName, setCategoryName] = useState(selected_category);
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];

  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            key={category.cat_name}
            selected={category.cat_name === shownCategory.cat_name}
            onClick={() => setCategoryName(category.cat_name)}
          >
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      <Stack vertical>
        {shownCategory?.designs.map((design, i) => (
          <Stack.Item key={i}>
            <Button
              fluid
              height="64px"
              color="transparent"
              selected={
                design.title === selected_design &&
                shownCategory.cat_name === selected_category
              }
              onClick={() =>
                act('design', {
                  category: shownCategory.cat_name,
                  index: i + 1,
                })
              }
            >
              <Box
                mt={design.icon_id.includes('32x32') ? 3 : 0}
                inline
                verticalAlign="middle"
                mr="10px"
                className={classes([design.icon_id, design.icon])}
              />
              <span>{capitalizeAll(design.title)}</span>
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const ConfigureSection = (props) => {
  const { data } = useBackend<Data>();
  const { selected_root } = data;

  return (
    <Stack.Item grow>
      {selected_root === 'Airlock Access' ? (
        <AirLockMainSection />
      ) : (
        <DesignSection />
      )}
    </Stack.Item>
  );
};

export const RapidConstructionDevice = (props) => {
  return (
    <Window width={450} height={590}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <InfoSection />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <ConfigureSection />
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

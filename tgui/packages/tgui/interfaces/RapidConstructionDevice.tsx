import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike, classes } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';

import { useBackend } from '../backend';
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
  display_tabs: BooleanLike;
};

type Category = {
  cat_name: string;
  designs: Design[];
};

type Design = {
  title: string;
  icon: string;
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
      <LabeledList>
        <MatterItem />
        {silo_upgraded ? <SiloItem /> : ''}
        <CategoryItem />
      </LabeledList>
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
      {shownCategory?.designs.map((design, i) => (
        <Button
          key={i + 1}
          fluid
          height="31px"
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
            inline
            verticalAlign="middle"
            mr="10px"
            className={classes(['rcd-tgui32x32', design.icon])}
            style={{
              transform:
                design.title === 'full tile window' ||
                design.title === 'full tile reinforced window' ||
                design.title === 'catwalk'
                  ? 'scale(0.7)'
                  : 'scale(1.0)',
            }}
          />
          <span>{capitalizeAll(design.title)}</span>
        </Button>
      ))}
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

import { Window } from '../layouts';
import { classes } from 'common/react';
import { capitalizeAll } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { LabeledList, Section, Button, Tabs, Stack, Box } from '../components';
import { AirLockMainSection } from './AirlockElectronics';

type Data = {
  matterLeft: Number;
  space: Boolean;
  silo_upgraded: Boolean;
  silo_enabled: Boolean;
  root_categories: string[];
  selected_root: string;
  categories: Category[];
  selected_category: string;
  display_tabs: Boolean;
};

type Category = {
  cat_name: string;
  designs: Design[];
};

type Design = {
  title: string;
  design_id: Number;
  selected: Boolean;
  icon: string;
};

export const Space = (props, context) => {
  return <span>&nbsp;</span>;
};

export const MatterItem = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { matterLeft, space } = data;
  return (
    <LabeledList.Item label="Units Left">
      {space ? <Space /> : ''}
      {matterLeft} Units
    </LabeledList.Item>
  );
};

export const SiloItem = (props, context) => {
  const { act, data } = useBackend<Data>(context);
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

const CategoryItem = (props, context) => {
  const { act, data } = useBackend<Data>(context);
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

const InfoSection = (props, context) => {
  const { data } = useBackend<Data>(context);
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

const DesignSection = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { categories = [], selected_category } = data;
  const [categoryName, setCategoryName] = useLocalState(
    context,
    'categoryName',
    selected_category
  );
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];
  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            fluid
            key={category.cat_name}
            selected={category.cat_name === shownCategory.cat_name}
            onClick={() => setCategoryName(category.cat_name)}>
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.designs.map((design) => (
        <Button
          key={design.design_id}
          fluid
          ellipsis
          color="transparent"
          selected={design.selected}
          onClick={() =>
            act('design', {
              category: shownCategory.cat_name,
              index: design.design_id,
            })
          }>
          <Stack>
            <Stack.Item>
              <Box
                className={classes(['rcd-tgui32x32', design.icon])}
                style={{
                  transform: 'scale(1.5) translate(9%, 9%)',
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <span>&nbsp;&nbsp;</span>
            </Stack.Item>
            <Stack.Item>
              <Section verticalAlign="middle">
                {capitalizeAll(design.title)}
              </Section>
            </Stack.Item>
          </Stack>
          <Section
            style={{
              height: '10px',
            }}
          />
        </Button>
      ))}
    </Section>
  );
};

const ConfigureSection = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { display_tabs } = data;

  return (
    <Stack.Item grow>
      {display_tabs ? <DesignSection /> : <AirLockMainSection />}
    </Stack.Item>
  );
};

export const RapidConstructionDevice = (props, context) => {
  return (
    <Window width={450} height={580}>
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

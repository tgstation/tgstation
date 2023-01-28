import { Window } from '../layouts';
import { BooleanLike, classes } from 'common/react';
import { capitalizeAll } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { LabeledList, Section, Button, Tabs, Stack, Box } from '../components';
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

export const MatterItem = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { matterLeft } = data;
  return (
    <LabeledList.Item label="Units Left">
      &nbsp;{matterLeft} Units
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

export const InfoSection = (props, context) => {
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
  const { categories = [], selected_category, selected_design } = data;
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
      {shownCategory?.designs.map((design, i) => (
        <Button
          key={i + 1}
          fluid
          ellipsis
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
          }>
          <Box
            inline
            verticalAlign="middle"
            mr="10px"
            className={classes(['rcd-tgui32x32', design.icon])}
            style={{
              transform:
                design.icon === 'window0' ||
                design.icon === 'rwindow0' ||
                design.icon === 'catwalk0'
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

const ConfigureSection = (props, context) => {
  const { data } = useBackend<Data>(context);
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

export const RapidConstructionDevice = (props, context) => {
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

import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { ICON_BY_CATEGORY_NAME, ColorItem, LayerSelect, SmartPipeBlockSection } from './RapidPipeDispenser';

const PipeTypeSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    categories = [],
  } = data;
  const [
    categoryName,
    setCategoryName,
  ] = useLocalState(context, 'categoryName');
  const shownCategory = categories
    .find(category => category.cat_name === categoryName)
    || categories[0];
  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category, i) => (
          <Tabs.Tab
            fluid
            key={category.cat_name}
            icon={ICON_BY_CATEGORY_NAME[category.cat_name]}
            selected={category.cat_name === shownCategory.cat_name}
            onClick={() => setCategoryName(category.cat_name)}>
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.recipes.map(recipe => (
        <Button
          key={recipe.pipe_index}
          fluid
          ellipsis
          content={recipe.pipe_name}
          title={recipe.pipe_name}
          onClick={() => act('pipe_type', {
            pipe_type: recipe.pipe_index,
            pipe_dir: recipe.dir,
            category: shownCategory.cat_name,
          })} />
      ))}
    </Section>
  );
};

export const PipeDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    category: rootCategoryIndex,
  } = data;
  return (
    <Window
      width={450}
      height={575}>
      <Window.Content>
        <Stack fill vertical>
          {rootCategoryIndex === 0 && (
            <Stack.Item>
              <Section>
                <LabeledList>
                  <ColorItem />
                </LabeledList>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Stack fill>
              {rootCategoryIndex === 0 && (
                <Stack.Item>
                  <Stack vertical fill>
                    <Stack.Item>
                      <SmartPipeBlockSection />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Section fill width={7.5}>
                        <LayerSelect />
                      </Section>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              )}
              <Stack.Item grow>
                <PipeTypeSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

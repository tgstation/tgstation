import { useBackend, useSharedState } from '../backend';
import { Box, Button, Dimmer, Icon, LabeledList, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const Limbgrower = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    reagents = [],
    total_reagents,
    max_reagents,
    categories = [],
    busy,
  } = data;
  const [tab, setTab] = useSharedState(
    context, 'category', categories[0]?.name);
  const designList = categories
    .find(category => category.name === tab)
    ?.designs || [];

  return (
    <Window
      title="Limb Grower"
      width={400}
      height={550}>
      {!!busy && (
        <Dimmer fontSize="32px">
          <Icon name="cog" spin={1} />
          {' Building...'}
        </Dimmer>
      )}
      <Window.Content scrollable>
        <Section title="Reagents">
          <Box mb={1}>
            {total_reagents} / {max_reagents} reagent capacity used.
          </Box>
          <LabeledList>
            {reagents.map(reagent => (
              <LabeledList.Item
                key={reagent.reagent_name}
                label={reagent.reagent_name}
                buttons={(
                  <Button.Confirm
                    textAlign="center"
                    width="120px"
                    content="Remove Reagent"
                    color="bad"
                    onClick={() => act('empty_reagent', {
                      reagent_type: reagent.reagent_type,
                    })} />
                )}>
                {reagent.reagent_amount}u
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Designs">
          <Tabs>
            {categories.map(category => (
              <Tabs.Tab
                fluid
                key={category.name}
                selected={tab === category.name}
                onClick={() => setTab(category.name)}>
                {category.name}
              </Tabs.Tab>
            ))}
          </Tabs>
          <LabeledList>
            {designList.map(design => (
              <LabeledList.Item
                key={design.name}
                label={design.name}
                buttons={(
                  <Button
                    content="Make"
                    color="good"
                    onClick={() => act('make_limb', {
                      design_id: design.id,
                      active_tab: design.parent_category,
                    })} />
                )}>
                {design.needed_reagents.map(reagent => (
                  <Box key={reagent.name}>
                    {reagent.name}: {reagent.amount}u
                  </Box>
                ))}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

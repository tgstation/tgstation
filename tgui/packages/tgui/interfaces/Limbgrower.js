import { useBackend, useSharedState } from '../backend';
import { Box, Button, Section, Divider, Tabs, LabeledList, Flex } from '../components';
import { Window } from '../layouts';

export const Limbgrower = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    reagents = [],
    total_reagents,
    max_reagents,
    categories = [],
  } = data;
  const [tab, setTab] = useSharedState(context, 'category', categories[0]?.name);
  const designList = categories.find(category => category.name === tab)?.designs

  return (
    <Window
      width={400}
      height={550}
      title="Limb Grower">
      <Window.Content scrollable>
        <Section title="Reagents">
          <Flex direction="column">
            <Flex.Item mb={1}>
              {total_reagents} / {max_reagents} reagent capacity used.
            </Flex.Item>
            <Flex.Item>
              <LabeledList>
                {reagents.map(reagent => (
                  <LabeledList.Item
                    label={reagent.reagent_name}
                    buttons={(
                      <Button
                        content="Remove Reagent"
                        color="bad"
                        onClick={() => act('empty_reagent', {reagent_type: reagent.reagent_type})} />)} >
                    {reagent.reagent_amount}u
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Section>

        <Divider/>

        <Section title="Designs">
          <Flex direction="column">
            <Flex.Item>
              <Tabs>
                {categories.map(category => (
                  <Tabs.Tab
                    fluid
                    selected={tab === category.name}
                    onClick={() => {
                      act("updated_active_tab", {active_tab: category.name});
                      setTab(category.name);
                    }}>
                    {category.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Flex.Item>
            <Flex.Item>
              <LabeledList>
                  {designList.map(design => (
                    <LabeledList.Item
                      label={design.name}
                      buttons={(
                        <Button
                          content="Make"
                          color="good"
                          onClick={() => act('make_limb', {design_id: design.id})}/>
                        )}>
                      {design.needed_reagents.map(reagent => (
                        <Box>
                          {reagent.name}: {reagent.amount}u
                        </Box>
                        ))}
                    </LabeledList.Item>
                  ))}
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

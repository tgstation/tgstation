import { useBackend, useSharedState } from '../backend';
import { Box, Button, Section, Divider, Tabs, LabeledList, Flex, Dimmer, Icon } from '../components';
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
  const [tab, setTab] = useSharedState(context, 'category', categories[0]?.name);
  const designList = categories.find(category => category.name === tab)?.designs

  return (
    <Window
      width={400}
      height={550}
      title="Limb Grower">
      {!!busy && (
        <Dimmer fontSize="32px">
          <Icon name="cog" spin={1} />
          {' Building...'}
        </Dimmer>
      )}
      <Window.Content scrollable>
        <Section title="Reagents">
          <Flex direction="column">
            <Flex.Item mb={1}>
              {total_reagents} / {max_reagents} reagent capacity used.
            </Flex.Item>
            <Flex.Item>
              <LabeledList>
                { reagents.map(reagent => (
                  <LabeledList.Item
                    label={reagent.reagent_name}
                    buttons={(
                      <Button.Confirm
                        textAlign="center"
                        width="120px"
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
                    onClick={() => setTab(category.name)}>
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
                          onClick={() => act('make_limb', {
                            design_id: design.id,
                            active_tab: design.parent_category,
                          })}/>
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

import { useBackend, useSharedState } from '../backend';
import { Box, Button, Section, Divider, Tabs, LabeledList, Flex } from '../components';
import { Window } from '../layouts';

export const Limbgrower = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    reagents = [],
    categories = [],
    total_reagents,
    max_reagents,
  } = data;
  const [tab, setTab] = useSharedState(context, 'category', categories[0]);

  return (
    <Window
      width={400}
      height={500}
      title="Limb Grower">
      <Window.Content>
        <Section title="Reagents">
          <Flex direction="column">
            <Flex.Item>
              {total_reagents} / {max_reagents} reagents currently filled.
            </Flex.Item>
            <Flex.Item>
              <LabeledList>
                {reagents.map(reagent => {
                  <LabeledList.Item label={reagent.reagent_name}>
                    {reagent.reagent_amount}
                  </LabeledList.Item>
                })}
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Section>

        <Divider/>

        <Section title="Designs">
          <Flex direction="column">
            <Flex.Item>
              <Tabs>
                {categories.map(category => {
                  <Tabs.Tab
                    selected={tab === category}
                    onClick={() => setTab(category)}>
                    Category: {category}
                  </Tabs.Tab>
                })}
              </Tabs>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

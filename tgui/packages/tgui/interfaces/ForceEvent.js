
import { useBackend, useSharedState } from '../backend';
import { Box, Flex, Button, Section, Tabs, Table } from "../components";
import { Window } from '../layouts';

export const ForceEvent = (props, context) => {
    return (
      <Window title="Force Event" width={450} height={360}>
        <Window.Content scrollable>
            <EventEmporium />
        </Window.Content>
      </Window>
    );
}

  export const EventEmporium = (props, context) => {
  const { act, data } = useBackend(context);
  
  const categories = Object.values(data.categories);

  const [activeCategoryName, setActiveCategoryName] = useSharedState(
    context,
    'category',
    categories[0]?.name
  );

  const activeCategory = categories.find((category) => category.name === activeCategoryName);

  const nameSorter = (a,b) => {
    const nameA = a.name.toLowerCase();
    const nameB = b.name.toLowerCase();
    if (nameA < nameB) {
      return -1;
    }
    if (nameA > nameB) {
      return 1;
    }
    return 0;
  }

  return (
    <Box>
        <Section fitted>
            <Flex>
                <Flex.Item>
                <Tabs vertical>
                    {categories.sort(nameSorter).map((category) => (
                    <Tabs.Tab
                        key={category.name}
                        selected={category.name === activeCategoryName}
                        onClick={() => {
                        setActiveCategoryName(category.name);
                        }}>
                        {category.name}
                    </Tabs.Tab>
                    ))}
                </Tabs>
                </Flex.Item>
                <Flex.Item grow={1} basis={0}>
                    <Table>
                    {
                            activeCategory?.events.sort(nameSorter).map((event) => {
                                return (
                                    <Table.Row key={event.name} className="candystripe">
                                            <Table.Cell>{event.name}</Table.Cell>
                                            <Table.Cell collapsing textAlign="right">
                                                <Button
                                                    content="Trigger"
                                                    tooltip={ event.description || ''}
                                                    tooltipPosition="right"
                                                    onClick={() =>
                                                        act('forceevent', {
                                                        type: event.type,
                                                        })}
                                                />
                                            </Table.Cell>
                                    </Table.Row>     
                            )})
                        }

                    </Table>
                </Flex.Item>
            </Flex>
        </Section>
    </Box>
  )
}

import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, ProgressBar, Flex, Box, Table, Collapsible, Input, Dimmer, Icon } from '../components';
import { Window } from '../layouts';
import { capitalize } from "common/string";

export const Autolathe = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    materialtotal,
    materialsmax,
    materials = [],
    categories = [],
    designs = [],
    active,
  } = data;
  const [
    current_category,
    setCategory,
  ] = useLocalState(context, 'current_category', "None");
  const filteredmaterials = materials.filter(material =>
    material.mineral_amount > 0);
  return (
    <Window
      title="Autolathe"
      width={600}
      height={600}>
      <Window.Content scrollable>
        <Section title="Total Materials">
          <LabeledList>
            <LabeledList.Item
              label="Total Materials">
              <ProgressBar
                value={materialtotal}
                minValue={0}
                maxValue={materialsmax}
                ranges={{
                  "good": [materialsmax * 0.85, materialsmax],
                  "average": [materialsmax * 0.25, materialsmax * 0.85],
                  "bad": [0, materialsmax * 0.25],
                }}>
                {materialtotal + '/' + materialsmax + ' cm³'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item>
              {filteredmaterials.length > 0 && (
                <Collapsible title="Materials">
                  <LabeledList>
                    {filteredmaterials.map(filteredmaterial => (
                      <LabeledList.Item
                        key={filteredmaterial.id}
                        label={capitalize(filteredmaterial.name)}>
                        <ProgressBar
                          style={{
                            transform: 'scaleX(-1) scaleY(1)',
                          }}
                          value={materialsmax - filteredmaterial.mineral_amount}
                          maxValue={materialsmax}
                          color="black"
                          backgroundColor={filteredmaterial.matcolour}>
                          <div style={{ transform: 'scaleX(-1)' }}>{filteredmaterial.mineral_amount + ' cm³'}</div>
                        </ProgressBar>
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Collapsible>)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Search">
          <Input fluid
            placeholder="Search Recipes..."
            selfClear
            onChange={(e, value) => {
              if (value.length) {
                act('search', {
                  to_search: value,
                });
                setCategory('results for "' + value + '"');
              }
            }} />
        </Section>
        <Section title="Categories">
          <Box>
            {categories.map(category => (
              // eslint-disable-next-line react/jsx-key
              <Button
                selected={current_category === category}
                content={category}
                onClick={() => {
                  act('category', {
                    selectedCategory: category,
                  });
                  setCategory(category);
                }} />
            ))}
          </Box>
        </Section>
        {current_category.toString() !== "None" && (
          <Section
            title={'Displaying ' + current_category.toString()}
            buttons={(
              <Button
                icon="times"
                content="Close Category"
                onClick={() => {
                  act('menu');
                  setCategory("None");
                }} />
            )}>
            {active === 1 && (
              <Dimmer fontSize="32px">
                <Icon name="cog" spin />
                {'Building items...'}
              </Dimmer>
            )}
            <Flex direction="row" wrap="nowrap">
              <Table>
                {designs.length
                  && (designs.map(design => (
                    <Table.Row
                      key={design.id}>
                      <Flex.Item>
                        <Button
                          content={design.name}
                          disabled={design.buildable}
                          onClick={() => act('make', {
                            id: design.id,
                            multiplier: '1',
                          })} />
                      </Flex.Item>
                      {design.sheet ? (
                        <Table.Cell>
                          <Flex.Item grow={1}>
                            <Button
                              icon="hammer"
                              content="10"
                              disabled={!design.mult10}
                              onClick={() => act('make', {
                                id: design.id,
                                multiplier: '10',
                              })} />
                            <Button
                              icon="hammer"
                              content="25"
                              disabled={!design.mult25}
                              onClick={() => act('make', {
                                id: design.id,
                                multiplier: '25',
                              })} />
                          </Flex.Item>
                        </Table.Cell>
                      ) : (
                        <Table.Cell>
                          <Flex.Item grow={3}>
                            <Button
                              icon="hammer"
                              content="5"
                              disabled={!design.mult5}
                              onClick={() => act('make', {
                                id: design.id,
                                multiplier: '5',
                              })} />
                            <Button
                              icon="hammer"
                              content="10"
                              disabled={!design.mult10}
                              onClick={() => act('make', {
                                id: design.id,
                                multiplier: '10',
                              })} />
                          </Flex.Item>
                        </Table.Cell>
                      )}
                      <Table.Cell>
                        <Button.Input
                          content={"[Max:" + design.maxmult + ']'}
                          maxValue={design.maxmult}
                          disabled={design.buildable}
                          backgroundColor={design.buildable ? '#999999' : 'default'}
                          onCommit={(e, value) => act('make', {
                            id: design.id,
                            multiplier: value,
                          })} />
                      </Table.Cell>
                      {design.cost}
                    </Table.Row>
                  ))) || (
                  <Table.Row>
                    <Table.Cell>
                      {"No designs found."}
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Flex>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

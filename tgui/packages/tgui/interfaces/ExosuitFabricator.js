import { useBackend, useSharedState } from '../backend';
import { Flex, Section, Tabs, Box, Button } from '../components';
import { Window } from '../layouts';

export const ExosuitFabricator = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Flex
          fillPositionedParent
          direction="column">
          <Flex.Item m={1} basis="content" shrink={1}>
            <Button content="Sync" onClick={() => act('sync_rnd')} />
          </Flex.Item>
          <Flex.Item ml={1} mr={1} basis="content" shrink={1}>
            <Section
              title="Materials"
              width="100%">
              <Materials />
            </Section>
          </Flex.Item>
          <Flex.Item grow={1} m={1}>
            <Flex
              spacing={1}
              height="100%"
              overflowY="hide">
              <Flex.Item position="relative" basis="content">
                <Section
                  height="100%"
                  overflowY="auto"
                  title="Categories">
                  <PartSets />
                </Section>
              </Flex.Item>
              <Flex.Item
                position="relative"
                width="40%">
                <Section
                  fillPositionedParent
                  overflowY="auto"
                  title="Parts">
                  <PartLists />
                </Section>
              </Flex.Item>
              <Flex.Item grow={1}>
                <Section
                  height="100%"
                  overflowY="auto"
                  title="Queue">
                  <Queue />
                </Section>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Materials = (props, context) => {
  const { data } = useBackend(context);

  const { materials } = data;

  return (
    <Flex
      wrap="wrap">
      {materials.map(material => (
        <Flex.Item
          key={material.name}
          width="25%">
          {material.name} : {material.amount}
        </Flex.Item>
      ))}
    </Flex>
  );
};

const PartSets = (props, context) => {
  const { data } = useBackend(context);

  const {
    part_sets = [],
    buildable_parts = {},
  } = data;

  const [
    selectedPartTab,
    setSelectedPartTab,
  ] = useSharedState(context, "part_tab", part_sets.length ? part_sets[0] : "");

  return (
    <Tabs vertical>
      {part_sets.map(set => (
        <Tabs.Tab
          key={set}
          selected={set === selectedPartTab}
          disabled={!(buildable_parts[set])}
          onClick={() => setSelectedPartTab(set)}>
          {set}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};

const PartLists = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    part_sets = [],
    buildable_parts = {},
  } = data;

  const [
    selectedPartTab,
    setSelectedPartTab,
  ] = useSharedState(context, "part_tab", part_sets.length ? part_sets[0] : "");

  return (
    buildable_parts[selectedPartTab].map(part => (
      <Box
        key={part.name}>
        <Button
          height="22px"
          mr={1}
          icon="plus-circle"
          onClick={() => { act("add_queue_part", { id: part.id }); }} />
        {part.name}
      </Box>
    ))
  );
};

const Queue = (props, context) => {
  const { data } = useBackend(context);

  const {
    queue = [],
  } = data;

  return (
    queue.map(part => (
      <Box
        key={part.name}>
        {part.name}
      </Box>
    ))
  );
};

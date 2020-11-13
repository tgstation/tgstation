import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, BlockQuote, Button, Collapsible, Flex, Input, LabeledList, ProgressBar, Section, Tabs, Tooltip, Window } from '../components';

const PAGES = [
  { title: 'Researched' },
  { title: 'Available' },
  { title: 'Future' },
];

export const addNodeToResearch = (context, node_id) => {
  const { act, data } = useBackend(context);
  const {
    techweb_nodes,
    researched_nodes,
    research_queue,
    hidden_nodes,
  } = data;
  const node = techweb_nodes[node_id];
  const prereqs = node["assoc_list_strip_value(prereq_ids)"];

  for (let prereq of prereqs) {
    if (researched_nodes[prereq]) {
      continue;
    }
    if (research_queue.includes(prereq)) {
      continue;
    }
    if (hidden_nodes[prereq]) {
      alert("This technology requires something special to unlock it.");
      return false;
    }

    if (!addNodeToResearch(context, prereq)) {
      return false;
    }
  }

  act('add_node_to_queue', {
    node_id: node_id,
  });
  return true;
};

export const selectResearchNodes = (nodes, searchText = '', designs = []) => {
  const testSearch = createSearch(searchText, node => (
    node.display_name + " "
    + node.description + " "
    // List of design IDs
    + node["assoc_list_strip_value(design_ids)"].join(" "))
    // List of design names, if available.
    + (designs.length ? " "
      + node["assoc_list_strip_value(design_ids)"].map(design_id => {
        return designs[design_id]?.name + " ";
      }) : ""
    )
  );
  return flow([
    // Optional name search
    searchText && filter(testSearch),
  ])(nodes);
};

export const RdManagement = (props, context) => {
  return (
    <Window
      width={1280}
      height={640}
      resizable>
      <Window.Content>
        <RdManagementContent />
      </Window.Content>
    </Window>
  );
};

export const RdManagementContent = (props, context) => {
  const [
    pageIndex,
    setPageIndex,
  ] = useLocalState(context, 'pageIndex', 0);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  return (
    <Flex direction="row" height="100%">
      <Flex.Item grow={0} shrink={0}>
        <Tabs vertical>
          {PAGES.map((page, i) => (
            <Tabs.Tab
              key={i}
              color="transparent"
              selected={i === pageIndex}
              onClick={() => setPageIndex(i)}>
              {page.title}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Flex.Item>
      <Flex.Item grow={1} shrink={0} basis={0}>
        <Input m={1} mt={0} fluid
          placeholder="Search Nodes and Designs"
          onInput={(e, value) => setSearchText(value)} />
        <RdManagementPanes />
      </Flex.Item>
      <Flex.Item ml={1} grow={0} shrink={0} width="420px">
        <Section title="Research Queue" fill>
          <RdManagementPoints />
          <RdManagementQueue />
        </Section>
      </Flex.Item>
    </Flex>
  );
};

export const RdManagementPanes = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const [
    pageIndex,
    setPageIndex,
  ] = useLocalState(context, 'pageIndex', 0);
  const {
    techweb_nodes,
    techweb_designs,
    available_nodes,
    researched_nodes,
    research_queue,
    hidden_nodes,
    visible_nodes,
  } = data;

  let keys = [];
  // Researched
  if (pageIndex === 0) {
    keys = Object.keys(researched_nodes);
  }
  // Available
  else if (pageIndex === 1) {
    keys = Object.keys(available_nodes);
  }
  // Higher Tiers
  else {
    keys = Object.keys(techweb_nodes).filter(k =>
      // Nodes which don't appear in Available and which are not hidden.
      k !== "ERROR"
      && !Object.keys(researched_nodes).includes(k)
      && !Object.keys(available_nodes).includes(k)
      && !Object.keys(hidden_nodes).includes(k)
    );
  }
  let nodes = selectResearchNodes(
    keys.map(key => techweb_nodes[key]),
    searchText,
    techweb_designs
  );
  return (
    <Section fill scrollable m={1} height="94%">
      {nodes.map(node => {
        let researchButton;
        if (node.id in researched_nodes) {
          // Nothing.
        }
        else if (research_queue.includes(node.id)) {
          researchButton = (
            <Button
              icon="pause"
              color="bad"
              onClick={() => act('remove_node_from_queue', {
                node_id: node.id,
              })}>
              Pause
            </Button>
          );
        }
        else {
          researchButton = (
            <Button
              icon="play"
              color="good"
              onClick={() => addNodeToResearch(context, node.id)}>
              Queue
            </Button>
          );
          for (let prereq of node["assoc_list_strip_value(prereq_ids)"]) {
            if (hidden_nodes[prereq]) {
              researchButton = (
                <Button
                  icon="exclamation-triangle"
                  color="average">
                  Unknown
                </Button>
              );
              break;
            }
          }
        }
        return (
          <Collapsible
            key={node.id}
            title={node.display_name}
            buttons={researchButton}
            open={!!searchText}>
            <BlockQuote>
              {node.description}
            </BlockQuote>
            {node["assoc_list_strip_value(design_ids)"].map(design => {
              return (
                <Box key={design} inline position="relative">
                  <span key={design}
                    className={classes(['design32x32', design])}
                    style={{ 'vertical-align': 'middle' }} />
                  <Tooltip content={techweb_designs[design].name} />
                </Box>
              );
            })}
          </Collapsible>
        );
      })}
    </Section>
  );
};

export const RdManagementPoints = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    research_points,
  } = data;
  if (!Object.keys(research_points).length) {
    return;
  }
  if (!Object.values(research_points).reduce((a, b) => a + b)) {
    return;
  }
  return (
    <Box mb={1}>
      <strong>Stored Research</strong>
      <LabeledList>
        {Object.keys(research_points).map(point_type => {
          return (
            <LabeledList.Item label={point_type} key={point_type} mb={1}>
              {research_points[point_type]}
            </LabeledList.Item>
          );
        })}
      </LabeledList>
    </Box>
  );
};

export const RdManagementQueue = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    available_nodes,
    research_points,
    research_queue,
    researching_nodes,
    servers,
    techweb_nodes,
  } = data;

  return research_queue.map((node_id, i) => {
    const node = techweb_nodes[node_id];

    // If this node is actively being researched
    let researching_server = false;
    servers.forEach(server => {
      if (server.researching_node && server.researching_node.id === node_id) {
        researching_server = server;
        return false;
      }
    });

    // Determine if this node is boostable
    let boostable_node = false;
    if (available_nodes[node_id] && Object.keys(research_points).length) {
      for (let pool in research_points) {
        if (research_points[pool] === 0) {
          continue;
        }
        if (typeof node.research_costs[pool] === "undefined") {
          continue;
        }
        if (typeof researching_nodes[node_id] === "undefined") {
          boostable_node = true;
          break;
        }
        if (typeof researching_nodes[node_id][pool] === "undefined") {
          boostable_node = true;
          break;
        }
        if (node.research_costs[pool] - researching_nodes[node_id][pool] > 0) {
          boostable_node = true;
          break;
        }
      }
    }

    return (
      <Collapsible
        key={node_id}
        title={node.display_name}
        open={researching_server !== false}
        color={researching_server !== false ? "good" : ""}
        buttons={(
          <Box inline>
            {!boostable_node ? ""
              : <Button
                icon="bolt"
                color="grey"
                tooltip="Boost with stored research"
                tooltipPosition="bottom-left"
                onClick={() => act('boost_node', {
                  node_id: node_id,
                })}
              />}
            <Button mr={1}
              icon="pause"
              color="bad"
              onClick={() => act('remove_node_from_queue', {
                node_id: node_id,
              })}
            />
          </Box>
        )}>
        <Box ml={2} mr={1}>
          {Object.keys(node.research_costs).map(research_type => {
            let points = 0;
            if (researching_nodes[node_id]) {
              points = researching_nodes[node_id][research_type] || 0;
            }
            const remaining = node.research_costs[research_type];
            return (
              <ProgressBar
                key={research_type}
                minValue={0}
                maxValue={remaining}
                value={points}
                color="blue">
                {Math.floor(points)} / {remaining} {research_type}
              </ProgressBar>
            );
          })}
        </Box>
      </Collapsible>
    );
  });
};

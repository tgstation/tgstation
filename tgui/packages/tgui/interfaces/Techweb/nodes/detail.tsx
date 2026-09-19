import { useState } from 'react';
import {
  Button,
  Divider,
  Flex,
  Section,
  Tabs,
  VirtualList,
} from 'tgui-core/components';

import { useRemappedBackend } from '../helpers';
import { useTechWebRoute } from '../hooks';
import type { TechwebNode } from '../types';
import { TechNode } from './TechNode';

type NodeDetailProps = {
  selectedNode: string;
};

export function TechwebNodeDetail(props: NodeDetailProps) {
  const { selectedNode } = props;

  const { data } = useRemappedBackend();
  const { nodes } = data;

  const selectedNodeData =
    selectedNode && nodes.find((x) => x.path === selectedNode);

  if (!selectedNodeData) return;

  return <TechNodeDetail node={selectedNodeData} />;
}

type TechNodeDetailProps = {
  node: TechwebNode;
};

enum Tab {
  REQUIRED,
  UNLOCKS,
}

export function TechNodeDetail(props: TechNodeDetailProps) {
  const { node } = props;

  const { data } = useRemappedBackend();
  const { nodes, node_cache } = data;

  const { prerequisite_nodes, unlocked_nodes } = node_cache[node.path];

  const [tabIndex, setTabIndex] = useState(Tab.REQUIRED);
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  const prereqNodes = nodes.filter((x) => prerequisite_nodes.includes(x.path));
  const complPrereq = prerequisite_nodes.filter(
    (x) => nodes.find((y) => y.path === x)?.tier === 0,
  ).length;
  const unlockedNodes = nodes.filter((x) => unlocked_nodes.includes(x.path));

  return (
    <Flex direction="column" height="100%">
      <Flex.Item shrink={1}>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Node
          </Flex.Item>
          <Flex.Item grow>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === Tab.REQUIRED}
                onClick={() => setTabIndex(Tab.REQUIRED)}
              >
                Required ({complPrereq}/{prereqNodes.length})
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === Tab.UNLOCKS}
                // disabled={unlockedNodes.length === 0}
                onClick={() => setTabIndex(Tab.UNLOCKS)}
              >
                Unlocks ({unlockedNodes.length})
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            <Button icon="home" onClick={() => setTechwebRoute({ route: '' })}>
              Home
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item className="Techweb__OverviewNodes" shrink={0}>
        <TechNode node={node} nodetails />
        <Divider />
      </Flex.Item>
      {tabIndex === 0 && (
        <Flex.Item className="Techweb__OverviewNodes" grow>
          <Section scrollable fill>
            <VirtualList>
              {prereqNodes.map((n) => (
                <TechNode key={n.path} node={n} />
              ))}
            </VirtualList>
          </Section>
        </Flex.Item>
      )}
      {tabIndex === 1 && (
        <Flex.Item className="Techweb__OverviewNodes" grow>
          <Section scrollable fill>
            <VirtualList>
              {unlockedNodes.map((n) => (
                <TechNode key={n.path} node={n} />
              ))}
            </VirtualList>
          </Section>
        </Flex.Item>
      )}
    </Flex>
  );
}

import { useState } from 'react';
import { Button, Divider, Flex, Tabs } from 'tgui-core/components';

import { useLocalState } from '../../../backend';
import { useRemappedBackend } from '../helpers';
import { TechNode } from './TechNode';

export function TechwebNodeDetail(props) {
  const { data } = useRemappedBackend();
  const { nodes } = data;
  const { selectedNode } = props;

  const selectedNodeData =
    selectedNode && nodes.find((x) => x.id === selectedNode);
  return <TechNodeDetail node={selectedNodeData} />;
}

export function TechNodeDetail(props) {
  const { data } = useRemappedBackend();
  const { nodes, node_cache } = data;
  const { node } = props;
  const { id } = node;
  const { prereq_ids, unlock_ids } = node_cache[id];
  const [tabIndex, setTabIndex] = useState(0);
  const [techwebRoute, setTechwebRoute] = useLocalState('techwebRoute', null);

  const prereqNodes = nodes.filter((x) => prereq_ids.includes(x.id));
  const complPrereq = prereq_ids.filter(
    (x) => nodes.find((y) => y.id === x)?.tier === 0,
  ).length;
  const unlockedNodes = nodes.filter((x) => unlock_ids.includes(x.id));

  return (
    <Flex direction="column" height="100%">
      <Flex.Item shrink={1}>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            Node
          </Flex.Item>
          <Flex.Item grow={1}>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 0}
                onClick={() => setTabIndex(0)}
              >
                Required ({complPrereq}/{prereqNodes.length})
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 1}
                // disabled={unlockedNodes.length === 0}
                onClick={() => setTabIndex(1)}
              >
                Unlocks ({unlockedNodes.length})
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            <Button icon="home" onClick={() => setTechwebRoute(null)}>
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
        <Flex.Item className="Techweb__OverviewNodes" grow={1}>
          {prereqNodes.map((n) => (
            <TechNode key={n.id} node={n} />
          ))}
        </Flex.Item>
      )}
      {tabIndex === 1 && (
        <Flex.Item className="Techweb__OverviewNodes" grow={1}>
          {unlockedNodes.map((n) => (
            <TechNode key={n.id} node={n} />
          ))}
        </Flex.Item>
      )}
    </Flex>
  );
}

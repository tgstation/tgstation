/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
import { useState } from 'react';
import { JSONTree } from 'react-json-tree';
import { Divider, NoticeBox, Section, Stack, Tabs } from 'tgui-core/components';
import { useBackend } from '../backend';
import { tgui16 } from '../constants/theme';
import { Pane, Window } from '../layouts';

type Props = {
  panel?: boolean;
};

enum Tab {
  Config = 'config',
  Data = 'data',
  Shared = 'shared',
  Chunks = 'outgoingPayloadQueues',
  Components = 'components',
}

const tabs = [
  { name: 'Config', value: Tab.Config },
  { name: 'Data', value: Tab.Data },
  { name: 'Shared', value: Tab.Shared },
  { name: 'Chunks', value: Tab.Chunks },
] as const;

export function KitchenSink(props: Props) {
  const { panel } = props;

  const [activeTab, setActiveTab] = useState(Tab.Config);

  const Layout = panel ? Pane : Window;

  return (
    <Layout title="Kitchen Sink" width={600} height={500}>
      <Layout.Content>
        <Stack fill>
          <Stack.Item grow>
            <Tabs vertical>
              {tabs.map((tab) => (
                <Tabs.Tab
                  key={tab.name}
                  className="candystripe"
                  selected={activeTab === tab.value}
                  onClick={() => setActiveTab(tab.value)}
                >
                  {tab.name}
                </Tabs.Tab>
              ))}
              <Divider />
              <Tabs.Tab
                selected={activeTab === Tab.Components}
                onClick={() => setActiveTab(Tab.Components)}
              >
                Components
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow={4}>
            {activeTab === Tab.Components ? (
              <ComponentsPage />
            ) : (
              <TreePage tab={activeTab} />
            )}
          </Stack.Item>
        </Stack>
      </Layout.Content>
    </Layout>
  );
}

function ComponentsPage() {
  return (
    <Section fill>
      <NoticeBox info>All component stories have been moved.</NoticeBox>
      View them here{' '}
      <a href="https://tgstation.github.io/tgui-core">
        https://tgstation.github.io/tgui-core
      </a>
    </Section>
  );
}

type TreeProps = {
  tab: Tab;
};

function TreePage(props: TreeProps) {
  const { tab } = props;

  const backend = useBackend();
  const inView = backend[tab];

  return (
    <Section
      fill
      scrollable
      title={`${backend.config.interface.name ?? 'TGUI'} data`}
    >
      <div style={{ border: 'thin solid var(--color-base)' }}>
        <JSONTree data={inView} theme={tgui16} />
      </div>
    </Section>
  );
}

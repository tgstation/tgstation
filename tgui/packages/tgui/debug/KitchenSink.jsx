/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useState } from 'react';
import { Flex, Section, Tabs } from 'tgui-core/components';
import { useLocalState } from '../backend';

import { Pane, Window } from '../layouts';

const r = require.context('../stories', false, /\.stories\.jsx$/);

/**
 * @returns {{
 *   meta: {
 *     title: string,
 *     render: () => any,
 *   },
 * }[]}
 */
const getStories = () => r.keys().map((path) => r(path));

export const KitchenSink = (props) => {
  const { panel } = props;
  const [theme, setTheme] = useLocalState('kitchenSinkTheme');
  const [pageIndex, setPageIndex] = useState(0);
  const stories = getStories();
  const story = stories[pageIndex];
  const Layout = panel ? Pane : Window;
  return (
    <Layout title="Kitchen Sink" width={600} height={500} theme={theme}>
      <Flex height="100%">
        <Flex.Item m={1} mr={0}>
          <Section fill fitted>
            <Tabs vertical>
              {stories.map((story, i) => (
                <Tabs.Tab
                  key={i}
                  color="transparent"
                  selected={i === pageIndex}
                  onClick={() => setPageIndex(i)}
                >
                  {story.meta.title}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Flex.Item>
        <Flex.Item position="relative" grow={1}>
          <Layout.Content scrollable>{story.meta.render()}</Layout.Content>
        </Flex.Item>
      </Flex>
    </Layout>
  );
};

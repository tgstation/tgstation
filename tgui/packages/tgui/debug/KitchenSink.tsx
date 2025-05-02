/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useState } from 'react';
import { Section, Stack, Tabs } from 'tgui-core/components';

import { Pane, Window } from '../layouts';

const r = require.context('../stories', false, /\.stories\.tsx$/);

/**
 * @returns {{
 *   meta: {
 *     title: string,
 *     render: () => any,
 *   },
 * }[]}
 */
function getStories() {
  return r.keys().map((path) => r(path));
}

export function KitchenSink(props) {
  const { panel } = props;

  const [pageIndex, setPageIndex] = useState(0);

  const stories = getStories();
  const story = stories[pageIndex];
  const Layout = panel ? Pane : Window;

  return (
    <Layout title="Kitchen Sink" width={600} height={500}>
      <Layout.Content>
        <Stack fill>
          <Stack.Item>
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
          </Stack.Item>
          <Stack.Item grow>{story.meta.render()}</Stack.Item>
        </Stack>
      </Layout.Content>
    </Layout>
  );
}

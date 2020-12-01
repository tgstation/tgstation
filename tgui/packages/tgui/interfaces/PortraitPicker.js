import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const PortraitPicker = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [listIndex, setListIndex] = useLocalState(context, 'listIndex', 0);
  const {
    library,
    library_secure,
    library_private,
  } = data;
  const TABS = [
    {
      name: 'Common Portraits',
      list: library,
    },
    {
      name: 'Secure Portraits',
      list: library_secure,
    },
    {
      name: 'Private Portraits',
      list: library_private,
    },
  ];
  const tab2list = TABS[tabIndex].list;
  const current_portrait = tab2list[listIndex]["title"];
  return (
    <Window
      theme="ntos"
      title="Portrait Picker"
      width={400}
      height={406}>
      <Window.Content>
        <Flex height="100%" direction="column">
          <Flex.Item mb={1}>
            <Section fitted>
              <Tabs fluid textAlign="center">
                {TABS.map((tabObj, i) => (
                  <Tabs.Tab
                    key={i}
                    selected={i === tabIndex}
                    onClick={() => {
                      setListIndex(0);
                      setTabIndex(i);
                    }}>
                    {tabObj.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Flex.Item>
          <Flex.Item mb={1} grow={2}>
            <Section fill>
              <Flex
                height="100%"
                align="center"
                justify="center"
                direction="column">
                <Flex.Item>
                  <img
                    src={resolveAsset(current_portrait)}
                    height="96px"
                    width="96px"
                    style={{
                      'vertical-align': 'middle',
                      '-ms-interpolation-mode': 'nearest-neighbor',
                    }} />
                </Flex.Item>
                <Flex.Item className="Section__titleText">
                  {current_portrait}
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Flex>
              <Flex.Item grow={3}>
                <Section height="100%">
                  <Flex justify="space-between">
                    <Flex.Item grow={1}>
                      <Button
                        icon="angle-double-left"
                        disabled={listIndex === 0}
                        onClick={() => setListIndex(0)}
                      />
                    </Flex.Item>
                    <Flex.Item grow={3}>
                      <Button
                        disabled={listIndex === 0}
                        icon="chevron-left"
                        onClick={() => setListIndex(listIndex-1)}
                      />
                    </Flex.Item>
                    <Flex.Item grow={3}>
                      <Button
                        icon="check"
                        content="Select Portrait"
                        onClick={() => act("select", {
                          tab: tabIndex+1,
                          selected: listIndex+1,
                        })}
                      />
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <Button
                        icon="chevron-right"
                        disabled={listIndex === tab2list.length-1}
                        onClick={() => setListIndex(listIndex+1)}
                      />
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        icon="angle-double-right"
                        disabled={listIndex === tab2list.length-1}
                        onClick={() => setListIndex(tab2list.length-1)}
                      />
                    </Flex.Item>
                  </Flex>
                </Section>
              </Flex.Item>
            </Flex>
            <Flex.Item mt={1}>
              <NoticeBox info>
                Only the 23x23 or 24x24 canvas size art can be
                displayed. Make sure you read the warning below
                before embracing the wide wonderful world of
                artistic expression!
              </NoticeBox>
            </Flex.Item>
            <Flex.Item>
              <NoticeBox danger>
                WARNING: While Central Command loves art as much as you do,
                choosing erotic art will lead to severe consequences.
                Additionally, Central Command reserves the right to request
                you change your display portrait, for any reason.
              </NoticeBox>
            </Flex.Item>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

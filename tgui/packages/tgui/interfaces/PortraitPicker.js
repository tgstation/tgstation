import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Fragment, Section, Tabs, NoticeBox } from '../components';
import { Window } from '../layouts';
import { classes } from 'common/react';

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
      name:'Common Portraits',
      list:library,
    },
    {
      name:'Secure Portraits',
      list:library_secure,
    },
    {
      name:'Private Portraits',
      list:library_private,
    },
  ];
  const tab2list = TABS[tabIndex].list
  const current_portrait = tab2list[listIndex]["title"];
  return (
    <Window
      theme="ntos"
      title="Portrait Picker"
      width={400}
      height={270}>
      <Window.Content>
        <Flex height="100%" direction="column">
          <Flex.Item mb={1}>
            <Section>
              <Tabs fluid={1}>
                {TABS.map((tabObj, i) => (
                  <Tabs.Tab
                    key={i}
                    selected={i == tabIndex}
                    onClick={() => {setListIndex(0); setTabIndex(i); }}>
                    {tabObj.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1}
            style={{
              'background-image': 'url("'
                + resolveAsset(current_portrait)
                + '")',
              'pointer-events': 'none',
              'background-position': 'center',
              'background-repeat': 'no-repeat',
              'transform': 'scale(5)',
            }}/>
          <Flex.Item bold align="center">
            {current_portrait}
          </Flex.Item>
          <Flex.Item>
            <Flex>
              <Flex.Item grow={1}>
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
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

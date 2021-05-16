import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Button, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

export const PortraitPrinter = (props, context) => {
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
      asset_prefix: "library",
      list: library,
    },
    {
      name: 'Secure Portraits',
      asset_prefix: "library_secure",
      list: library_secure,
    },
    {
      name: 'Private Portraits',
      asset_prefix: "library_private",
      list: library_private,
    },
  ];
  const tab2list = TABS[tabIndex].list;
  const current_portrait_title = tab2list[listIndex]["title"];
  const current_portrait_asset_name = TABS[tabIndex].asset_prefix + "_" + tab2list[listIndex]["md5"];
  return (
    <Window
      theme="ntos"
      title="Portrait Picker"
      width={400}
      height={406}>
      <Window.Content>
        <Stack fill>
          <Stack.Item mb={1}>
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
          </Stack.Item>
          <Stack.Item mb={1} grow={2}>
            <Section fill>
              <Stack
                height="100%"
                align="center"
                justify="center"
                direction="column">
                <Stack.Item>
                  <img
                    src={resolveAsset(current_portrait_asset_name)}
                    height="96px"
                    width="96px"
                    style={{
                      'vertical-align': 'middle',
                      '-ms-interpolation-mode': 'nearest-neighbor',
                    }} />
                </Stack.Item>
                <Stack.Item className="Section__titleText">
                  {current_portrait_title}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item grow={3}>
                <Section height="100%">
                  <Stack justify="space-between">
                    <Stack.Item grow={1}>
                      <Button
                        icon="angle-double-left"
                        disabled={listIndex === 0}
                        onClick={() => setListIndex(0)}
                      />
                    </Stack.Item>
                    <Stack.Item grow={3}>
                      <Button
                        disabled={listIndex === 0}
                        icon="chevron-left"
                        onClick={() => setListIndex(listIndex-1)}
                      />
                    </Stack.Item>
                    <Stack.Item grow={3}>
                      <Button
                        icon="check"
                        content="Select Portrait"
                        onClick={() => act("select", {
                          tab: tabIndex+1,
                          selected: listIndex+1,
                        })}
                      />
                    </Stack.Item>
                    <Stack.Item grow={1}>
                      <Button
                        icon="chevron-right"
                        disabled={listIndex === tab2list.length-1}
                        onClick={() => setListIndex(listIndex+1)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="angle-double-right"
                        disabled={listIndex === tab2list.length-1}
                        onClick={() => setListIndex(tab2list.length-1)}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
            <Stack.Item mt={1}>
              <NoticeBox info>
                Only the 23x23 or 24x24 canvas size art can be
                displayed. Make sure you read the warning below
                before embracing the wide wonderful world of
                artistic expression!
              </NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <NoticeBox danger>
                WARNING: While Central Command loves art as much as you do,
                choosing erotic art will lead to severe consequences.
                Additionally, Central Command reserves the right to request
                you change your display portrait, for any reason.
              </NoticeBox>
            </Stack.Item>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

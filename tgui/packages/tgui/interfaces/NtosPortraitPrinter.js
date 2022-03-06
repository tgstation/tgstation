import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Button, NoticeBox, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPortraitPrinter = (props, context) => {
  const { act, data } = useBackend(context);
  const [listIndex, setListIndex] = useLocalState(context, 'listIndex', 0);
  const {
    paintings,
  } = data;
  const current_portrait_title = paintings[listIndex]["title"];
  const current_portrait_asset_name = "paintings" + "_" + paintings[listIndex]["md5"];
  return (
    <NtosWindow
      title="Art Galaxy"
      width={400}
      height={406}>
      <NtosWindow.Content>
        <Stack vertical fill>
          <Stack.Item grow={2}>
            <Section fill>
              <Stack
                height="100%"
                align="center"
                justify="center"
                direction="column">
                <Stack.Item>
                  <img
                    src={resolveAsset(current_portrait_asset_name)}
                    height="128px"
                    width="128px"
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
                        content="Print Portrait"
                        onClick={() => act("select", {
                          selected: paintings[listIndex]["ref"],
                        })}
                      />
                    </Stack.Item>
                    <Stack.Item grow={1}>
                      <Button
                        icon="chevron-right"
                        disabled={listIndex === paintings.length-1}
                        onClick={() => setListIndex(listIndex+1)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="angle-double-right"
                        disabled={listIndex === paintings.length-1}
                        onClick={() => setListIndex(paintings.length-1)}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
            <Stack.Item mt={1} mb={-1}>
              <NoticeBox info>
                Printing a canvas costs 10 paper from
                the printer installed in your machine.
              </NoticeBox>
            </Stack.Item>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

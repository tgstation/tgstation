import { useState } from 'react';
import { Button, Flex, Input, NoticeBox, Section } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export const PortraitPicker = (props) => {
  const { act, data } = useBackend();
  const [listIndex, setListIndex] = useState(0);
  const { paintings, search_string, search_mode } = data;
  const got_paintings = !!paintings.length;
  const current_portrait_title = got_paintings && paintings[listIndex]['title'];
  const current_portrait_author =
    got_paintings && 'By ' + paintings[listIndex]['creator'];
  const current_portrait_asset_name =
    got_paintings && 'paintings' + '_' + paintings[listIndex]['md5'];

  return (
    <Window theme="ntos" title="Portrait Picker" width={400} height={406}>
      <Window.Content>
        <Flex height="100%" direction="column">
          <Flex.Item mb={1}>
            <Section title="Search">
              <Input
                fluid
                placeholder="Search Paintings..."
                value={search_string}
                expensive
                onChange={(value) => {
                  act('search', {
                    to_search: value,
                  });
                  setListIndex(0);
                }}
              />
              <Button
                content={search_mode}
                onClick={() => {
                  act('change_search_mode');
                  if (search_string) {
                    setListIndex(0);
                  }
                }}
              />
            </Section>
          </Flex.Item>
          <Flex.Item mb={1} grow={2}>
            <Section fill>
              <Flex
                height="100%"
                align="center"
                justify="center"
                direction="column"
              >
                {got_paintings ? (
                  <>
                    <Flex.Item>
                      <img
                        src={resolveAsset(current_portrait_asset_name)}
                        height="128px"
                        width="128px"
                        style={{
                          verticalAlign: 'middle',
                        }}
                      />
                    </Flex.Item>
                    <Flex.Item className="Section__titleText">
                      {current_portrait_title}
                    </Flex.Item>
                    <Flex.Item>{current_portrait_author}</Flex.Item>
                  </>
                ) : (
                  <Flex.Item className="Section__titleText">
                    No paintings found.
                  </Flex.Item>
                )}
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
                        onClick={() => setListIndex(listIndex - 1)}
                      />
                    </Flex.Item>
                    <Flex.Item grow={3}>
                      <Button
                        icon="check"
                        content="Select Portrait"
                        disabled={!got_paintings}
                        onClick={() =>
                          act('select', {
                            selected: paintings[listIndex]['ref'],
                          })
                        }
                      />
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <Button
                        icon="chevron-right"
                        disabled={listIndex >= paintings.length - 1}
                        onClick={() => setListIndex(listIndex + 1)}
                      />
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        icon="angle-double-right"
                        disabled={listIndex >= paintings.length - 1}
                        onClick={() => setListIndex(paintings.length - 1)}
                      />
                    </Flex.Item>
                  </Flex>
                </Section>
              </Flex.Item>
            </Flex>
            <Flex.Item mt={1}>
              <NoticeBox info>
                Only the 23x23 or 24x24 canvas size art can be displayed. Make
                sure you read the warning below before embracing the wide
                wonderful world of artistic expression!
              </NoticeBox>
            </Flex.Item>
            <Flex.Item>
              <NoticeBox danger>
                WARNING: While Central Command loves art as much as you do,
                choosing erotic art will lead to severe consequences.
                Additionally, Central Command reserves the right to request you
                change your display portrait, for any reason.
              </NoticeBox>
            </Flex.Item>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

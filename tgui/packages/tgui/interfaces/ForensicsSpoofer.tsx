import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  silent: BooleanLike;
  scanmode: BooleanLike;
  fibers: string[];
  fingerprints: string[];
  chosen_fiber: string;
  chosen_fingerprint: string;
  max_storage: number;
};
export const ForensicsSpoofer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    silent,
    scanmode,
    fibers,
    fingerprints,
    chosen_fiber,
    chosen_fingerprint,
    max_storage,
  } = data;
  const [currentTab, setTab] = useState(0);
  return (
    <Window
      title="Forensics Spoofing Device"
      width={460}
      height={340}
      theme="syndicate"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item width="50%">
                  <Button
                    width="100%"
                    icon={silent ? 'eye-slash' : 'eye'}
                    content={silent ? 'Silent Mode: On' : 'Silent Mode: Off'}
                    tooltip="On Silent Mode this device will make the same sounds and sights as an actual Forensics Scanner."
                    onClick={() => act('stealth')}
                  />
                </Stack.Item>
                <Stack.Item width="50%">
                  <Button
                    width="100%"
                    icon={scanmode ? 'magnifying-glass' : 'share-from-square'}
                    content={scanmode ? 'Mode: Scan' : 'Mode: Apply'}
                    color={scanmode ? 'blue' : 'red'}
                    onClick={() => act('scanmode')}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill>
              <Tabs fluid>
                <Tabs.Tab
                  icon="fingerprint"
                  selected={currentTab === 0}
                  onClick={() => setTab(0)}
                  width="50%"
                >
                  Fingerprints {Object.keys(fingerprints).length}/{max_storage}
                </Tabs.Tab>
                <Tabs.Tab
                  icon="shirt"
                  selected={currentTab === 1}
                  width="50%"
                  onClick={() => setTab(1)}
                >
                  Fibers {Object.keys(fibers).length}/{max_storage}
                </Tabs.Tab>
              </Tabs>
              <Divider />
              <Stack vertical>
                {Object.keys(currentTab === 0 ? fingerprints : fibers).map(
                  (forensic_data, _) => (
                    <Stack.Item key={forensic_data}>
                      <Stack>
                        <Stack.Item>
                          <Button.Checkbox
                            checked={
                              (currentTab === 0
                                ? chosen_fingerprint
                                : chosen_fiber) === forensic_data
                            }
                            onClick={() =>
                              act('choose', { chosen: forensic_data })
                            }
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            width="1.9rem"
                            color="red"
                            onClick={() =>
                              act('delete', { chosen: forensic_data })
                            }
                          >
                            <Icon name="trash" />
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Box pt="0.25rem">
                            {currentTab === 0
                              ? forensic_data.substring(0, 25)
                              : forensic_data}
                          </Box>
                        </Stack.Item>
                        {currentTab === 0 && (
                          <Stack.Item grow>
                            <Box
                              bold
                              fontSize="14px"
                              pt="0.2rem"
                              width="100%"
                              textAlign="right"
                            >
                              ({fingerprints[forensic_data]})
                            </Box>
                          </Stack.Item>
                        )}
                      </Stack>
                    </Stack.Item>
                  ),
                )}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

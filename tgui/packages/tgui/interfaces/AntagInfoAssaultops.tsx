// THIS IS A SKYRAT UI FILE
import { BooleanLike } from 'common/react';

import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  Divider,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type Objectives = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
};

type AvailableTargets = {
  name: string;
  job: string;
};

type ExtractedTargets = {
  name: string;
  job: string;
};

type GoldeneyeKeys = {
  coord_x: number;
  coord_y: number;
  coord_z: number;
  name: string;
  ref: string;
  selected: BooleanLike;
};

type Info = {
  equipped: number;
  required_keys: number;
  uploaded_keys: number;
  objectives: Objectives[];
  available_targets: AvailableTargets[];
  extracted_targets: ExtractedTargets[];
  goldeneye_keys: GoldeneyeKeys[];
};

export const AntagInfoAssaultops = (props) => {
  const [tab, setTab] = useSharedState('tab', 1);
  const { data } = useBackend<Info>();
  const { required_keys, uploaded_keys, objectives } = data;
  return (
    <Window theme="hackerman" width={650} height={650}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Section>
              <Stack.Item grow={1} align="center">
                <Box fontSize={0.8} textAlign="right">
                  GoldeneEye Defnet &nbsp;
                  <Box color="green" as="span">
                    Connection Secure
                  </Box>
                </Box>
              </Stack.Item>
              <Section title="GoldenEye Subversion Progress" fontSize="15px">
                {uploaded_keys >= required_keys ? (
                  <Box fontSize="20px" color="green">
                    GOLDENEYE ACTIVATED, WELL DONE OPERATIVE.
                  </Box>
                ) : (
                  <Stack>
                    <Stack.Item grow>
                      <ProgressBar
                        color="green"
                        value={uploaded_keys}
                        minValue={0}
                        maxValue={required_keys}
                      />
                    </Stack.Item>
                    <Stack.Item color="yellow">
                      Required Keycards: {required_keys}
                    </Stack.Item>
                    <Stack.Item color="green">
                      Uploaded Keycards: {uploaded_keys}
                    </Stack.Item>
                  </Stack>
                )}
              </Section>
            </Section>
            <Section title="Objectives">
              <LabeledList>
                {objectives.map((objective) => (
                  <LabeledList.Item
                    key={objective.count}
                    label={objective.name}
                    color={objective.complete ? 'good' : 'bad'}
                  >
                    {objective.explanation}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack vertical mb={1}>
              <Stack.Item>
                <Tabs fill>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 1}
                    onClick={() => setTab(1)}
                  >
                    Targets
                  </Tabs.Tab>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 2}
                    onClick={() => setTab(2)}
                  >
                    GoldenEye Keycards
                  </Tabs.Tab>
                </Tabs>
              </Stack.Item>
            </Stack>
            {tab === 1 && <TargetPrintout />}
            {tab === 2 && <KeyPrintout />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TargetPrintout = (props) => {
  const { act, data } = useBackend<Info>();
  const { available_targets, extracted_targets } = data;
  return (
    <Section>
      <Box textColor="red" fontSize="20px" mb={1}>
        Target List
      </Box>
      <Stack>
        <Stack.Item grow>
          <Section title="Available Targets">
            <Box textColor="red" mb={2}>
              These are targets you have not yet extracted a GoldenEye key from.
              They can be extracted by the in-TERROR-gator.
            </Box>
            <LabeledList>
              {available_targets.map((target) => (
                <LabeledList.Item
                  key={target.name}
                  label={target.name}
                  color="red"
                >
                  {target.job}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item grow>
          <Section title="Extracted Targets">
            <Box textColor="green" mb={2}>
              These are targets you have extracted a GoldenEye keycard from.
              They cannot be extracted again.
            </Box>
            <LabeledList>
              {extracted_targets.map((target) => (
                <LabeledList.Item
                  key={target.name}
                  label={target.name}
                  color="good"
                >
                  {target.job}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
// Utils have goldeneye key list, current heads of staff, extracted heads
// Common target button, track key button

const KeyPrintout = (props) => {
  const { act, data } = useBackend<Info>();
  const { goldeneye_keys } = data;
  return (
    <Section>
      <Box textColor="red" fontSize="20px">
        GoldenEye Keycards
      </Box>
      <Box mb={1}>
        A list of GoldenEye keycards currently in existence. Select one to track
        where it is using your hud.
      </Box>
      <Stack vertical fill>
        <Stack.Item>
          <Section>
            <Stack vertical>
              {goldeneye_keys.map((key) => (
                <Stack.Item key={key.name}>
                  <Button
                    width="100%"
                    textAlign="center"
                    color="yellow"
                    disabled={key.selected}
                    key={key.name}
                    icon="key"
                    content={
                      key.selected
                        ? key.name +
                          ' (' +
                          key.coord_x +
                          ', ' +
                          key.coord_y +
                          ', ' +
                          key.coord_z +
                          ')' +
                          ' (Tracking)'
                        : key.name +
                          ' (' +
                          key.coord_x +
                          ', ' +
                          key.coord_y +
                          ', ' +
                          key.coord_z +
                          ')'
                    }
                    onClick={() =>
                      act('track_key', {
                        key_ref: key.ref,
                      })
                    }
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

import {
  Box,
  Button,
  Icon,
  LabeledControls,
  NumberInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  reflector_name: string;
  rotation_angle: number;
};
export const Reflector = (props) => {
  const { act, data } = useBackend<Data>();
  const { reflector_name, rotation_angle } = data;
  return (
    <Window title={reflector_name} height={200} width={219}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Section title="Presets" textAlign="center" fill>
              <Table mt={3.5}>
                <Table.Cell>
                  <Table.Row>
                    <Button
                      icon="arrow-left"
                      iconRotation={45}
                      mb={1}
                      onClick={() =>
                        act('rotate', {
                          rotation_angle: 315,
                        })
                      }
                    />
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-left"
                      mb={1}
                      onClick={() =>
                        act('rotate', {
                          rotation_angle: 270,
                        })
                      }
                    />
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-left"
                      iconRotation={-45}
                      mb={1}
                      onClick={() =>
                        act('rotate', {
                          rotation_angle: 225,
                        })
                      }
                    />
                  </Table.Row>
                </Table.Cell>
                <Table.Cell>
                  <Table.Row>
                    <Button
                      icon="arrow-up"
                      mb={1}
                      onClick={() =>
                        act('rotate', {
                          rotation_angle: 0,
                        })
                      }
                    />
                  </Table.Row>
                  <Table.Row>
                    <Box px={0.75}>
                      <Icon
                        name="angle-double-up"
                        size={1.66}
                        rotation={rotation_angle}
                        mb={1}
                      />
                    </Box>
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-down"
                      mb={1}
                      onClick={() =>
                        act('rotate', {
                          rotation_angle: 180,
                        })
                      }
                    />
                  </Table.Row>
                </Table.Cell>
                <Table.Cell>
                  <Table.Row>
                    <Button
                      icon="arrow-right"
                      iconRotation={-45}
                      mb={1}
                      onClick={() =>
                        act('rotate', {
                          rotation_angle: 45,
                        })
                      }
                    />
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-right"
                      mb={1}
                      onClick={() =>
                        act('rotate', {
                          rotation_angle: 90,
                        })
                      }
                    />
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-right"
                      iconRotation={45}
                      mb={1}
                      onClick={() =>
                        act('rotate', {
                          rotation_angle: 135,
                        })
                      }
                    />
                  </Table.Row>
                </Table.Cell>
              </Table>
            </Section>
          </Stack.Item>
          <Stack>
            <Section title="Angle" textAlign="center" fill>
              <LabeledControls>
                <LabeledControls.Item ml={0.5} label="Set rotation">
                  <NumberInput
                    value={rotation_angle}
                    unit="degrees"
                    minValue={0}
                    maxValue={359}
                    step={1}
                    stepPixelSize={1}
                    onDrag={(value) =>
                      act('rotate', {
                        rotation_angle: value,
                      })
                    }
                  />
                </LabeledControls.Item>
              </LabeledControls>
              <Stack fill>
                <Stack fill vertical>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="undo-alt"
                      content="-5"
                      mb={1}
                      onClick={() =>
                        act('calculate', {
                          rotation_angle: -5,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack>
                    <Button
                      fluid
                      icon="undo-alt"
                      content="-10"
                      mb={1}
                      onClick={() =>
                        act('calculate', {
                          rotation_angle: -10,
                        })
                      }
                    />
                  </Stack>
                  <Stack>
                    <Button
                      fluid
                      icon="undo-alt"
                      content="-15"
                      mb={1}
                      onClick={() =>
                        act('calculate', {
                          rotation_angle: -15,
                        })
                      }
                    />
                  </Stack>
                </Stack>
                <Stack vertical>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="redo-alt"
                      iconPosition="right"
                      content="+5"
                      mb={1}
                      onClick={() =>
                        act('calculate', {
                          rotation_angle: 5,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack>
                    <Button
                      fluid
                      icon="redo-alt"
                      iconPosition="right"
                      content="+10"
                      mb={1}
                      onClick={() =>
                        act('calculate', {
                          rotation_angle: 10,
                        })
                      }
                    />
                  </Stack>
                  <Stack>
                    <Button
                      fluid
                      icon="redo-alt"
                      iconPosition="right"
                      content="+15"
                      mb={1}
                      onClick={() =>
                        act('calculate', {
                          rotation_angle: 15,
                        })
                      }
                    />
                  </Stack>
                </Stack>
              </Stack>
            </Section>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};

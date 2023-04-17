import { useBackend } from '../backend';
import { Box, Button, Flex, Stack, Icon, LabeledControls, Section, NumberInput, Table } from '../components';
import { Window } from '../layouts';

export const Reflector = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title={data.reflector_name}
      height={200}
      width={219}>
      <Window.Content>
        <Flex direction="row">
          <Flex.Item>
            <Section
              title="Presets"
              textAlign="center"
              fill>
              <Table mt={3.5}>
                <Table.Cell>
                  <Table.Row>
                    <Button
                      icon="arrow-left"
                      iconRotation={45}
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 315,
                      })} />
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-left"
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 270,
                      })} />
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-left"
                      iconRotation={-45}
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 225,
                      })} />
                  </Table.Row>
                </Table.Cell>
                <Table.Cell>
                  <Table.Row>
                    <Button
                      icon="arrow-up"
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 0,
                      })} />
                  </Table.Row>
                  <Table.Row>
                    <Box px={0.75}>
                      <Icon
                        name="angle-double-up"
                        size={1.66}
                        rotation={data.rotation_angle}
                        mb={1}
                      />
                    </Box>
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-down"
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 180,
                      })} />
                  </Table.Row>
                </Table.Cell>
                <Table.Cell>
                  <Table.Row>
                    <Button
                      icon="arrow-right"
                      iconRotation={-45}
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 45,
                      })} />
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-right"
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 90,
                      })} />
                  </Table.Row>
                  <Table.Row>
                    <Button
                      icon="arrow-right"
                      iconRotation={45}
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 135,
                      })} />
                  </Table.Row>
                </Table.Cell>
              </Table>
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section
              title="Angle"
              textAlign="center"
              fill>
              <LabeledControls>
                <LabeledControls.Item ml={0.5} label="Set rotation">
                  <NumberInput
                    value={data.rotation_angle}
                    unit="degrees"
                    minValue={0}
                    maxValue={359}
                    step={1}
                    stepPixelSize={1}
                    onDrag={(e, value) => act('rotate', {
                      rotation_angle: value,
                    })} />
                </LabeledControls.Item>
              </LabeledControls>
              <Flex direction="row" grow={1}>
                <Flex direction="column" grow={1}>
                  <Flex.Item>
                    <Button
                      fluid
                      icon="undo-alt"
                      content="-5"
                      mb={1}
                      onClick={() => act('calculate', {
                        rotation_angle: -5,
                      })} />
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      fluid
                      icon="undo-alt"
                      content="-10"
                      mb={1}
                      onClick={() => act('calculate', {
                        rotation_angle: -10,
                      })} />
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      fluid
                      icon="undo-alt"
                      content="-15"
                      mb={1}
                      onClick={() => act('calculate', {
                        rotation_angle: -15,
                      })} />
                  </Flex.Item>
                </Flex>
                <Flex direction="column">
                  <Flex.Item>
                    <Button
                      fluid
                      icon="redo-alt"
                      iconPosition="right"
                      content="+5"
                      mb={1}
                      onClick={() => act('calculate', {
                        rotation_angle: 5,
                      })} />
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      fluid
                      icon="redo-alt"
                      iconPosition="right"
                      content="+10"
                      mb={1}
                      onClick={() => act('calculate', {
                        rotation_angle: 10,
                      })} />
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      fluid
                      icon="redo-alt"
                      iconPosition="right"
                      content="+15"
                      mb={1}
                      onClick={() => act('calculate', {
                        rotation_angle: 15,
                      })} />
                  </Flex.Item>
                </Flex>
              </Flex>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

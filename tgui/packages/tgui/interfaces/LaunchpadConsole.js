import { useBackend } from '../backend';
import { Box, Button, Divider, Flex, Grid, Input, NoticeBox, NumberInput, Section } from '../components';
import { Window } from '../layouts';

const LaunchpadButtonPad = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Grid width="1px">
      <Grid.Column>
        <Button
          fluid
          icon="arrow-left"
          iconRotation={45}
          mb={1}
          onClick={() => act('move_pos', {
            x: -1,
            y: 1,
          })} />
        <Button
          fluid
          icon="arrow-left"
          mb={1}
          onClick={() => act('move_pos', {
            x: -1,
          })} />
        <Button
          fluid
          icon="arrow-down"
          iconRotation={45}
          mb={1}
          onClick={() => act('move_pos', {
            x: -1,
            y: -1,
          })} />
      </Grid.Column>
      <Grid.Column>
        <Button
          fluid
          icon="arrow-up"
          mb={1}
          onClick={() => act('move_pos', {
            y: 1,
          })} />
        <Button
          fluid
          content="R"
          mb={1}
          onClick={() => act('set_pos', {
            x: 0,
            y: 0,
          })} />
        <Button
          fluid
          icon="arrow-down"
          mb={1}
          onClick={() => act('move_pos', {
            y: -1,
          })} />
      </Grid.Column>
      <Grid.Column>
        <Button
          fluid
          icon="arrow-up"
          iconRotation={45}
          mb={1}
          onClick={() => act('move_pos', {
            x: 1,
            y: 1,
          })} />
        <Button
          fluid
          icon="arrow-right"
          mb={1}
          onClick={() => act('move_pos', {
            x: 1,
          })} />
        <Button
          fluid
          icon="arrow-right"
          iconRotation={45}
          mb={1}
          onClick={() => act('move_pos', {
            x: 1,
            y: -1,
          })} />
      </Grid.Column>
    </Grid>
  );
};

export const LaunchpadControl = (props, context) => {
  const { topLevel } = props;
  const { act, data } = useBackend(context);
  const {
    x,
    y,
    pad_name,
    range,
  } = data;
  return (
    <Section
      title={(
        <Input
          value={pad_name}
          width="170px"
          onChange={(e, value) => act('rename', {
            name: value,
          })} />
      )}
      level={topLevel ? 1 : 2}
      buttons={(
        <Button
          icon="times"
          content="Remove"
          color="bad"
          onClick={() => act('remove')} />
      )}>
      <Grid>
        <Grid.Column>
          <Section title="Controls" level={2}>
            <LaunchpadButtonPad />
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title="Target" level={2}>
            <Box fontSize="26px">
              <Box mb={1}>
                <Box
                  inline
                  bold
                  mr={1}>
                  X:
                </Box>
                <NumberInput
                  value={x}
                  minValue={-range}
                  maxValue={range}
                  lineHeight="30px"
                  fontSize="26px"
                  width="90px"
                  height="30px"
                  stepPixelSize={10}
                  onChange={(e, value) => act('set_pos', {
                    x: value,
                  })} />
              </Box>
              <Box>
                <Box
                  inline
                  bold
                  mr={1}>
                  Y:
                </Box>
                <NumberInput
                  value={y}
                  minValue={-range}
                  maxValue={range}
                  stepPixelSize={10}
                  lineHeight="30px"
                  fontSize="26px"
                  width="90px"
                  height="30px"
                  onChange={(e, value) => act('set_pos', {
                    y: value,
                  })} />
              </Box>
            </Box>
          </Section>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <Button
            fluid
            icon="upload"
            content="Launch"
            textAlign="center"
            onClick={() => act('launch')} />
        </Grid.Column>
        <Grid.Column>
          <Button
            fluid
            icon="download"
            content="Pull"
            textAlign="center"
            onClick={() => act('pull')} />
        </Grid.Column>
      </Grid>
    </Section>
  );
};

export const LaunchpadConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    launchpads = [],
    selected_id,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        {launchpads.length === 0 && (
          <NoticeBox>
            No Pads Connected
          </NoticeBox>
        ) || (
          <Section>
            <Flex minHeight="190px">
              <Flex.Item width="140px" minHeight="190px">
                {launchpads.map(launchpad => (
                  <Button
                    fluid
                    ellipsis
                    key={launchpad.name}
                    content={launchpad.name}
                    selected={selected_id === launchpad.id}
                    color="transparent"
                    onClick={() => act('select_pad', {
                      id: launchpad.id,
                    })} />
                ))}
              </Flex.Item>
              <Flex.Item minHeight="100%">
                <Divider vertical />
              </Flex.Item>
              <Flex.Item grow={1} basis={0} minHeight="100%">
                {selected_id && (
                  <LaunchpadControl />
                ) || (
                  <Box>
                    Please select a pad
                  </Box>
                )}
              </Flex.Item>
            </Flex>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

import { useBackend } from '../backend';
import { Box, Button, ColorBox, Flex, Stack, Icon, Input, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type ColorEntry = {
  index: Number;
  value: string;
}

type SpriteData = {
  icon_states: string[];
  finished: string;
  steps: SpriteEntry[];
}

type SpriteEntry = {
  layer: string;
  result: string;
}

type GreyscaleMenuData = {
  greyscale_config: string;
  colors: ColorEntry[];
  sprites: SpriteData;
  generate_full_preview: boolean;
  unlocked: boolean;
  sprites_dir: string;
  icon_state: string;
  refreshing: boolean;
}

enum Direction {
  North = "north",
  NorthEast = "northeast",
  East = "east",
  SouthEast = "southeast",
  South = "south",
  SouthWest = "southwest",
  West = "west",
  NorthWest = "northwest"
}

const DirectionAbbreviation : Record<Direction, string> = {
  [Direction.North]: "N",
  [Direction.NorthEast]: "NE",
  [Direction.East]: "E",
  [Direction.SouthEast]: "SE",
  [Direction.South]: "S",
  [Direction.SouthWest]: "SW",
  [Direction.West]: "W",
  [Direction.NorthWest]: "NW",
};

const ConfigDisplay = (props, context) => {
  const { act, data } = useBackend<GreyscaleMenuData>(context);
  return (
    <Section title="Designs">
      <LabeledList>
        <LabeledList.Item label="Design Type">
          <Button
            icon="cogs"
            onClick={() => act("select_config")}
          />
          <Input
            value={data.greyscale_config}
            onChange={(_, value) => act("load_config_from_string", { config_string: value })}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ColorDisplay = (props, context) => {
  const { act, data } = useBackend<GreyscaleMenuData>(context);
  const colors = (data.colors || []);
  return (
    <Section title="Colors">
      <LabeledList>
        <LabeledList.Item
          label="Full Color String">
          <Input
            value={colors.map(item => item.value).join('')}
            onChange={(_, value) => act("recolor_from_string", { color_string: value })}
          />
        </LabeledList.Item>
        {colors.map(item => (
          <LabeledList.Item
            key={`colorgroup${item.index}${item.value}`}
            label={`Color Group ${item.index}`}
            color={item.value}
          >
            <ColorBox
              color={item.value}
            />
            {" "}
            <Button
              icon="palette"
              onClick={() => act("pick_color", { color_index: item.index })}
            />
            <Input
              value={item.value}
              onChange={(_, value) => act("recolor", { color_index: item.index, new_color: value })}
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const PreviewCompassSelect = (props, context) => {
  const { act, data } = useBackend<GreyscaleMenuData>(context);
  return (
    <Box>
      <Stack vertical>
        <Flex>
          <SingleDirection dir={Direction.NorthWest} />
          <SingleDirection dir={Direction.North} />
          <SingleDirection dir={Direction.NorthEast} />
        </Flex>
        <Flex>
          <SingleDirection dir={Direction.West} />
          <Flex.Item grow={1} basis={0}>
            <Button lineHeight={3} m={-0.2} fluid>
              <Icon name="arrows-alt" size={1.5} m="20%" />
            </Button>
          </Flex.Item>
          <SingleDirection dir={Direction.East} />
        </Flex>
        <Flex>
          <SingleDirection dir={Direction.SouthWest} />
          <SingleDirection dir={Direction.South} />
          <SingleDirection dir={Direction.SouthEast} />
        </Flex>
      </Stack>
    </Box>
  );
};

const SingleDirection = (props, context) => {
  const { dir } = props;
  const { data, act } = useBackend<GreyscaleMenuData>(context);
  return (
    <Flex.Item grow={1} basis={0}>
      <Button
        content={DirectionAbbreviation[dir]}
        disabled={`${dir}` === data.sprites_dir ? true : false}
        textAlign="center"
        onClick={() => act("change_dir", { new_sprite_dir: dir })}
        lineHeight={3}
        m={-0.2}
        fluid
      />
    </Flex.Item>
  );
};

const IconStatesDisplay = (props, context) => {
  const { data, act } = useBackend<GreyscaleMenuData>(context);
  return (
    <Section title="Icon States">
      <Flex>
        {
          data.sprites.icon_states.map(item => (
            <Flex.Item key={item}>
              <Button
                mx={0.5}
                content={item ? item : "Blank State"}
                disabled={item === data.icon_state}
                onClick={() => act("select_icon_state", { new_icon_state: item })}
              />
            </Flex.Item>
          ))
        }
      </Flex>
    </Section>
  );
};

const PreviewDisplay = (props, context) => {
  const { data } = useBackend<GreyscaleMenuData>(context);
  return (
    <Section title={`Preview (${data.sprites_dir})`}>
      <Table>
        <Table.Row>
          <Table.Cell width="50%">
            <PreviewCompassSelect />
          </Table.Cell>
          {
            data.sprites?.finished
              ? (
                <Table.Cell>
                  <Box as="img" src={data.sprites.finished} m={0} width="75%" mx="10%" />
                </Table.Cell>
              )
              : (
                <Table.Cell>
                  <Box grow>
                    <Icon name="image" ml="25%" size={5} />
                  </Box>
                </Table.Cell>
              )
          }
        </Table.Row>
      </Table>
      {
        !data.refreshing
          && (
            <Table>
              {
                !!data.generate_full_preview && data.sprites.steps !== null
                  && (
                    <Table.Row header>
                      <Table.Cell textAlign="center">Step Layer</Table.Cell>
                      <Table.Cell textAlign="center">Step Result</Table.Cell>
                    </Table.Row>
                  )
              }
              {
                !!data.generate_full_preview && data.sprites.steps !== null
                  && data.sprites.steps.map(item => (
                    <Table.Row key={`${item.result}|${item.layer}`}>
                      <Table.Cell width="50%"><SingleSprite source={item.result} /></Table.Cell>
                      <Table.Cell width="50%"><SingleSprite source={item.layer} /></Table.Cell>
                    </Table.Row>
                  ))
              }
            </Table>
          )
      }
    </Section>
  );
};

const SingleSprite = (props) => {
  const {
    source,
  } = props;
  return (
    <Box
      as="img"
      src={source}
      width="100%"
    />
  );
};

const LoadingAnimation = () => {
  return (
    <Box height={0} mt="-100%">
      <Icon name="cog" height={22.7} opacity={0.5} size={25} spin />
    </Box>
  );
};

export const GreyscaleModifyMenu = (props, context) => {
  const { act, data } = useBackend<GreyscaleMenuData>(context);
  return (
    <Window
      title="Color Configuration"
      width={325}
      height={800}>
      <Window.Content scrollable>
        <ConfigDisplay />
        <ColorDisplay />
        <IconStatesDisplay />
        {
          !!data.unlocked
            && <Button content="Refresh Icon File" onClick={() => act("refresh_file")} />
        }
        <Button
          content="Apply"
          onClick={() => act("apply")}
          mx={1}
        />
        <Button.Checkbox
          content="Full Preview"
          disabled={!data.generate_full_preview && !data.unlocked}
          checked={data.generate_full_preview}
          onClick={() => act("toggle_full_preview")}
        />
        <PreviewDisplay />
        {
          !!data.refreshing && <LoadingAnimation />
        }
      </Window.Content>
    </Window>
  );
};

import { useBackend } from '../backend';
import { Box, Button, ColorBox, Flex, Icon, Input, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type ColorEntry = {
  index: Number;
  value: string;
}

type SpriteData = {
  finished: SpriteEntry
  steps: Array<SpriteEntry>
}

type SpriteEntry = {
  layer: string
  result: string
}

type GreyscaleMenuData = {
  greyscale_config: string;
  colors: Array<ColorEntry>;
  sprites: SpriteData;
  sprites_dir: string;
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
    <Section title="Config">
      <LabeledList>
        <LabeledList.Item label="Config Type">
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
    <Section>
      <Flex mx="25%" fluid>
        <SingleDirection dir={Direction.NorthWest} />
        <SingleDirection dir={Direction.North} />
        <SingleDirection dir={Direction.NorthEast} />
      </Flex>
      <Flex mx="25%">
        <SingleDirection dir={Direction.West} />
        <Flex.Item grow={1} basis={0}>
          <Button lineHeight={3} m={-0.2} fluid>
            <Icon name="arrows-alt" size={1.5} m="20%" />
          </Button>
        </Flex.Item>
        <SingleDirection dir={Direction.East} />
      </Flex>
      <Flex mx="25%">
        <SingleDirection dir={Direction.SouthWest} />
        <SingleDirection dir={Direction.South} />
        <SingleDirection dir={Direction.SouthEast} />
      </Flex>
    </Section>
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

const PreviewDisplay = (props, context) => {
  const { data } = useBackend<GreyscaleMenuData>(context);
  return (
    <Section title={`Preview (${data.sprites_dir})`}>
      <PreviewCompassSelect />
      <Table>
        <Table.Row header>
          <Table.Cell textAlign="center">Step Layer</Table.Cell>
          <Table.Cell textAlign="center">Step Result</Table.Cell>
        </Table.Row>
        {data.sprites.steps.map(item => (
          <Table.Row key={`${item.result}|${item.layer}`}>
            <Table.Cell width="50%"><SingleSprite source={item.result} /></Table.Cell>
            <Table.Cell width="50%"><SingleSprite source={item.layer} /></Table.Cell>
          </Table.Row>
        ))}
      </Table>
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

export const GreyscaleModifyMenu = (props, context) => {
  const { act, data } = useBackend<GreyscaleMenuData>(context);
  return (
    <Window
      title="Greyscale Modification"
      width={325}
      height={800}>
      <Window.Content scrollable>
        <ConfigDisplay />
        <ColorDisplay />
        <Button
          content="Refresh Icon File"
          onClick={() => act("refresh_file")}
        />
        {" "}
        <Button
          content="Apply"
          onClick={() => act("apply")}
        />
        <PreviewDisplay />
      </Window.Content>
    </Window>
  );
};

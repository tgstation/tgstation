import { useBackend } from '../backend';
import { Box, Button, ColorBox, Flex, Icon, Input, LabeledList, Section, Stack, Table } from '../components';
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

enum Directions {
  North = "north",
  NorthEast = "northeast",
  East = "east",
  SouthEast = "southeast",
  South = "south",
  SouthWest = "southwest",
  West = "west",
  NorthWest = "northwest"
}

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
  )
}

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
      <Table width="51%" mx="25%">
        <Table.Row key="top" height="33%">
          <Table.Cell width="33%">
            <Button
              content="NW"
              textAlign="center"
              onClick={() => act("change_dir", { new_sprite_dir: Directions.NorthWest })}
              fluid
              m={1}
            />
          </Table.Cell>
          <Table.Cell width="33%">
            <Button
              content="N"
              textAlign="center"
              onClick={() => act("change_dir", { new_sprite_dir: Directions.North })}
              fluid
              m={1}
            />
          </Table.Cell>
          <Table.Cell width="33%">
            <Button
              content="NE"
              textAlign="center"
              onClick={() => act("change_dir", { new_sprite_dir: Directions.NorthEast })}
              fluid
              m={1}
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row key="middle" height="33%">
          <Table.Cell width="33%">
            <Button
              content="W"
              textAlign="center"
              onClick={() => act("change_dir", { new_sprite_dir: Directions.West })}
              fluid
              m={1}
            />
          </Table.Cell>
          <Table.Cell width="33%"><Box textAlign="center" ><Icon name="arrows-alt" size={1.5} /></Box></Table.Cell>
          <Table.Cell width="33%">
            <Button
              content="E"
              textAlign="center"
              onClick={() => act("change_dir", { new_sprite_dir: Directions.East })}
              fluid
              m={1}
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row key="bottom" height="33%">
          <Table.Cell width="33%">
            <Button
              content="SW"
              textAlign="center"
              onClick={() => act("change_dir", { new_sprite_dir: Directions.SouthWest })}
              fluid
              m={1}
            />
          </Table.Cell>
          <Table.Cell width="33%">
            <Button
              content="S"
              textAlign="center"
              onClick={() => act("change_dir", { new_sprite_dir: Directions.South })}
              fluid
              m={1}
            />
          </Table.Cell>
          <Table.Cell width="33%">
            <Button
              content="SE"
              textAlign="center"
              onClick={() => act("change_dir", { new_sprite_dir: Directions.SouthEast })}
              fluid
              m={1}
            />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
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

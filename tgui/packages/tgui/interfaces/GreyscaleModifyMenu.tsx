import {
  Box,
  Button,
  ColorBox,
  Divider,
  Flex,
  Icon,
  Image,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ColorEntry = {
  index: Number;
  value: string;
};

type SpriteData = {
  icon_states: string[];
  finished: string;
  steps: SpriteEntry[];
  time_spent: Number;
};

type SpriteEntry = {
  layer: string;
  result: string;
  config_name: string;
};

type GreyscaleMenuData = {
  greyscale_config: string;
  colors: ColorEntry[];
  sprites: SpriteData;
  generate_full_preview: boolean;
  unlocked: boolean;
  monitoring_files: boolean;
  sprites_dir: string;
  icon_state: string;
  refreshing: boolean;
};

enum Direction {
  North = 'north',
  NorthEast = 'northeast',
  East = 'east',
  SouthEast = 'southeast',
  South = 'south',
  SouthWest = 'southwest',
  West = 'west',
  NorthWest = 'northwest',
}

const DirectionAbbreviation: Record<Direction, string> = {
  [Direction.North]: 'N',
  [Direction.NorthEast]: 'NE',
  [Direction.East]: 'E',
  [Direction.SouthEast]: 'SE',
  [Direction.South]: 'S',
  [Direction.SouthWest]: 'SW',
  [Direction.West]: 'W',
  [Direction.NorthWest]: 'NW',
};

const ConfigDisplay = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  return (
    <Section title="Designs">
      <LabeledList>
        <LabeledList.Item label="Design Type">
          <Button icon="cogs" onClick={() => act('select_config')} />
          <Input
            value={data.greyscale_config}
            expensive
            onChange={(value) =>
              act('load_config_from_string', { config_string: value })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ColorDisplay = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  const colors = data.colors || [];
  return (
    <Section title="Colors">
      <LabeledList>
        <LabeledList.Item label="Full Color String">
          <Button
            icon="dice"
            onClick={() => act('random_all_colors')}
            tooltip="Randomizes all color groups."
          />
          <Input
            value={colors.map((item) => item.value).join('')}
            expensive
            onChange={(value) =>
              act('recolor_from_string', { color_string: value })
            }
          />
        </LabeledList.Item>
        {colors.map((item) => (
          <LabeledList.Item
            key={`colorgroup${item.index}${item.value}`}
            label={`Color Group ${item.index}`}
            color={item.value}
          >
            <ColorBox color={item.value} />{' '}
            <Button
              icon="palette"
              onClick={() => act('pick_color', { color_index: item.index })}
              tooltip="Brings up a color pick window to replace this color group."
            />
            <Button
              icon="dice"
              onClick={() => act('random_color', { color_index: item.index })}
              tooltip="Randomizes the color for this color group."
            />
            <Input
              value={item.value}
              width={7}
              expensive
              onChange={(value) =>
                act('recolor', { color_index: item.index, new_color: value })
              }
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const PreviewCompassSelect = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
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

const SingleDirection = (props) => {
  const { dir } = props;
  const { data, act } = useBackend<GreyscaleMenuData>();
  return (
    <Flex.Item grow={1} basis={0}>
      <Button
        content={DirectionAbbreviation[dir]}
        tooltip={`Sets the direction of the preview sprite to ${dir}`}
        disabled={`${dir}` === data.sprites_dir ? true : false}
        textAlign="center"
        onClick={() => act('change_dir', { new_sprite_dir: dir })}
        lineHeight={3}
        m={-0.2}
        fluid
      />
    </Flex.Item>
  );
};

const IconStatesDisplay = (props) => {
  const { data, act } = useBackend<GreyscaleMenuData>();
  return (
    <Section title="Icon States">
      <Flex>
        {data.sprites.icon_states.map((item) => (
          <Flex.Item key={item}>
            <Button
              mx={0.5}
              content={item ? item : 'Blank State'}
              disabled={item === data.icon_state}
              onClick={() => act('select_icon_state', { new_icon_state: item })}
            />
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const PreviewDisplay = (props) => {
  const { data } = useBackend<GreyscaleMenuData>();
  return (
    <Section title={`Preview (${data.sprites_dir})`}>
      <Table>
        <Table.Row>
          <Table.Cell width="50%">
            <PreviewCompassSelect />
          </Table.Cell>
          {data.sprites?.finished ? (
            <Table.Cell>
              <Image m={0} mx="10%" src={data.sprites.finished} width="75%" />
            </Table.Cell>
          ) : (
            <Table.Cell>
              <Box>
                <Icon name="image" ml="25%" size={5} />
              </Box>
            </Table.Cell>
          )}
        </Table.Row>
      </Table>
      {!!data.unlocked && `Time Spent: ${data.sprites.time_spent}ms`}
      <Divider />
      {!data.refreshing && (
        <Table>
          {!!data.generate_full_preview && data.sprites.steps !== null && (
            <Table.Row header>
              <Table.Cell width="50%" textAlign="center">
                Layer Source
              </Table.Cell>
              <Table.Cell width="25%" textAlign="center">
                Step Layer
              </Table.Cell>
              <Table.Cell width="25%" textAlign="center">
                Step Result
              </Table.Cell>
            </Table.Row>
          )}
          {!!data.generate_full_preview &&
            data.sprites.steps !== null &&
            data.sprites.steps.map((item) => (
              <Table.Row key={`${item.result}|${item.layer}`}>
                <Table.Cell verticalAlign="middle">
                  {item.config_name}
                </Table.Cell>
                <Table.Cell>
                  <SingleSprite source={item.layer} />
                </Table.Cell>
                <Table.Cell>
                  <SingleSprite source={item.result} />
                </Table.Cell>
              </Table.Row>
            ))}
        </Table>
      )}
    </Section>
  );
};

const SingleSprite = (props) => {
  const { source } = props;
  return <Image src={source} />;
};

const LoadingAnimation = () => {
  return (
    <Box height={0} mt="-100%">
      <Icon name="cog" height={22.7} opacity={0.5} size={25} spin />
    </Box>
  );
};

export const GreyscaleModifyMenu = (props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  return (
    <Window title="Color Configuration" width={325} height={800}>
      <Window.Content scrollable>
        <ConfigDisplay />
        <ColorDisplay />
        <IconStatesDisplay />
        <Flex direction="column">
          {!!data.unlocked && (
            <Flex.Item justify="flex-start">
              <Button
                content={
                  <Icon name="file-image-o" spin={data.monitoring_files} />
                }
                tooltip="Continuously checks files for changes and reloads when necessary. WARNING: Very expensive"
                selected={data.monitoring_files}
                onClick={() => act('toggle_mass_refresh')}
                width={1.9}
                mr={-0.2}
              />
              <Button
                content="Refresh Icon File"
                tooltip="Loads the json configuration and icon file fresh from disk. This is useful to avoid restarting the server to see changes. WARNING: Expensive"
                onClick={() => act('refresh_file')}
              />
              <Button
                content="Save Icon File"
                tooltip="Saves the icon to a temp file in tmp/. This is useful if you want to use a generated icon elsewhere or just view a more accurate representation"
                onClick={() => act('save_dmi')}
              />
            </Flex.Item>
          )}
          <Flex.Item>
            <Button
              content="Apply"
              tooltip="Applies changes made to the object this menu was created from."
              color="red"
              onClick={() => act('apply')}
            />
            <Button.Checkbox
              content="Full Preview"
              tooltip="Generates and displays the full sprite generation process instead of just the final output."
              disabled={!data.generate_full_preview && !data.unlocked}
              checked={data.generate_full_preview}
              onClick={() => act('toggle_full_preview')}
            />
          </Flex.Item>
        </Flex>
        <PreviewDisplay />
        {!!data.refreshing && <LoadingAnimation />}
      </Window.Content>
    </Window>
  );
};

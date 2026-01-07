import { Button, ColorBox, Flex, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DecalInfo = {
  name: string;
  icon_state: string;
  directional: BooleanLike;
};

type ColorInfo = {
  name: string;
  color: string;
};

type DirInfo = {
  name: string;
  dir: number;
};

type Category = {
  category: string;
  decal_list: DecalInfo[];
  color_list: ColorInfo[];
  dir_list: DirInfo[];
};

type DecalPainterData = {
  icon_prefix: string;
  categories: Category[];
  // decal painter state
  current_decal: string;
  current_color: string;
  current_dir: number;
  current_custom_color: string;
  active_category: string;
};

const filterBoxColor = (color: string) => {
  if (!color.startsWith('#')) {
    return color;
  }

  // cut alpha
  return color.substring(0, 7);
};

export const DecalPainter = (props) => {
  const { act, data } = useBackend<DecalPainterData>();

  const {
    categories,
    active_category,
    current_color,
    current_custom_color,
    current_decal,
    current_dir,
  } = data;

  const active_category_info = categories.find(
    (category) => category.category === active_category,
  );
  const decal_list = active_category_info?.decal_list || [];
  const color_list = active_category_info?.color_list || [];
  const dir_list = active_category_info?.dir_list || [];

  const custom_color_selected = !color_list.some(
    (color) => color.color === current_color,
  );

  // Handle custom color icon correctly
  const preview_color = custom_color_selected ? 'custom' : current_color;

  return (
    <Window width={650} height={455}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Category">
              {categories.map((category) => (
                <Button
                  align="center"
                  key={category.category}
                  selected={category === active_category_info}
                  onClick={() =>
                    act('select_category', {
                      category: category.category,
                    })
                  }
                >
                  {category.category}
                </Button>
              ))}
            </Section>
          </Stack.Item>
          {color_list.length > 1 && (
            <Stack.Item>
              <Section title="Color">
                {color_list.map((color) => {
                  if (color.color === 'custom') {
                    return (
                      <Button
                        key={color.name}
                        selected={custom_color_selected}
                        onClick={() => act('pick_custom_color')}
                      >
                        <ColorBox color={current_custom_color} mr={0.5} />
                        Custom
                      </Button>
                    );
                  }
                  return (
                    <Button
                      key={color.name}
                      selected={color.color === current_color}
                      onClick={() =>
                        act('select_color', {
                          color: color.color,
                        })
                      }
                    >
                      <ColorBox color={filterBoxColor(color.color)} mr={0.5} />
                      {color.name}
                    </Button>
                  );
                })}
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section title="Style" fill scrollable>
              <Flex wrap="wrap">
                {decal_list.map((decal) => {
                  const nondirectional = decal.directional === 0;

                  return nondirectional ? (
                    // Tallll button for nondirectional
                    <IconButton
                      key={decal.icon_state}
                      icon_state={decal.icon_state}
                      dir={2}
                      color={preview_color}
                      label={decal.name}
                      selected={decal.icon_state === current_decal}
                    />
                  ) : (
                    // 4 buttons for directional
                    <Flex key={decal.icon_state} direction="column">
                      {dir_list.map((dir) => {
                        const selected =
                          decal.icon_state === current_decal &&
                          dir.dir === current_dir;

                        return (
                          <IconButton
                            key={dir.dir}
                            icon_state={decal.icon_state}
                            dir={dir.dir}
                            color={preview_color}
                            label={`${dir.name} ${decal.name}`}
                            selected={selected}
                          />
                        );
                      })}
                    </Flex>
                  );
                })}
              </Flex>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type IconButtonParams = {
  icon_state: string;
  dir: number;
  color: string;
  label: string;
  selected: boolean;
};

const IconButton = (props: IconButtonParams) => {
  const { act, data } = useBackend<DecalPainterData>();

  const generateIconKey = (decal: string, dir: number, color: string) =>
    `${data.icon_prefix} ${decal}_${dir}_${color.replace('#', '')}`;

  const icon = generateIconKey(props.icon_state, props.dir, props.color);

  return (
    <Button
      tooltip={props.label}
      selected={props.selected}
      verticalAlignContent="middle"
      m={'2px'}
      p={1}
      onClick={() =>
        act('select_decal', {
          decal: props.icon_state,
          dir: props.dir,
        })
      }
    >
      <div className={icon} style={{ display: 'block' }} />
    </Button>
  );
};

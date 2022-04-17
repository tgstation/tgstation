import { useBackend } from '../backend';
import { Button, ColorBox, Flex, Section } from '../components';
import { Window } from '../layouts';

type Decal = {
  name: string,
  decal: string
}

type Color = {
  name: string,
  color: string
}

type Dir = {
  name: string,
  dir: number
}

type DecalPainterData = {
  icon_prefix: string,
  decal_list: Decal[],
  color_list: Color[],
  dir_list: Dir[],
  nondirectional_decals: string[],
  current_decal: string,
  current_color: string,
  current_dir: number
}

export const DecalPainter = (props, context) => {
  const { act, data } = useBackend<DecalPainterData>(context);

  return (
    <Window
      width={550}
      height={400}>
      <Window.Content>
        <Section title="Decal Color">
          {data.color_list.map(color => {
            return (
              <Button
                key={color.color}
                selected={color.color === data.current_color}
                onClick={() => act('select color', {
                  color: color.color,
                })}
              >
                <ColorBox color={color.color} mr={0.5} />
                { color.name }
              </Button>
            );
          })}
        </Section>
        <Section title="Decal Style">
          <Flex
            direction="row" wrap="nowrap"
            align="fill" justify="fill"
          >
            {data.decal_list.map(decal => {
              const nondirectional = data.nondirectional_decals
                .includes(decal.decal);

              return nondirectional ? (
                // Tallll button for nondirectional
                <IconButton
                  decal={decal.decal} dir={2}
                  label={decal.name}
                  selected={decal.decal === data.current_decal}
                />
              ) : (
                // 4 buttons for directional
                <Flex
                  key="decal.decal"
                  direction="column" wrap="nowrap"
                  align="fill" justify="fill"
                >
                  {data.dir_list.map(dir => {
                    const selected = decal.decal === data.current_decal
                      && dir.dir === data.current_dir;

                    return (
                      <IconButton
                        key={dir.dir}
                        decal={decal.decal} dir={dir.dir}
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
      </Window.Content>
    </Window>
  );
};

type IconButtonParams = {
  decal: string;
  dir: number;
  label: string;
  selected: boolean;
};

const IconButton = (props: IconButtonParams, context) => {
  const { act, data } = useBackend<DecalPainterData>(context);

  const generateIconKey = (decal: string, dir: number) =>
    `${data.icon_prefix} ${decal}_${dir}_${data.current_color.replace("#", "")}`;

  const icon = generateIconKey(props.decal, props.dir);

  return (
    <Button
      key={props.decal}
      tooltip={props.label}
      selected={props.selected}
      verticalAlignContent="middle"
      className="DecalPainter__CellButton"
      onClick={() => act('select decal', {
        decal: props.decal,
        dir: props.dir,
      })}
    >
      <span className={`${icon} DecalPainter__CellIcon`} />
    </Button>
  );
};

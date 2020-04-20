import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const DecalPainter = (props, context) => {
  const { act, data } = useBackend(context);
  const decal_list = data.decal_list || [];
  const color_list = data.color_list || [];
  const dir_list = data.dir_list || [];
  return (
    <Window>
      <Window.Content>
        <Section title="Decal Type">
          {decal_list.map(decal => (
            <Button
              key={decal.decal}
              content={decal.name}
              selected={decal.decal === data.decal_style}
              onClick={() => act('select decal', {
                decals: decal.decal,
              })} />
          ))}
        </Section>
        <Section title="Decal Color">
          {color_list.map(color => {
            return (
              <Button
                key={color.colors}
                content={color.colors === "red"
                  ? "Red"
                  : color.colors === "white"
                    ? "White"
                    : "Yellow"}
                selected={color.colors === data.decal_color}
                onClick={() => act('select color', {
                  colors: color.colors,
                })} />
            );
          })}
        </Section>
        <Section title="Decal Direction">
          {dir_list.map(dir => {
            return (
              <Button
                key={dir.dirs}
                content={dir.dirs === 1
                  ? "North"
                  : dir.dirs === 2
                    ? "South"
                    : dir.dirs === 4
                      ? "East"
                      : "West"}
                selected={dir.dirs === data.decal_direction}
                onClick={() => act('selected direction', {
                  dirs: dir.dirs,
                })} />
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};

import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section, Tabs } from '../components';

export const DecalPainter = props => {
  const { act, data } = useBackend(props);
  const decal_list = data.decal_list || [];
  const color_list = data.color_list || [];
  const dir_list = data.dir_list || [];
  return (
    <Fragment>
      <Section title="Decal Type">
        {decal_list.map(decal => { 
          return (
            <Button
              key={decal.decal}
              content={decal.name}
              selected={decal.decal === data.decal_style}
              onClick={() => act('select decal', {
                decals: decal.decal, 
              })} />
          );
        })} 
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
    </Fragment>
  );
};

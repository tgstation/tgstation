import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section, Tabs } from '../components';

export const DecalPainter = props => {
  const { act, data } = useBackend(props);
  const decal_builder = data.decal_builder || [];
  const color_builder = data.color_builder || [];
  const direction_builder = data.direction_builder || [];
  return (
    <Fragment>
      <Section title="Decal Type">
        {decal_builder.map(decal => {
          return (
            <Button
              key={decal.decal_type}
              content={decal.decal_type}
              selected={decal.decal_type === data.decal_style}
              onClick={() => act('select decal', {
                decal_type: decal.decal_type, 
              })} />
          );
        })} 
      </Section>
      <Section title="Decal Color">
        {color_builder.map(color => {
          const col = color.color_type;
          return (
            <Button
              key={color.color_type}
              content={col==="_red"?"Red":col==="_white"?"White":"Yellow"}
              selected={col===data.decal_color}
              onClick={() => act('select color', {
                color_type: col, 
              })} />
          );
        })} 
      </Section>
      <Section title="Decal Direction">
        {direction_builder.map(dir => {
          const dt = dir.dir_type;
          return (
            <Button
              key={dt}
              content={dt===1?"North":dt===2?"South":dt===4?"East":"West"}
              selected={dt===data.decal_direction}
              onClick={() => act('selected direction', {
                dir_type: dt, 
              })} />
          );
        })} 
      </Section>
    </Fragment>
  );
};

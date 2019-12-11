import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section, Tabs } from '../components';

export const DecalPainter = props => {
  const { act, data } = useBackend(props);
  return (
    <Fragment>
      <Section title="Decal Style">
        <Button
          color={data.decal_style === "warningline" ? "good" : "default"}
          onClick={() => act('lines')}
          content="Caution Lines" />
        <Button
          color={data.decal_style === "warninglinecorner" ? "good" : "default"}
          onClick={() => act('lines corner')}
          content="Caution Line Corner" />
        <Button
          color={data.decal_style === "caution" ? "good" : "default"}
          onClick={() => act('caution')}
          content="Caution Letters" />
        <Button
          color={data.decal_style === "arrows" ? "good" : "default"}
          onClick={() => act('arrow')}
          content="Arrows" />
        <Button
          color={data.decal_style === "stand_clear" ? "good" : "default"}
          onClick={() => act('stand clear')}
          content="Stand Clear" />
        <Button
          color={data.decal_style === "box" ? "good" : "default"}
          onClick={() => act('box')}
          content="Box (Full)" />
        <Button
          color={data.decal_style === "box_corners" ? "good" : "default"}
          onClick={() => act('box corners')}
          content="Box (Corner)" />
        <Button
          color={data.decal_style === "delivery" ? "good" : "default"}
          onClick={() => act('delivery')}
          content="Delivery Zone" />
        <Button
          color={data.decal_style === "warn_full" ? "good" : "default"}
          onClick={() => act('full stripes')}
          content="Striped Box" />
      </Section>
      <Section title="Decal Direction">
        <Button
          icon="angle-double-up"
          width={19}
          color={data.decal_direction === 1 ? "good" : "default"}
          onClick={() => act('north')}
          content="North" />
        <Button
          icon="angle-double-down"
          width={19}
          color={data.decal_direction === 2 ? "good" : "default"}
          onClick={() => act('south')}
          content="South" />
        <Button
          icon="angle-double-right"
          width={19}
          color={data.decal_direction === 4 ? "good" : "default"}
          onClick={() => act('east')}
          content="East" />
        <Button
          icon="angle-double-left"
          width={19}
          color={data.decal_direction === 8 ? "good" : "default"}
          onClick={() => act('west')}
          content="West" />
      </Section>
      <Section title="Decal Color">
        <Button
          icon="circle"
          width={26}
          color={data.decal_color === "" ? "yellow" : "default"}
          onClick={() => act('yellow')}
          content="Yellow" />
        <Button
          icon="circle"
          width={26}
          color={data.decal_color === "_red" ? "red" : "default"}
          onClick={() => act('red')}
          content="Red" />
        <Button
          icon="circle"
          width={26}
          color={data.decal_color === "_white" ? "white" : "default"}
          onClick={() => act('white')}
          content="White" />
      </Section>
    </Fragment>
  );
};

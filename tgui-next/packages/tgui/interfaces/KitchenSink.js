import { Component, Fragment } from 'inferno';
import {
  Box, Button, Flex, Input, LabeledList, NumberInput,
  ProgressBar, Section, Tabs, Tooltip,
} from '../components';

const COLORS_ARBITRARY = [
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
];

const COLORS_STATES = [
  'good',
  'average',
  'bad',
  'black',
  'white',
];

const TAB_KEYS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  .map(x => 'tab_' + x);

export const KitchenSink = props => {
  return (
    <Fragment>
      <Flex mb={1}>
        <Flex.Item mr={1} grow={1}>
          <KitchenSinkButtons />
        </Flex.Item>
        <Flex.Item>
          <KitchenSinkBoxes />
        </Flex.Item>
      </Flex>
      <KitchenSinkProgress />
      <KitchenSinkTabs />
      <KitchenSinkTooltips />
      <KitchenSinkInputs />
    </Fragment>
  );
};

const KitchenSinkButtons = props => {
  return (
    <Section
      title="Buttons"
      height="100%">
      <Box mb={1}>
        <Button content="Simple" />
        <Button selected content="Selected" />
        <Button disabled content="Disabled" />
        <Button color="transparent" content="Transparent" />
        <Button icon="cog" content="Icon" />
        <Button icon="power-off" />
        <Button fluid content="Fluid" />
        <Button
          my={1}
          lineHeight={4}
          minWidth={30}
          textAlign="center"
          content="With Box props" />
      </Box>
      <Box mb={1}>
        {COLORS_STATES.map(color => (
          <Button
            key={color}
            color={color}
            content={color} />
        ))}
        <br />
        {COLORS_ARBITRARY.map(color => (
          <Button
            key={color}
            color={color}
            content={color} />
        ))}
        <br />
        {COLORS_ARBITRARY.map(color => (
          <Box inline
            mx="7px"
            key={color}
            color={color}
            content={color} />
        ))}
      </Box>
    </Section>
  );
};

const KitchenSinkBoxes = props => {
  return (
    <Section
      title="Box"
      width={25}
      height="100%">
      <Box bold content="bold" />
      <Box italic content="italic" />
      <Box opacity={0.5} content="opacity 0.5" />
      <Box opacity={0.25} content="opacity 0.25" />
      <Box m={2} content="m: 2" />
      <Box textAlign="left" content="left" />
      <Box textAlign="center" content="center" />
      <Box textAlign="right" content="right" />
    </Section>
  );
};

class KitchenSinkProgress extends Component {
  constructor() {
    super();
    this.state = {
      progress: 0.5,
    };
  }

  render() {
    const { progress } = this.state;
    return (
      <Section title="Progress">
        <ProgressBar
          ranges={{
            good: [0.5, Infinity],
            bad: [-Infinity, 0.1],
            average: [0, 0.5],
          }}
          minValue={-1}
          maxValue={1}
          value={progress}
          content={`value: ${Number(progress).toFixed(1)}`} />
        <Button
          content="-0.1"
          onClick={() => this.setState(prevState => ({
            progress: prevState.progress - 0.1,
          }))} />
        <Button
          content="+0.1"
          onClick={() => this.setState(prevState => ({
            progress: prevState.progress + 0.1,
          }))} />
      </Section>
    );
  }
}

class KitchenSinkTabs extends Component {
  constructor() {
    super();
    this.state = {
      vertical: true,
    };
  }

  render() {
    const { vertical } = this.state;
    return (
      <Section title="Tabs">
        {'Vertical: '}
        <Button inline
          content={String(vertical)}
          onClick={() => this.setState(prevState => ({
            vertical: !prevState.vertical,
          }))} />
        <Box mb={2} />
        <Tabs vertical={vertical}>
          {TAB_KEYS.map(key => (
            <Tabs.Tab
              key={key}
              label={'Label ' + key}>
              {() => (
                <Box>
                  {'Active tab: '}
                  <Box inline color="green">{key}</Box>
                  <BoxOfSampleText mt={2} />
                </Box>
              )}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Section>
    );
  }
}

const KitchenSinkTooltips = props => {
  return (
    <Section label="Tooltips">
      <Box inline position="relative" mr={1}>
        Box (hover me).
        <Tooltip
          content="Tooltip text."
          position="right" />
      </Box>
      <Button
        tooltip="Tooltip text."
        content="Button" />
    </Section>
  );
};

class KitchenSinkInputs extends Component {
  constructor() {
    super();
    this.state = {
      number: 0,
      text: 'Sample text',
    };
  }

  render() {
    const { number, text } = this.state;
    return (
      <Section title="Inputs">
        <LabeledList>
          <LabeledList.Item label="NumberInput">
            <NumberInput
              animated
              width={10}
              step={1}
              stepPixelSize={5}
              value={number}
              minValue={-100}
              maxValue={100}
              onChange={(e, value) => this.setState({
                number: value,
              })} />
            <NumberInput
              animated
              width={10}
              step={1}
              stepPixelSize={5}
              value={number}
              minValue={-100}
              maxValue={100}
              onDrag={(e, value) => this.setState({
                number: value,
              })} />
          </LabeledList.Item>
          <LabeledList.Item label="Input">
            <Input
              value={text}
              onChange={(e, value) => this.setState({
                text: value,
              })} />
            <Input
              value={text}
              onInput={(e, value) => this.setState({
                text: value,
              })} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  }
}

const BoxOfSampleText = props => {
  return (
    <Box {...props}>
      <Box italic>
        Jackdaws loves my big sphinx of quartz.
      </Box>
      <Box mt={1} bold>
        The wide electrification of the southern
        provinces will give a powerful impetus to the
        growth of soviet agriculture.
      </Box>
    </Box>
  );
};

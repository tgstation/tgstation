import { Component } from 'inferno';
import { useBackend } from '../backend';
import { BlockQuote, Box, Button, ByondUi, Collapsible, Input, LabeledList, NumberInput, ProgressBar, Section, Tabs, Tooltip } from '../components';

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

const PAGES = [
  {
    title: 'Button',
    component: () => KitchenSinkButton,
  },
  {
    title: 'Box',
    component: () => KitchenSinkBox,
  },
  {
    title: 'ProgressBar',
    component: () => KitchenSinkProgressBar,
  },
  {
    title: 'Tabs',
    component: () => KitchenSinkTabs,
  },
  {
    title: 'Tooltip',
    component: () => KitchenSinkTooltip,
  },
  {
    title: 'Input',
    component: () => KitchenSinkInput,
  },
  {
    title: 'Collapsible',
    component: () => KitchenSinkCollapsible,
  },
  {
    title: 'BlockQuote',
    component: () => KitchenSinkBlockQuote,
  },
  {
    title: 'ByondUi',
    component: () => KitchenSinkByondUi,
  },
];

export const KitchenSink = props => {
  return (
    <Section>
      <Tabs vertical>
        {PAGES.map(page => (
          <Tabs.Tab
            key={page.title}
            label={page.title}>
            {() => {
              const Component = page.component();
              return (
                <Component {...props} />
              );
            }}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

const KitchenSinkButton = props => {
  return (
    <Box>
      <Box mb={1}>
        <Button content="Simple" />
        <Button selected content="Selected" />
        <Button altSelected content="Alt Selected" />
        <Button disabled content="Disabled" />
        <Button color="transparent" content="Transparent" />
        <Button icon="cog" content="Icon" />
        <Button icon="power-off" />
        <Button fluid content="Fluid" />
        <Button
          my={1}
          lineHeight={2}
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
    </Box>
  );
};

const KitchenSinkBox = props => {
  return (
    <Box>
      <Box bold content="bold" />
      <Box italic content="italic" />
      <Box opacity={0.5} content="opacity 0.5" />
      <Box opacity={0.25} content="opacity 0.25" />
      <Box m={2} content="m: 2" />
      <Box textAlign="left" content="left" />
      <Box textAlign="center" content="center" />
      <Box textAlign="right" content="right" />
    </Box>
  );
};

class KitchenSinkProgressBar extends Component {
  constructor() {
    super();
    this.state = {
      progress: 0.5,
    };
  }

  render() {
    const { progress } = this.state;
    return (
      <Box>
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
        <Box mt={1}>
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
        </Box>
      </Box>
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
    const TAB_KEYS = [1, 2, 3, 4, 5].map(x => 'tab_' + x);
    return (
      <Box>
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
      </Box>
    );
  }
}

const KitchenSinkTooltip = props => {
  const positions = [
    'top',
    'left',
    'right',
    'bottom',
    'bottom-left',
    'bottom-right',
  ];
  return (
    <Box>
      <Box>
        <Box inline position="relative" mr={1}>
          Box (hover me).
          <Tooltip content="Tooltip text." />
        </Box>
        <Button
          tooltip="Tooltip text."
          content="Button" />
      </Box>
      <Box mt={1}>
        {positions.map(position => (
          <Button
            key={position}
            color="transparent"
            tooltip="Tooltip text."
            tooltipPosition={position}
            content={position} />
        ))}
      </Box>
    </Box>
  );
};

class KitchenSinkInput extends Component {
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
      <Box>
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
      </Box>
    );
  }
}

const KitchenSinkCollapsible = props => {
  return (
    <Collapsible
      title="Collapsible Demo"
      buttons={(
        <Button icon="cog" />
      )}>
      <Section>
        <BoxOfSampleText />
      </Section>
    </Collapsible>
  );
};

const BoxOfSampleText = props => {
  return (
    <Box {...props}>
      <Box italic>
        Jackdaws love my big sphinx of quartz.
      </Box>
      <Box mt={1} bold>
        The wide electrification of the southern
        provinces will give a powerful impetus to the
        growth of soviet agriculture.
      </Box>
    </Box>
  );
};

const KitchenSinkBlockQuote = props => {
  return (
    <BlockQuote>
      <BoxOfSampleText />
    </BlockQuote>
  );
};

const KitchenSinkByondUi = props => {
  const { config } = useBackend(props);
  return (
    <Box>
      <Section
        title="Button"
        level={2}>
        <ByondUi
          params={{
            type: 'button',
            parent: config.window,
            text: 'Button',
          }} />
      </Section>
    </Box>
  );
};

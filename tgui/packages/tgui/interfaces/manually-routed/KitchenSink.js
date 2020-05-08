import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../../backend';
import { BlockQuote, Box, Button, ByondUi, Collapsible, Flex, Icon, Input, Knob, LabeledList, NumberInput, ProgressBar, Section, Slider, Tabs, Tooltip } from '../../components';
import { DraggableControl } from '../../components/DraggableControl';
import { Window } from '../../layouts';

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
    title: 'Input / Control',
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
  {
    title: 'Themes',
    component: () => KitchenSinkThemes,
  },
];

export const KitchenSink = (props, context) => {
  const [theme] = useLocalState(context, 'kitchenSinkTheme');
  const [pageIndex, setPageIndex] = useLocalState(context, 'pageIndex', 0);
  const PageComponent = PAGES[pageIndex].component();
  return (
    <Window
      theme={theme}
      resizable>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item>
              <Tabs vertical>
                {PAGES.map((page, i) => (
                  <Tabs.Tab
                    key={i}
                    selected={i === pageIndex}
                    onClick={() => setPageIndex(i)}>
                    {page.title}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Flex.Item>
            <Flex.Item grow={1} basis={0}>
              <PageComponent />
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
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
          minWidth={15}
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
            color={color}>
            {color}
          </Box>
        ))}
      </Box>
    </Box>
  );
};

const KitchenSinkBox = props => {
  return (
    <Box>
      <Box bold>
        bold
      </Box>
      <Box italic>
        italic
      </Box>
      <Box opacity={0.5}>
        opacity 0.5
      </Box>
      <Box opacity={0.25}>
        opacity 0.25
      </Box>
      <Box m={2}>
        m: 2
      </Box>
      <Box textAlign="left">
        left
      </Box>
      <Box textAlign="center">
        center
      </Box>
      <Box textAlign="right">
        right
      </Box>
    </Box>
  );
};

const KitchenSinkProgressBar = (props, context) => {
  const [
    progress,
    setProgress,
  ] = useLocalState(context, 'progress', 0.5);

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
        value={progress}>
        Value: {Number(progress).toFixed(1)}
      </ProgressBar>
      <Box mt={1}>
        <Button
          content="-0.1"
          onClick={() => setProgress(progress - 0.1)} />
        <Button
          content="+0.1"
          onClick={() => setProgress(progress + 0.1)} />
      </Box>
    </Box>
  );
};

const KitchenSinkTabs = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [vertical, setVertical] = useLocalState(context, 'tabVert');
  const [altSelection, setAltSelection] = useLocalState(context, 'tabAlt');
  const TAB_RANGE = [1, 2, 3, 4, 5];
  return (
    <Box>
      <Box mb={2}>
        <Button.Checkbox
          inline
          content="vertical"
          checked={vertical}
          onClick={() => setVertical(!vertical)} />
        <Button.Checkbox
          inline
          content="altSelection"
          checked={altSelection}
          onClick={() => setAltSelection(!altSelection)} />
      </Box>
      <Tabs vertical={vertical}>
        {TAB_RANGE.map((number, i) => (
          <Tabs.Tab
            key={i}
            altSelection={altSelection}
            selected={i === tabIndex}
            onClick={() => setTabIndex(i)}>
            Tab #{number}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Box>
  );
};

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
    <Fragment>
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
    </Fragment>
  );
};

const KitchenSinkInput = (props, context) => {
  const [
    number,
    setNumber,
  ] = useLocalState(context, 'number', 0);

  const [
    text,
    setText,
  ] = useLocalState(context, 'text', "Sample text");

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Input (onChange)">
          <Input
            value={text}
            onChange={(e, value) => setText(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="Input (onInput)">
          <Input
            value={text}
            onInput={(e, value) => setText(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="NumberInput (onChange)">
          <NumberInput
            animated
            width="40px"
            step={1}
            stepPixelSize={5}
            value={number}
            minValue={-100}
            maxValue={100}
            onChange={(e, value) => setNumber(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="NumberInput (onDrag)">
          <NumberInput
            animated
            width="40px"
            step={1}
            stepPixelSize={5}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="Slider (onDrag)">
          <Slider
            step={1}
            stepPixelSize={5}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="Knob (onDrag)">
          <Knob
            inline
            size={1}
            step={1}
            stepPixelSize={2}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)} />
          <Knob
            ml={1}
            inline
            bipolar
            size={1}
            step={1}
            stepPixelSize={2}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="Rotating Icon">
          <Box inline position="relative">
            <DraggableControl
              value={number}
              minValue={-100}
              maxValue={100}
              dragMatrix={[0, -1]}
              step={1}
              stepPixelSize={5}
              onDrag={(e, value) => setNumber(value)}>
              {control => (
                <Box onMouseDown={control.handleDragStart}>
                  <Icon
                    size={4}
                    color="yellow"
                    name="times"
                    rotation={control.displayValue * 4} />
                  {control.inputElement}
                </Box>
              )}
            </DraggableControl>
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

const KitchenSinkCollapsible = props => {
  return (
    <Collapsible
      title="Collapsible Demo"
      buttons={(
        <Button icon="cog" />
      )}>
      <Section>
        <BoxWithSampleText />
      </Section>
    </Collapsible>
  );
};

const BoxWithSampleText = props => {
  return (
    <Box {...props}>
      <Box italic>
        Jackdaws love my big sphinx of quartz.
      </Box>
      <Box mt={1} bold>
        The wide electrification of the southern
        provinces will give a powerful impetus to the
        growth of agriculture.
      </Box>
    </Box>
  );
};

const KitchenSinkBlockQuote = props => {
  return (
    <BlockQuote>
      <BoxWithSampleText />
    </BlockQuote>
  );
};

const KitchenSinkByondUi = (props, context) => {
  const { config } = useBackend(context);
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

const KitchenSinkThemes = (props, context) => {
  const [theme, setTheme] = useLocalState(context, 'kitchenSinkTheme');
  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Use theme">
          <Input
            placeholder="theme_name"
            value={theme}
            onInput={(e, value) => setTheme(value)} />
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

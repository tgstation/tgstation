/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, ByondUi, Collapsible, DraggableControl, Flex, Icon, Input, Knob, LabeledList, NoticeBox, NumberInput, ProgressBar, Section, Slider, Tabs, Tooltip } from '../components';
import { formatSiUnit } from '../format';
import { Pane, Window } from '../layouts';
import { createLogger } from '../logging';

const logger = createLogger('KitchenSink');

const COLORS_SPECTRUM = [
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
    title: 'Flex & Sections',
    component: () => KitchenSinkFlexAndSections,
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
  {
    title: 'Storage',
    component: () => KitchenSinkStorage,
  },
];

export const KitchenSink = (props, context) => {
  const { panel } = props;
  const [theme] = useLocalState(context, 'kitchenSinkTheme');
  const [pageIndex, setPageIndex] = useLocalState(context, 'pageIndex', 0);
  const PageComponent = PAGES[pageIndex].component();
  const Layout = panel ? Pane : Window;
  return (
    <Layout
      title="Kitchen Sink"
      width={600}
      height={500}
      theme={theme}
      resizable>
      <Flex height="100%">
        <Flex.Item m={1} mr={0}>
          <Section fill fitted>
            <Tabs vertical>
              {PAGES.map((page, i) => (
                <Tabs.Tab
                  key={i}
                  color="transparent"
                  selected={i === pageIndex}
                  onClick={() => setPageIndex(i)}>
                  {page.title}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Flex.Item>
        <Flex.Item
          position="relative"
          grow={1}>
          <Layout.Content scrollable>
            <PageComponent />
          </Layout.Content>
        </Flex.Item>
      </Flex>
    </Layout>
  );
};

const KitchenSinkButton = props => {
  return (
    <Section>
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
        {COLORS_SPECTRUM.map(color => (
          <Button
            key={color}
            color={color}
            content={color} />
        ))}
        <br />
        {COLORS_SPECTRUM.map(color => (
          <Box inline
            mx="7px"
            key={color}
            color={color}>
            {color}
          </Box>
        ))}
      </Box>
    </Section>
  );
};

const KitchenSinkBox = props => {
  return (
    <Section>
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
    </Section>
  );
};

const KitchenSinkFlexAndSections = (props, context) => {
  const [grow, setGrow] = useLocalState(
    context, 'fs_grow', 1);
  const [direction, setDirection] = useLocalState(
    context, 'fs_direction', 'column');
  const [fill, setFill] = useLocalState(
    context, 'fs_fill', true);
  const [hasTitle, setHasTitle] = useLocalState(
    context, 'fs_title', true);
  return (
    <Flex
      height="100%"
      direction="column">
      <Flex.Item mb={1}>
        <Section>
          <Button
            fluid
            onClick={() => setDirection(
              direction === 'column' ? 'row' : 'column'
            )}>
            {`Flex direction="${direction}"`}
          </Button>
          <Button
            fluid
            onClick={() => setGrow(Number(!grow))}>
            {`Flex.Item grow={${grow}}`}
          </Button>
          <Button
            fluid
            onClick={() => setFill(!fill)}>
            {`Section fill={${String(fill)}}`}
          </Button>
          <Button
            fluid
            selected={hasTitle}
            onClick={() => setHasTitle(!hasTitle)}>
            {`Section title`}
          </Button>
        </Section>
      </Flex.Item>
      <Flex.Item grow={1}>
        <Flex
          height="100%"
          direction={direction}>
          <Flex.Item
            mr={direction === 'row' && 1}
            mb={direction === 'column' && 1}
            grow={grow}>
            <Section
              title={hasTitle && "Section 1"}
              fill={fill}>
              Content
            </Section>
          </Flex.Item>
          <Flex.Item grow={grow}>
            <Section
              title={hasTitle && "Section 2"}
              fill={fill}>
              Content
            </Section>
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

const KitchenSinkProgressBar = (props, context) => {
  const [
    progress,
    setProgress,
  ] = useLocalState(context, 'progress', 0.5);
  return (
    <Section>
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
    </Section>
  );
};

const KitchenSinkTabs = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [tabProps, setTabProps] = useLocalState(context, 'tabProps', {});
  const TAB_RANGE = [
    'Tab #1',
    'Tab #2',
    'Tab #3',
    'Tab #4',
  ];
  return (
    <Fragment>
      <Section>
        <Button.Checkbox
          inline
          content="vertical"
          checked={tabProps.vertical}
          onClick={() => setTabProps({
            ...tabProps,
            vertical: !tabProps.vertical,
          })} />
        <Button.Checkbox
          inline
          content="leftSlot"
          checked={tabProps.leftSlot}
          onClick={() => setTabProps({
            ...tabProps,
            leftSlot: !tabProps.leftSlot,
          })} />
        <Button.Checkbox
          inline
          content="rightSlot"
          checked={tabProps.rightSlot}
          onClick={() => setTabProps({
            ...tabProps,
            rightSlot: !tabProps.rightSlot,
          })} />
        <Button.Checkbox
          inline
          content="icon"
          checked={tabProps.icon}
          onClick={() => setTabProps({
            ...tabProps,
            icon: !tabProps.icon,
          })} />
        <Button.Checkbox
          inline
          content="fluid"
          checked={tabProps.fluid}
          onClick={() => setTabProps({
            ...tabProps,
            fluid: !tabProps.fluid,
          })} />
        <Button.Checkbox
          inline
          content="left aligned"
          checked={tabProps.leftAligned}
          onClick={() => setTabProps({
            ...tabProps,
            leftAligned: !tabProps.leftAligned,
          })} />
      </Section>
      <Section fitted>
        <Tabs
          vertical={tabProps.vertical}
          fluid={tabProps.fluid}
          textAlign={tabProps.leftAligned && 'left'}>
          {TAB_RANGE.map((text, i) => (
            <Tabs.Tab
              key={i}
              selected={i === tabIndex}
              icon={tabProps.icon && 'info-circle'}
              leftSlot={tabProps.leftSlot && (
                <Button
                  circular
                  compact
                  color="transparent"
                  icon="times" />
              )}
              rightSlot={tabProps.rightSlot && (
                <Button
                  circular
                  compact
                  color="transparent"
                  icon="times" />
              )}
              onClick={() => setTabIndex(i)}>
              {text}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Section>
    </Fragment>
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
    <Section>
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
    </Section>
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
    <Section>
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
    </Section>
  );
};

const KitchenSinkCollapsible = props => {
  return (
    <Section>
      <Collapsible
        title="Collapsible Demo"
        buttons={(
          <Button icon="cog" />
        )}>
        <BoxWithSampleText />
      </Collapsible>
    </Section>
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
    <Section>
      <BlockQuote>
        <BoxWithSampleText />
      </BlockQuote>
    </Section>
  );
};

const KitchenSinkByondUi = (props, context) => {
  const { config } = useBackend(context);
  const [code, setCode] = useLocalState(context,
    'byondUiEvalCode',
    `Byond.winset('${window.__windowId__}', {\n  'is-visible': true,\n})`);
  return (
    <Fragment>
      <Section title="Button">
        <ByondUi
          params={{
            type: 'button',
            text: 'Button',
          }} />
      </Section>
      <Section
        title="Make BYOND calls"
        buttons={(
          <Button
            icon="chevron-right"
            onClick={() => setImmediate(() => {
              try {
                const result = new Function('return (' + code + ')')();
                if (result && result.then) {
                  logger.log('Promise');
                  result.then(logger.log);
                }
                else {
                  logger.log(result);
                }
              }
              catch (err) {
                logger.log(err);
              }
            })}>
            Evaluate
          </Button>
        )}>
        <Box
          as="textarea"
          width="100%"
          height="10em"
          onChange={e => setCode(e.target.value)}>
          {code}
        </Box>
      </Section>
    </Fragment>
  );
};

const KitchenSinkThemes = (props, context) => {
  const [theme, setTheme] = useLocalState(context, 'kitchenSinkTheme');
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Use theme">
          <Input
            placeholder="theme_name"
            value={theme}
            onInput={(e, value) => setTheme(value)} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const KitchenSinkStorage = (props, context) => {
  if (!window.localStorage) {
    return (
      <NoticeBox>
        Local storage is not available.
      </NoticeBox>
    );
  }
  return (
    <Section
      title="Local Storage"
      buttons={(
        <Button
          icon="recycle"
          onClick={() => {
            localStorage.clear();
          }}>
          Clear
        </Button>
      )}>
      <LabeledList>
        <LabeledList.Item label="Keys in use">
          {localStorage.length}
        </LabeledList.Item>
        <LabeledList.Item label="Remaining space">
          {formatSiUnit(localStorage.remainingSpace, 0, 'B')}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

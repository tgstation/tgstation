/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useState } from 'react';
import { Button, Section, Tabs } from 'tgui-core/components';

export const meta = {
  title: 'Tabs',
  render: () => <Story />,
};

const TAB_RANGE = ['Tab #1', 'Tab #2', 'Tab #3', 'Tab #4'] as const;

type TabProps = Partial<{
  centered: boolean;
  fluid: boolean;
  icon: boolean;
  leftSlot: boolean;
  rightSlot: boolean;
  vertical: boolean;
}>;

function Story() {
  const [tabProps, setTabProps] = useState<TabProps>({});

  return (
    <>
      <Section>
        <Button.Checkbox
          inline
          checked={tabProps.vertical}
          onClick={() =>
            setTabProps({
              ...tabProps,
              vertical: !tabProps.vertical,
            })
          }
        >
          Vertical
        </Button.Checkbox>
        <Button.Checkbox
          inline
          checked={tabProps.leftSlot}
          onClick={() =>
            setTabProps({
              ...tabProps,
              leftSlot: !tabProps.leftSlot,
            })
          }
        >
          leftSlot
        </Button.Checkbox>
        <Button.Checkbox
          inline
          checked={tabProps.rightSlot}
          onClick={() =>
            setTabProps({
              ...tabProps,
              rightSlot: !tabProps.rightSlot,
            })
          }
        >
          rightSlot
        </Button.Checkbox>
        <Button.Checkbox
          inline
          checked={tabProps.icon}
          onClick={() =>
            setTabProps({
              ...tabProps,
              icon: !tabProps.icon,
            })
          }
        >
          icon
        </Button.Checkbox>
        <Button.Checkbox
          inline
          checked={tabProps.fluid}
          onClick={() =>
            setTabProps({
              ...tabProps,
              fluid: !tabProps.fluid,
            })
          }
        >
          fluid
        </Button.Checkbox>
        <Button.Checkbox
          inline
          checked={tabProps.centered}
          onClick={() =>
            setTabProps({
              ...tabProps,
              centered: !tabProps.centered,
            })
          }
        >
          centered
        </Button.Checkbox>
      </Section>
      <Section fitted>
        <TabsPrefab />
      </Section>
      <Section title="Normal section">
        <TabsPrefab />
        Some text
      </Section>
      <Section>
        Section-less tabs appear the same as tabs in a fitted section:
      </Section>
      <TabsPrefab />
    </>
  );
}

function TabsPrefab() {
  const [tabIndex, setTabIndex] = useState(0);
  const [tabProps] = useState<TabProps>({});

  return (
    <Tabs
      vertical={tabProps.vertical}
      fluid={tabProps.fluid}
      textAlign={tabProps.centered && 'center'}
    >
      {TAB_RANGE.map((text, i) => (
        <Tabs.Tab
          key={i}
          selected={i === tabIndex}
          icon={tabProps.icon ? 'info-circle' : undefined}
          leftSlot={
            tabProps.leftSlot && (
              <Button circular compact color="transparent" icon="times" />
            )
          }
          rightSlot={
            tabProps.rightSlot && (
              <Button circular compact color="transparent" icon="times" />
            )
          }
          onClick={() => setTabIndex(i)}
        >
          {text}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
}

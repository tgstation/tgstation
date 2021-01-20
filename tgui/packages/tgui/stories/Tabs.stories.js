/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useLocalState } from '../backend';
import { Button, Section, Tabs } from '../components';

export const meta = {
  title: 'Tabs',
  render: () => <Story />,
};

const TAB_RANGE = [
  'Tab #1',
  'Tab #2',
  'Tab #3',
  'Tab #4',
];

const Story = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [tabProps, setTabProps] = useLocalState(context, 'tabProps', {});
  return (
    <>
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
    </>
  );
};

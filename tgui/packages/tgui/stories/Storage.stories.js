/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Button, LabeledList, NoticeBox, Section } from '../components';
import { formatSiUnit } from '../format';

export const meta = {
  title: 'Storage',
  render: () => <Story />,
};

const Story = (props, context) => {
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

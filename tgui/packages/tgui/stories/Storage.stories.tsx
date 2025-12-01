/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

export const meta = {
  title: 'Storage',
  render: () => <Story />,
};

const Story = (props) => {
  if (!window.localStorage) {
    return <NoticeBox>Local storage is not available.</NoticeBox>;
  }

  return (
    <Section
      title="Local Storage"
      buttons={
        <Button
          icon="recycle"
          onClick={() => {
            localStorage.clear();
            storage.clear();
          }}
        >
          Clear
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Keys in use">
          {localStorage.length}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

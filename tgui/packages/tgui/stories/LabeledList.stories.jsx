/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Button, LabeledList } from '../components';

export const meta = {
  title: 'LabeledList',
  render: () => <Story />,
};

const Story = (props) => {
  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Label 1">Entry 1</LabeledList.Item>
        <LabeledList.Item label={<Button>Nodes as labels:</Button>}>
          Entry 2
        </LabeledList.Item>
        <LabeledList.Item labelColor="green" label="labelColor=green">
          Entry 3
        </LabeledList.Item>
        <LabeledList.Item color="green" label="color=green">
          Entry 4
        </LabeledList.Item>
        <LabeledList.Item buttons={<Button>Test</Button>} label="Buttons prop">
          Entry 5
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item label="LabeledList.Divider right above us">
          Entry 6
        </LabeledList.Item>
        <LabeledList.Item
          labelWrap
          label="Very very very very very very very very very very very very very long label with labelWrap">
          Entry 7
        </LabeledList.Item>
        <LabeledList.Item
          labelWrap
          verticalAlign="middle"
          label="Very very very very very very very very very very very very very long label with labelWrap and verticalAlign">
          Entry 8
        </LabeledList.Item>
      </LabeledList>
      <br />
      <br />
      <br />
      <LabeledList>
        <LabeledList.Item labelWrap label="List with all labelWrap=true">
          Entry 1
        </LabeledList.Item>
        <LabeledList.Item labelWrap label="List with all labelWrap=true">
          Entry 2
        </LabeledList.Item>
        <LabeledList.Item labelWrap label="List with all labelWrap=true">
          Entry 3
        </LabeledList.Item>
      </LabeledList>
      <br />
      <br />
      <br />
      <LabeledList>
        <LabeledList.Item label="Very very very very very very very very very very very very very long label without labelWrap">
          Entry 1
        </LabeledList.Item>
      </LabeledList>
    </>
  );
};

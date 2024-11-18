import { LabeledList } from 'tgui-core/components';
type Props = {
  lines: string[];
  ref: string;
};
export default function GenericLines(props: { ourProps: Props }): JSX.Element {
  const { ourProps } = props;
  return (
    <LabeledList>
      {Object.keys(ourProps.lines).map((value, index) => (
        <LabeledList.Item key={value} label={value}>
          {ourProps.lines[value]}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
}

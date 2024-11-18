import { LabeledList } from 'tgui-core/components';
type Data = {
  lines: string[];
  ref: string;
};
export default function GenericLines(props: { ourData: Data }): JSX.Element {
  const { ourData } = props;
  return (
    <LabeledList>
      {Object.keys(ourData.lines).map((value, index) => (
        <LabeledList.Item key={value} label={value}>
          {ourData.lines[value]}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
}

import { useBackend } from '../../../backend';
import { LabeledList } from '../../../components';
type Data = {
  lines: string[];
  ref: string;
};
export default function GenericLines(props: { partData: Data }): JSX.Element {
  const { act } = useBackend<{
    ourData: Data;
  }>();
  const ourData = props.partData as Data;
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

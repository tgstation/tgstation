import { useBackend } from '../../../backend';
import { Box } from '../../../components';
type Data = {
  funnydata: string;
  ref: string;
};
// PLEASE supply partRef in act
export default function Example(props: { partData: Data }): JSX.Element {
  const { act } = useBackend<{
    ourData: Data;
  }>();
  const ourData = props.partData as Data;
  return <Box>{ourData.funnydata}</Box>;
}

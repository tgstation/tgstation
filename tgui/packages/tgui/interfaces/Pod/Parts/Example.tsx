import { useBackend } from '../../../backend';
import { Box } from '../../../components';
type Data = {
  funnydata: string;
  ref: string;
};
// PLEASE supply partRef in act
export default function Example(props: { ourData: Data }): JSX.Element {
  const { act } = useBackend();
  const { ourData } = props;
  return <Box>{ourData.funnydata}</Box>;
}

import { useBackend } from 'tgui/backend';
import { Box } from 'tgui-core/components';
type Props = {
  funnydata: string;
  ref: string;
};
// PLEASE supply partRef in act
export default function Example(props: { ourProps: Props }): JSX.Element {
  const { act } = useBackend();
  const { ourProps } = props;
  return <Box>{ourProps.funnydata}</Box>;
}

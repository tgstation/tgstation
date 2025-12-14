import { Divider, Stack } from 'tgui-core/components';

type Props = {
  title: string;
};

export function GroupTitle(props: Props) {
  const { title } = props;

  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item color="gray">{title}</Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  );
}

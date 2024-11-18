import { useBackend } from 'tgui/backend';
import { Box, Button, Icon, Stack } from 'tgui-core/components';
type Data = {
  dnaSet: string;
  ref: string;
};

export default function DNAPart(props: { ourData: Data }): JSX.Element {
  const { act } = useBackend();
  const { ourData } = props;
  return (
    <Stack vertical>
      <Stack.Item>
        <Box
          textAlign="center"
          fontSize="18px"
          mb={1}
          className="NuclearBomb__displayBox"
        >
          {ourData.dnaSet}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          ml="25%"
          height="48px"
          width="128px"
          onClick={() => act('setprint', { partRef: ourData.ref })}
        >
          <Icon name="fingerprint" size={3} mt="0.5rem" ml="2.8rem" />
        </Button>
      </Stack.Item>
    </Stack>
  );
}

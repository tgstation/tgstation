import { Box, Button, ByondUi, Flex, Icon, Popper, Stack } from "../../components";

export const CharacterPreview = (props: {
  height: string,
  id: string,
}) => {
  return (
    <Stack>
      <Stack.Item>
        <ByondUi
          width="220px"
          height={props.height}
          params={{
            id: props.id,
            type: "map",
          }}
        />
      </Stack.Item>
    </Stack>
  );
};

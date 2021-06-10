import { Box, Button, ByondUi, Flex, Icon, Popper, Stack } from "../../components";

export const CharacterPreview = (props: {
  height: string,
  id: string,
}) => {
  return (<ByondUi
    width="220px"
    height={props.height}
    params={{
      id: props.id,
      type: "map",
    }}
  />);
};

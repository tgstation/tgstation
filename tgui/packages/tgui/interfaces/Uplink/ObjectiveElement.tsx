import { Box, Flex, Stack } from 'tgui-core/components';

export type Objective = {
  id: number;
  name: string;
  description: string;
};

type ObjectiveElementProps = {
  name: string;
  description: string;
};

export const ObjectiveElement = (props: ObjectiveElementProps) => {
  const { name, description } = props;

  return (
    <Flex direction="column">
      <Flex.Item grow={false} basis="content">
        <Box className="UplinkObjective__Titlebar" width="100%" height="100%">
          <Stack>
            <Stack.Item grow={1}>{name} </Stack.Item>
          </Stack>
        </Box>
      </Flex.Item>
      <Flex.Item grow={false} basis="content">
        <Box className="UplinkObjective__Content" height="100%">
          <Box>{description}</Box>
        </Box>
      </Flex.Item>
    </Flex>
  );
};

import { Button, Stack, Box } from '../../components';

export const CircuitInfo = (props, context) => {
  const {
    name,
    desc,
    notices,
    ...rest
  } = props;
  return (
    <Box {...rest}>
      <Stack fill vertical justify="space-around">
        <Stack.Item maxWidth="200px">
          {desc}
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            {notices.map((val, index) => (
              <Stack.Item key={index}>
                <Button
                  content={val.content}
                  color={val.color}
                  icon={val.icon}
                  fluid
                />
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

import { useBackend } from '../backend';
import { Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

export const AntagInfoShade = (props, context) => {
  const { act, data } = useBackend(context);
  const { master_name } = data;
  return (
    <Window width={400} height={400} theme="abductor">
      <Window.Content backgroundColor="#9d0032">
        <Icon
          size={20}
          name="ghost"
          color="#660020"
          position="absolute"
          top="20%"
          left="28%"
        />
        <Section fill>
          <Stack vertical fill textAlign="center">
            <Stack.Item fontSize="20px">
              Your soul has been captured!
            </Stack.Item>
            <Stack.Item fontSize="30px">
              You are bound to the will of {master_name}!
            </Stack.Item>
            <Stack.Item fontSize="20px">
              Help them succeed in their goals at all costs.
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

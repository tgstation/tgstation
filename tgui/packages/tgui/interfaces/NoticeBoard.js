import { useBackend } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';

export const NoticeBoard = (props, context) => {
  const { act, data } = useBackend(context);
  const { allowed, items = {} } = data;

  return (
    <Window width={425} height={176}>
      <Window.Content backgroundColor="#704D25">
        {!items.length ? (
          <Section>
            <Box color="white" align="center">
              The notice board is empty!
            </Box>
          </Section>
        ) : (
          items.map((item, index) => (
            <Flex
              key={item.ref}
              color="black"
              backgroundColor="white"
              style={{ padding: '2px 2px 0 2px' }}
              mb={0.5}>
              <Flex.Item align="center" grow={1}>
                <Box align="center">{item.name}</Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  icon="eye"
                  onClick={() => act('examine', { ref: item.ref })}
                />
                <Button
                  icon="eject"
                  disabled={!allowed}
                  onClick={() => act('remove', { ref: item.ref })}
                />
              </Flex.Item>
            </Flex>
          ))
        )}
      </Window.Content>
    </Window>
  );
};

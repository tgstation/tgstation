import { useBackend } from '../backend';
import { Button, Flex, Box, Section } from '../components';
import { Window } from '../layouts';


export const FilingCabinet = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    contents,
  } = data;
  return (
    <Window
      width={400}
      height={500}>
      <Window.Content scrollable>
        {contents?.length === 0 && (
          <Section>
            <Box color="white" align="center">
              The cabinet is empty!
            </Box>
          </Section>
        ) || contents?.map((paper) => (
          <Flex
            key={paper.ref}
            color="black"
            backgroundColor="white"
            style={{ padding: "2px" }}
            mb={0.5}>
            <Flex.Item grow
              align="center">
              <Box align="center">{paper.name}</Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="eject"
                onClick={() => act("remove", { ref: paper.ref })} />
            </Flex.Item>
          </Flex>
        ))}
      </Window.Content>
    </Window>
  );
};


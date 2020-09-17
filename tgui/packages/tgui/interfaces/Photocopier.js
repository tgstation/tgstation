import { ProgressBar, NumberInput, Button, Section, Box, Flex } from '../components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Photocopier = (props, context) => {
  const { data } = useBackend(context);
  const {
    isAI,
    has_toner,
    has_item,
  } = data;

  return (
    <Window
      title="Photocopier"
      width={240}
      height={isAI ? 309 : 234}>
      <Window.Content>
        {has_toner ? (
          <Toner />
        ) : (
          <Section title="Toner">
            <Box color="average">
              No inserted toner cartridge.
            </Box>
          </Section>
        )}
        {has_item ? (
          <Options />
        ) : (
          <Section title="Options">
            <Box color="average">
              No inserted item.
            </Box>
          </Section>
        )}
        {!!isAI && (
          <AIOptions />
        )}
      </Window.Content>
    </Window>
  );
};

const Toner = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    has_toner,
    max_toner,
    current_toner,
  } = data;

  const average_toner = max_toner * 0.66;
  const bad_toner = max_toner * 0.33;

  return (
    <Section
      title="Toner"
      buttons={
        <Button
          disabled={!has_toner}
          onClick={() => act('remove_toner')}
          icon="eject">
          Eject
        </Button>
      }>
      <ProgressBar
        ranges={{
          good: [average_toner, max_toner],
          average: [bad_toner, average_toner],
          bad: [0, bad_toner],
        }}
        value={current_toner}
        minValue={0}
        maxValue={max_toner} />
    </Section>
  );
};

const Options = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    color_mode,
    is_photo,
    num_copies,
    has_enough_toner,
  } = data;

  return (
    <Section title="Options">
      <Flex>
        <Flex.Item
          mt={0.4}
          width={11}
          color="label">
          Make copies:
        </Flex.Item>
        <Flex.Item>
          <NumberInput
            animate
            width={2.6}
            height={1.65}
            step={1}
            stepPixelSize={8}
            minValue={1}
            maxValue={10}
            value={num_copies}
            onDrag={(e, value) => act('set_copies', {
              num_copies: value,
            })} />
        </Flex.Item>
        <Flex.Item>
          <Button
            ml={0.2}
            icon="copy"
            textAlign="center"
            disabled={!has_enough_toner}
            onClick={() => act('make_copy')}>
            Copy
          </Button>
        </Flex.Item>
      </Flex>
      {!!is_photo && (
        <Flex mt={0.5}>
          <Flex.Item
            mr={0.4}
            width="50%">
            <Button
              fluid
              textAlign="center"
              selected={color_mode === "Greyscale"}
              onClick={() => act('color_mode', {
                mode: "Greyscale",
              })}>
              Greyscale
            </Button>
          </Flex.Item>
          <Flex.Item
            ml={0.4}
            width="50%">
            <Button
              fluid
              textAlign="center"
              selected={color_mode === "Color"}
              onClick={() => act('color_mode', {
                mode: "Color",
              })}>
              Color
            </Button>
          </Flex.Item>
        </Flex>
      )}
      <Button
        mt={0.5}
        textAlign="center"
        icon="reply"
        fluid
        onClick={() => act('remove')}>
        Remove item
      </Button>
    </Section>
  );
};

const AIOptions = (props, context) => {
  const { act, data } = useBackend(context);
  const { can_AI_print } = data;

  return (
    <Section title="AI Options">
      <Box>
        <Button
          fluid
          icon="images"
          textAlign="center"
          disabled={!can_AI_print}
          onClick={() => act('ai_photo')}>
          Print photo from database
        </Button>
      </Box>
    </Section>
  );
};

import { sortBy } from 'common/collections';
import { useBackend } from '../backend';
import { Box, Button, Dropdown, Flex, NumberInput, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const Photocopier = (props, context) => {
  const { data } = useBackend(context);
  const { isAI, has_toner, has_item, forms_exist } = data;

  return (
    <Window title="Photocopier" width={320} height={512}>
      <Window.Content>
        {has_toner ? (
          <Toner />
        ) : (
          <Section title="Toner">
            <Box color="average">No inserted toner cartridge.</Box>
          </Section>
        )}
        {forms_exist ? (
          <Blanks />
        ) : (
          <Section title="Blanks">
            <Box color="average">
              No forms found. Please contact your system administrator.
            </Box>
          </Section>
        )}
        {has_item ? (
          <Options />
        ) : (
          <Section title="Options">
            <Box color="average">No inserted item.</Box>
          </Section>
        )}
        {!!isAI && <AIOptions />}
      </Window.Content>
    </Window>
  );
};

const Toner = (props, context) => {
  const { act, data } = useBackend(context);
  const { has_toner, max_toner, current_toner } = data;

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
        maxValue={max_toner}
      />
    </Section>
  );
};

const Options = (props, context) => {
  const { act, data } = useBackend(context);
  const { color_mode, is_photo, num_copies, has_enough_toner } = data;

  return (
    <Section title="Options">
      <Flex>
        <Flex.Item mt={0.4} width={11} color="label">
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
            onDrag={(e, value) =>
              act('set_copies', {
                num_copies: value,
              })
            }
          />
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
          <Flex.Item mr={0.4} width="50%">
            <Button
              fluid
              textAlign="center"
              selected={color_mode === 'Greyscale'}
              onClick={() =>
                act('color_mode', {
                  mode: 'Greyscale',
                })
              }>
              Greyscale
            </Button>
          </Flex.Item>
          <Flex.Item ml={0.4} width="50%">
            <Button
              fluid
              textAlign="center"
              selected={color_mode === 'Color'}
              onClick={() =>
                act('color_mode', {
                  mode: 'Color',
                })
              }>
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

const Blanks = (props, context) => {
  const { act, data } = useBackend(context);
  const { blanks, category, has_toner } = data;

  const sortedBlanks = sortBy((blank) => blanks.category)(blanks || []);

  const categories = [];
  for (let blank of sortedBlanks) {
    if (!categories.includes(blank.category)) {
      categories.push(blank.category);
    }
  }

  const selectedCategory = category ?? categories[0];
  const visibleBlanks = sortedBlanks.filter(
    (blank) => blank.category === selectedCategory
  );

  return (
    <Section title="Blanks">
      <Dropdown
        width="100%"
        options={categories}
        selected={selectedCategory}
        onSelected={(value) =>
          act('choose_category', {
            category: value,
          })
        }
      />
      <Box mt={0.4}>
        {visibleBlanks.map((blank) => (
          <Button
            key={blank.code}
            title={blank.name}
            disabled={!has_toner}
            onClick={() =>
              act('print_blank', {
                name: blank.name,
                info: blank.info,
              })
            }>
            {blank.code}
          </Button>
        ))}
      </Box>
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

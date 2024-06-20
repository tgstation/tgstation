import { sortBy } from 'common/collections';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  NumberInput,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const Photocopier = (props) => {
  const { data } = useBackend();
  const {
    isAI,
    has_toner,
    has_item,
    categories = [],
    paper_count,
    copies_left,
  } = data;

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
        <Section title="Paper">
          <Box color="label">Paper stored: {paper_count}</Box>
          {!!copies_left && (
            <Box color="label">Copies in queue: {copies_left}</Box>
          )}
        </Section>
        {categories.length !== 0 ? (
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

const Toner = (props) => {
  const { act, data } = useBackend();
  const { max_toner, current_toner } = data;

  const average_toner = max_toner * 0.66;
  const bad_toner = max_toner * 0.33;

  return (
    <Section
      title="Toner"
      buttons={
        <Button onClick={() => act('remove_toner')} icon="eject">
          Eject
        </Button>
      }
    >
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

const Options = (props) => {
  const { act, data } = useBackend();
  const { color_mode, is_photo, num_copies } = data;

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
            onDrag={(value) =>
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
            onClick={() => act('make_copy')}
          >
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
              }
            >
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
              }
            >
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
        onClick={() => act('remove')}
      >
        Remove item
      </Button>
    </Section>
  );
};

const Blanks = (props) => {
  const { act, data } = useBackend();
  const { blanks, categories, category } = data;

  const sortedBlanks = sortBy(blanks || [], (blank) => blank.name);

  const selectedCategory = category ?? categories[0];
  const visibleBlanks = sortedBlanks.filter(
    (blank) => blank.category === selectedCategory,
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
            onClick={() =>
              act('print_blank', {
                code: blank.code,
              })
            }
          >
            {blank.code}
          </Button>
        ))}
      </Box>
    </Section>
  );
};

const AIOptions = (props) => {
  const { act, data } = useBackend();
  const { can_AI_print } = data;

  return (
    <Section title="AI Options">
      <Box>
        <Button
          fluid
          icon="images"
          textAlign="center"
          disabled={!can_AI_print}
          onClick={() => act('ai_photo')}
        >
          Print photo from database
        </Button>
      </Box>
    </Section>
  );
};

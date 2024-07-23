import { createSearch } from 'common/string';
import { useState } from 'react';

import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import {
  Button,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Data = {
  has_item: BooleanLike;
  has_toner: BooleanLike;
  can_AI_print: BooleanLike;
  isAI: BooleanLike;
  is_photo: BooleanLike;
  categories: string[];
  color_mode: string;
  num_copies: number;
  max_copies: number;
  copies_left: number;
  max_toner: number;
  current_toner: number;
  paper_count: number;
  max_paper_count: number;
  blanks: Blank[];
};

type Blank = {
  name: string;
  category: string;
  code: string;
};

export const Photocopier = (props) => {
  const [selectedBlank, setSelectedBlank] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');

  return (
    <Window
      title="Photocopier"
      width={selectedCategory ? 550 : 225}
      height={525}
    >
      <Window.Content>
        <Stack fill>
          <Stack.Item basis={selectedCategory ? '40%' : '100%'}>
            <Stack fill vertical>
              <Stack.Item>
                <Status selectedBlank={selectedBlank} />
              </Stack.Item>
              <Stack.Item>
                <Actions selectedBlank={selectedBlank} />
              </Stack.Item>
              <Stack.Item grow>
                <Categories
                  selectedCategory={selectedCategory}
                  setSelectedCategory={setSelectedCategory}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {selectedCategory && (
            <Stack.Item basis="60%">
              <Stack fill vertical>
                <Stack.Item grow>
                  <Blanks
                    selectedCategory={selectedCategory}
                    selectedBlank={selectedBlank}
                    setSelectedBlank={setSelectedBlank}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

type StatusProps = {
  selectedBlank: string | null;
};

const Status = (props: StatusProps) => {
  const { act, data } = useBackend<Data>();
  const { selectedBlank } = props;
  const {
    has_toner,
    copies_left,
    num_copies,
    current_toner,
    max_toner,
    paper_count,
    max_paper_count,
  } = data;

  const average_toner = max_toner * 0.66;
  const bad_toner = max_toner * 0.33;

  const average_paper = max_paper_count * 0.33;
  const bad_paper = max_paper_count * 0.1;

  return (
    <Section
      fill
      title="Status"
      buttons={
        <Button
          icon="eject"
          disabled={!has_toner}
          onClick={() => act('remove_toner')}
        >
          Eject Toner
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Toner">
          {has_toner ? (
            <ProgressBar
              minValue={0}
              value={current_toner}
              maxValue={max_toner}
              ranges={{
                average: [bad_toner, average_toner],
                bad: [0, bad_toner],
              }}
            />
          ) : (
            <ProgressBar color="bad" minValue={0} value={0} maxValue={1}>
              No Cartridge
            </ProgressBar>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Paper Stored">
          <ProgressBar
            minValue={0}
            value={paper_count}
            maxValue={max_paper_count}
            ranges={{
              average: [bad_paper, average_paper],
              bad: [0, bad_paper],
            }}
          >
            {paper_count} / {max_paper_count}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Queue">
          <ProgressBar
            verticalAlign="middle"
            minValue={0}
            value={copies_left}
            maxValue={num_copies}
          >
            {copies_left ? `${copies_left} / ${num_copies}` : 'Empty'}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Blank" textAlign="center">
          <b>{selectedBlank ? selectedBlank : 'Not Selected'}</b>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

type ActionsProps = {
  selectedBlank: string | null;
};

const Actions = (props: ActionsProps) => {
  const { act, data } = useBackend<Data>();
  const { selectedBlank } = props;
  const {
    has_item,
    is_photo,
    num_copies,
    max_copies,
    color_mode,
    isAI,
    can_AI_print,
  } = data;

  return (
    <Section fill title="Actions">
      <Stack fill vertical textAlign="center">
        <Stack.Item>
          <Stack align="center" textAlign="left">
            <Stack.Item grow color="label">
              Copies:
            </Stack.Item>
            <Stack.Item grow>
              <Slider
                animated
                minValue={1}
                value={num_copies}
                maxValue={max_copies}
                stepPixelSize={10}
                onChange={(e, value) =>
                  act('set_copies', {
                    num_copies: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {!!isAI && (
          <Stack.Item>
            <Button
              fluid
              icon="images"
              disabled={!can_AI_print}
              onClick={() => act('ai_photo', { code: selectedBlank })}
            >
              Print photo from database
            </Button>
          </Stack.Item>
        )}
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                icon="print"
                disabled={!selectedBlank}
                onClick={() => act('print_blank', { code: selectedBlank })}
              >
                Print
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="copy"
                disabled={!has_item}
                onClick={() => act('make_copy')}
              >
                Copy
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {!!has_item && !!is_photo && (
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="palette"
                  selected={color_mode === 'Color'}
                  onClick={() =>
                    act('color_mode', {
                      mode: 'Color',
                    })
                  }
                >
                  Color
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="pen"
                  selected={color_mode === 'Greyscale'}
                  onClick={() =>
                    act('color_mode', {
                      mode: 'Greyscale',
                    })
                  }
                >
                  Greyscale
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          <Button
            fluid
            icon={has_item ? 'eject' : 'times'}
            disabled={!has_item}
            onClick={() => act('remove')}
          >
            Eject Item
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type CategoriesProps = {
  selectedCategory: string | null;
  setSelectedCategory: (category: string) => void;
};

const Categories = (props: CategoriesProps) => {
  const { act, data } = useBackend<Data>();
  const { selectedCategory, setSelectedCategory } = props;

  return (
    <Section
      fill
      scrollable
      title="Blanks"
      buttons={
        <Button
          icon="times"
          tooltip="Close selected blank category"
          disabled={!selectedCategory}
          onClick={() => {
            setSelectedCategory('');
          }}
        />
      }
    >
      <Stack fill vertical zebra>
        <Stack.Item>
          <Button
            fluid
            icon="chevron-right"
            color="transparent"
            selected={selectedCategory === 'All Blanks'}
            onClick={() => {
              setSelectedCategory('All Blanks');
            }}
          >
            All Blanks
          </Button>
        </Stack.Item>
        {data.categories.map((category) => (
          <Stack.Item mt={0.25} key={category}>
            <Button
              fluid
              icon="chevron-right"
              color="transparent"
              selected={selectedCategory === category}
              onClick={() => {
                setSelectedCategory(category);
              }}
            >
              {category}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

type BlanksProps = {
  selectedCategory: string | null;
  selectedBlank: string | null;
  setSelectedBlank: (blank: string) => void;
};

const Blanks = (props: BlanksProps) => {
  const { act, data } = useBackend<Data>();
  const { selectedCategory, selectedBlank, setSelectedBlank } = props;
  const { blanks } = data;

  const [searchText, setSearchText] = useState('');
  const search = createSearch(searchText, (blank: Blank) => blank.name);
  const sortedBlanks = blanks.sort((a, b) => (a.name > b.name ? 1 : -1));
  const visibleBlanks = searchText
    ? sortedBlanks.filter(search)
    : selectedCategory === 'All Blanks'
      ? sortedBlanks
      : sortedBlanks.filter((blank) => blank.category === selectedCategory);

  return (
    <Section
      fill
      scrollable
      title={selectedCategory}
      buttons={
        <Input
          width={8.75}
          value={searchText}
          placeholder="Search blank..."
          onInput={(e, value) => setSearchText(value)}
        />
      }
    >
      <Stack fill vertical zebra>
        {visibleBlanks.map((blank) => (
          <Stack.Item key={blank.code} mt={0.5}>
            <Button
              fluid
              ellipsis
              color="transparent"
              selected={blank.code === selectedBlank}
              onClick={() => setSelectedBlank(blank.code)}
            >
              {blank.name}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

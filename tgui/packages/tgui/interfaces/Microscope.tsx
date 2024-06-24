import { BooleanLike } from 'common/react';
import { classes } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Data = {
  has_dish: BooleanLike;
  cell_lines: CellLine[];
};

type CellLine = {
  type: string;
  name: string;
  desc: string;
  icon: string;
  growth_rate: number;
  suspectibility: number;
  requireds: string[];
  supplementaries: string[];
  suppressives: string[];
};

export const Microscope = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_dish, cell_lines = [] } = data;

  return (
    <Window width={600} height={600}>
      <Window.Content scrollable>
        <Section
          title={has_dish ? 'Petri Dish Sample' : 'No Petri Dish'}
          buttons={
            !!has_dish && (
              <Button
                icon="eject"
                disabled={!has_dish}
                onClick={() => act('eject_petridish')}
              >
                Take Dish
              </Button>
            )
          }
        >
          <CellList cell_lines={cell_lines} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const CellList = (props) => {
  const { cell_lines } = props;
  const { act, data } = useBackend<Data>();
  if (!cell_lines.length) {
    return <NoticeBox>No micro-organisms found</NoticeBox>;
  }

  return cell_lines.map((cell_line) => {
    return (
      <Stack key={cell_line.desc}>
        <Stack.Item>
          <Box
            m={'16px'}
            style={{
              transform: 'scale(2)',
            }}
            className={classes(['cell_line32x32', cell_line.icon])}
          />
        </Stack.Item>
        <Stack.Item>
          <Section
            title={cell_line.desc}
            style={{ textTransform: 'capitalize' }}
          >
            <LabeledList>
              {/* <LabeledList.Item label="Type">{cell_line.type}</LabeledList.Item>
              <LabeledList.Item label="Name">{cell_line.name}</LabeledList.Item>
              <LabeledList.Item label="Description">
                {cell_line.desc}
              </LabeledList.Item> */}
              <LabeledList.Item label="Growth Rate">
                {cell_line.growth_rate}
              </LabeledList.Item>
              <LabeledList.Item label="Virus Suspectibility">
                {cell_line.suspectibility}
              </LabeledList.Item>
              <LabeledList.Item label="Required Reagents">
                {cell_line.requireds}
              </LabeledList.Item>
              <LabeledList.Item label="Supplementary Reagents">
                {cell_line.supplementaries}
              </LabeledList.Item>
              <LabeledList.Item label="Suppresive reagents">
                {cell_line.suppressives}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    );
  });
};

import { range } from 'es-toolkit';
import type { PropsWithChildren } from 'react';
import { Box, Button, FitText, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const CELLS_PER_GROUP = 4;
const CELL_WIDTH = 150;
const CELL_HEIGHT = 100;

type PuzzgridGroup = {
  answers: string[];
};

type PuzzgridData = {
  answers: string[];
  host: string;
  lives: number;
  selected_answers: string[];
  solved_groups: PuzzgridGroup[];
  time_left: number;
  wrong_group_select_cooldown: BooleanLike;
};

const PuzzgridButton = (
  props: {
    // In the future, this would be the TypeScript props of the button
    [key: string]: unknown;
  } & PropsWithChildren,
) => {
  return (
    <Button
      verticalAlignContent="middle"
      style={{
        width: '100%',
        height: '100%',

        textAlign: 'center',
        verticalAlign: 'middle',
        whiteSpace: 'normal',
      }}
      {...props}
    >
      <FitText maxFontSize={17} maxWidth={CELL_WIDTH}>
        {props.children}
      </FitText>
    </Button>
  );
};

export const Puzzgrid = (props) => {
  const { act, data } = useBackend<PuzzgridData>();

  const answersLeft = data.answers.filter(
    (answer) =>
      !data.solved_groups.find((group) => group.answers.indexOf(answer) !== -1),
  );

  return (
    <Window
      title={data.host}
      width={CELL_WIDTH * CELLS_PER_GROUP}
      height={CELL_HEIGHT * CELLS_PER_GROUP}
    >
      <Window.Content>
        <Stack vertical fill>
          {data.solved_groups.map((group, groupIndex) => (
            <Stack.Item key={groupIndex} grow>
              <Stack fill>
                {group.answers.map((answer, answerIndex) => {
                  return (
                    <Stack.Item key={answerIndex} width={CELL_WIDTH}>
                      <PuzzgridButton disabled>{answer}</PuzzgridButton>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Stack.Item>
          ))}

          {range(0, answersLeft.length / CELLS_PER_GROUP).map((row) => (
            <Stack.Item key={row} grow>
              <Stack fill>
                {range(0, CELLS_PER_GROUP).map((column) => {
                  const answer = answersLeft[row * CELLS_PER_GROUP + column];
                  const selected = data.selected_answers.indexOf(answer) !== -1;

                  return (
                    <Stack.Item key={column} width={CELL_WIDTH}>
                      <PuzzgridButton
                        disabled={!!data.wrong_group_select_cooldown}
                        selected={selected}
                        onClick={() =>
                          act(selected ? 'unselect' : 'select', {
                            answer,
                          })
                        }
                      >
                        {answer}
                      </PuzzgridButton>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>

        {data.solved_groups.length === CELLS_PER_GROUP - 2 && (
          <Box
            color="red"
            style={{
              textShadow: '1px 1px 1px #222',
              fontSize: '30px',
              position: 'absolute',
              top: '0',
              left: '10px',
            }}
          >
            {range(0, data.lives).map((live) => (
              <span key={live}>♥</span>
            ))}
          </Box>
        )}

        {data.time_left && (
          <Box
            style={{
              textShadow: '1px 1px 1px #222',
              textAlign: 'right',
              fontSize: '15px',
              pointerEvents: 'none',
              position: 'absolute',
              top: '0',
              right: '10px',
            }}
          >
            {Math.ceil(data.time_left)}s
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};

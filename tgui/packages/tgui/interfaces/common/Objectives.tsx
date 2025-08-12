import type { ReactNode } from 'react';
import { Button, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';

export type Objective = {
  // The title of the objective, not actually displayed so optional
  name?: string;
  // What "number" objective this is, IE, its index in the list of objectives
  count: number;
  // The text explaining what this objective requires
  explanation: string;
  // Whether or not this objective is completed
  complete: BooleanLike;
};

type ObjectivePrintoutProps = {
  // For passing onto the Stack component
  fill?: boolean;
  // Allows additional components to follow the printout in the same stack
  objectiveFollowup?: ReactNode;
  // The prefix to use for each objective, defaults to "#" (#1, #2)
  objectivePrefix?: string;
  // The font size to use for each objective
  objectiveTextSize?: string;
  // The objectives to print out
  objectives: Objective[];
  // The title to use for the printout, defaults to "Your current objectives"
  titleMessage?: string;
};

export const ObjectivePrintout = (props: ObjectivePrintoutProps) => {
  const {
    fill,
    objectiveFollowup,
    objectivePrefix,
    objectiveTextSize,
    objectives = [],
    titleMessage,
  } = props;

  return (
    <Stack fill={fill} vertical>
      <Stack.Item bold>{titleMessage || `Your current objectives`}:</Stack.Item>
      <Stack.Item>
        {(objectives.length === 0 && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item fontSize={objectiveTextSize} key={objective.count}>
              {objectivePrefix || '#'}
              {objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
      {!!objectiveFollowup && <Stack.Item>{objectiveFollowup}</Stack.Item>}
    </Stack>
  );
};

type ReplaceObjectivesProps = {
  // Whether we can actually use this button
  can_change_objective: BooleanLike;
  // What do we call our button
  button_title: string;
  // What colour is our button
  button_colour: string;
  // Tooltip to display on our button
  button_tooltip?: string;
};

export const ReplaceObjectivesButton = (props: ReplaceObjectivesProps) => {
  const {
    can_change_objective,
    button_title,
    button_colour,
    button_tooltip = 'Replace your existing objectives with a custom one. This action can only be taken once',
  } = props;
  const { act } = useBackend();
  if (!can_change_objective) {
    return null;
  }
  return (
    <Button
      color={button_colour}
      content={button_title}
      tooltip={button_tooltip}
      onClick={() => act('change_objectives')}
    />
  );
};

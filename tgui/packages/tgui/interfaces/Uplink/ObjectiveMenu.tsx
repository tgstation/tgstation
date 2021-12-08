import { classes } from "common/react";
import { Component } from "inferno";
import { Section, Stack, Box, Button, Flex } from "../../components";
import { calculateProgression, getReputation, Rank } from "./calculateReputationLevel";

export type Objective = {
  id: number,
  name: string,
  description: string,
  progression_minimum: number,
  progression_reward: number,
  telecrystal_reward: number,
  ui_buttons?: ObjectiveUiButton[],
  objective_state: number,
}

export type ObjectiveUiButton = {
  name: string,
  tooltip: string,
  icon: string,
  action: string,
}

type ObjectiveMenuProps = {
  activeObjectives: Objective[];
  potentialObjectives: Objective[];
  maximumActiveObjectives: number;

  handleStartObjective: (objective: Objective) => void;
  handleObjectiveAction: (objective: Objective, action: string) => void;
}

type ObjectiveMenuState = {
  draggingObjective: Objective|null;
  objectiveX: number;
  objectiveY: number;
}

export class ObjectiveMenu
  extends Component<ObjectiveMenuProps, ObjectiveMenuState> {
  constructor() {
    super();
    this.state = {
      draggingObjective: null,
      objectiveX: 0,
      objectiveY: 0,
    };

    this.handleObjectiveClick = this.handleObjectiveClick.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);
    this.handleMouseMove = this.handleMouseMove.bind(this);
    this.handleObjectiveAdded = this.handleObjectiveAdded.bind(this);
  }

  handleObjectiveClick(event: MouseEvent, objective: Objective) {
    if (event.button === 0) { // Left click
      this.setState({
        draggingObjective: objective,
        objectiveX: event.clientX,
        objectiveY: event.clientY,
      });
      window.addEventListener('mouseup', this.handleMouseUp);
      window.addEventListener('mousemove', this.handleMouseMove);
      event.stopPropagation();
      event.preventDefault();
    }
  }

  handleMouseUp(event: MouseEvent) {
    window.removeEventListener('mouseup', this.handleMouseUp);
    window.removeEventListener('mousemove', this.handleMouseMove);
    this.setState({
      draggingObjective: null,
    });
  }

  handleMouseMove(event: MouseEvent) {
    this.setState({
      objectiveX: event.pageX,
      objectiveY: event.pageY - 32,
    });
  }

  handleObjectiveAdded(event: MouseEvent) {
    const {
      draggingObjective,
    } = this.state as ObjectiveMenuState;
    if (!draggingObjective) {
      return;
    }
    const { handleStartObjective } = this.props;
    handleStartObjective(draggingObjective);
  }

  render() {
    const {
      activeObjectives = [],
      potentialObjectives,
      maximumActiveObjectives,
      handleObjectiveAction,
    } = this.props;
    const {
      draggingObjective,
      objectiveX,
      objectiveY,
    } = this.state as ObjectiveMenuState;

    potentialObjectives.sort((objA, objB) => {
      if (objA.progression_minimum < objB.progression_minimum) {
        return 1;
      } else if (objA.progression_minimum > objB.progression_minimum) {
        return -1;
      }
      return 0;
    });
    return (
      <>
        <Stack vertical fill scrollable>
          <Stack.Item>
            <Section>
              <Stack>
                {Array.apply(null,
                  Array(maximumActiveObjectives)).map((_, index) => {
                  if (index >= activeObjectives.length) {
                    return (
                      <Stack.Item
                        key={index}
                        minHeight="100px"
                        grow
                      >
                        <Box
                          color="label"
                          className="UplinkObjective__EmptyObjective"
                          onMouseUp={this.handleObjectiveAdded}
                        >
                          <Stack textAlign="center" fill align="center">
                            <Stack.Item textAlign="center" width="100%">
                              Empty Objective
                            </Stack.Item>
                          </Stack>
                        </Box>
                      </Stack.Item>
                    );
                  }
                  const objective = activeObjectives[index];
                  return (
                    <Stack.Item
                      key={index}
                      grow
                    >
                      {ObjectiveFunction(
                        objective,
                        true,
                        handleObjectiveAction
                      )}
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Potential Objectives"
              textAlign="center"
              fill
              scrollable
            >
              <Flex wrap="wrap" justify="space-evenly">
                {potentialObjectives.map(objective => {
                  if (objective === draggingObjective) {
                    return;
                  }
                  return (
                    <Flex.Item
                      key={objective.id}
                      textAlign="left"
                      basis="49%"
                      mb={1}
                      mx="0.5%"
                      onMouseDown={(event) => {
                        this.handleObjectiveClick(event, objective);
                      }}
                    >
                      {ObjectiveFunction(
                        objective,
                        false
                      )}
                    </Flex.Item>
                  );
                })}
              </Flex>
            </Section>
          </Stack.Item>
        </Stack>
        {!!draggingObjective && (
          <Box
            width="200px"
            height="200px"
            position="absolute"
            left={`${objectiveX - 100}px`}
            top={`${objectiveY}px`}
            style={{
              "pointer-events": "none",
            }}
          >
            {ObjectiveFunction(draggingObjective, false)}
          </Box>
        )}
      </>
    );
  }
}

const ObjectiveFunction = (
  objective: Objective,
  active: boolean,
  handleObjectiveAction?: (objective: Objective, action: string) => void
) => {
  const reputation = getReputation(objective.progression_minimum);
  return (
    <ObjectiveElement
      name={objective.name}
      description={objective.description}
      reputation={reputation}
      telecrystalReward={objective.telecrystal_reward}
      progressionReward={objective.progression_reward}
      uiButtons={
        active && handleObjectiveAction
          ? (
            <Stack width="100%" justify="center">
              {objective.ui_buttons?.map((value, index) => (
                <Stack.Item key={index}>
                  <Button
                    content={value.name}
                    icon={value.icon}
                    tooltip={value.tooltip}
                    className={reputation.gradient}
                    onClick={() => {
                      handleObjectiveAction(objective, value.action);
                    }}
                  />
                </Stack.Item>
              ))}
            </Stack>
          )
          : undefined
      }

    />
  );
};

type ObjectiveElementProps = {
  name: string;
  reputation: Rank;
  description: string;
  telecrystalReward: number;
  progressionReward: number;
  uiButtons?: JSX.Element;
}

const ObjectiveElement = (props: ObjectiveElementProps, context) => {
  const {
    name,
    reputation,
    description,
    uiButtons = null,
    telecrystalReward,
    progressionReward,
    ...rest
  } = props;

  return (
    <Box {...rest}>
      <Box
        className={classes([
          "UplinkObjective__Titlebar",
          reputation.gradient,
        ])}
      >
        {name}
      </Box>
      <Box
        className="UplinkObjective__Content"
      >
        <Stack vertical>
          <Stack.Item>
            <Box>
              {description}
            </Box>
          </Stack.Item>
        </Stack>
      </Box>
      <Box
        className="UplinkObjective__Footer"
      >
        <Stack vertical>
          <Stack.Item>
            <Stack align="center" justify="center">
              <Box
                style={{
                  "border": "2px solid rgba(0, 0, 0, 0.5)",
                  "border-left": "none",
                  "border-right": "none",
                }}
                className={reputation.gradient}
                py={0.5}
                width="100%"
                textAlign="center"
              >
                {telecrystalReward} TC,
                <Box ml={1} as="span">
                  {calculateProgression(progressionReward)} Reputation
                </Box>
              </Box>
            </Stack>
          </Stack.Item>
          {!!uiButtons && (
            <Stack.Item>
              {uiButtons}
            </Stack.Item>
          )}
        </Stack>
      </Box>
    </Box>
  );
};

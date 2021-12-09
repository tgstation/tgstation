import { classes } from "common/react";
import { Component } from "inferno";
import { Section, Stack, Box, Button, Flex, Tooltip } from "../../components";
import { calculateProgression, getReputation, Rank } from "./calculateReputationLevel";
import { ObjectiveState } from "./constants";

export type Objective = {
  id: number,
  name: string,
  description: string,
  progression_minimum: number,
  progression_reward: number,
  telecrystal_reward: number,
  ui_buttons?: ObjectiveUiButton[],
  objective_state: ObjectiveState,
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
  handleObjectiveCompleted: (objective: Objective) => void;
}

type ObjectiveMenuState = {
  draggingObjective: Objective|null;
  objectiveX: number;
  objectiveY: number;
}

let dragClickTimer = 0;

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
    if (this.state?.draggingObjective) {
      return;
    }
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

      dragClickTimer = Date.now() + 100; // 100 milliseconds
    }
  }

  handleMouseUp(event: MouseEvent) {
    if (dragClickTimer > Date.now()) {
      return;
    }

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
      handleObjectiveCompleted,
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
                              Empty Objective, drop objectives here to take them
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
                        handleObjectiveAction,
                        handleObjectiveCompleted,
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
                      {objective !== draggingObjective && ObjectiveFunction(
                        objective,
                        false
                      ) || (
                        <Box
                          style={{
                            "border": "2px dashed black",
                          }}
                          width="100%"
                          height="100%"
                          minHeight="100px"
                        />
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
  handleObjectiveAction?: (objective: Objective, action: string) => void,
  handleCompletion?: (objective: Objective) => void,
) => {
  const reputation = getReputation(objective.progression_minimum);
  return (
    <ObjectiveElement
      name={objective.name}
      description={objective.description}
      reputation={reputation}
      telecrystalReward={objective.telecrystal_reward}
      progressionReward={objective.progression_reward}
      objectiveState={objective.objective_state}
      handleCompletion={(event) => {
        if (handleCompletion) {
          handleCompletion(objective);
        }
      }}
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
  objectiveState: ObjectiveState;

  handleCompletion: (event: MouseEvent) => void;
}

const ObjectiveElement = (props: ObjectiveElementProps, context) => {
  const {
    name,
    reputation,
    description,
    uiButtons = null,
    telecrystalReward,
    progressionReward,
    objectiveState,
    handleCompletion,
    ...rest
  } = props;

  const objectiveFinished
    = objectiveState === ObjectiveState.Completed
    || objectiveState === ObjectiveState.Failed;

  const objectiveFailed = objectiveState === ObjectiveState.Failed;

  return (
    <Box {...rest}>
      <Box
        className={classes([
          "UplinkObjective__Titlebar",
          reputation.gradient,
        ])}
        width="100%"
        position="relative"
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
                  "border-bottom": objectiveFinished? "none" : undefined,
                }}
                className={reputation.gradient}
                py={0.5}
                width="100%"
                textAlign="center"
                position="relative"
              >
                {telecrystalReward} TC,
                <Box ml={1} as="span">
                  {calculateProgression(progressionReward)} Reputation
                </Box>
              </Box>
            </Stack>
            {objectiveFinished? (
              <Tooltip
                content={`Click this to finish this objective.${
                  objectiveFailed? ""
                    : ` You will receive ${telecrystalReward} TC
              and ${progressionReward} Reputation.`
                }`}
              >
                <Button
                  inline
                  className={reputation.gradient}
                  style={{
                    "border-radius": "0",
                    "border": "2px solid rgba(0, 0, 0, 0.5)",
                    "border-left": "none",
                    "border-right": "none",
                  }}
                  width="100%"
                  textAlign="center"
                  bold
                  onClick={handleCompletion}
                >
                  <Box
                    width="100%"
                    height="100%"
                    backgroundColor={objectiveFailed
                      ? "rgba(255, 0, 0, 0.1)"
                      : "rgba(0, 255, 0, 0.1)"}
                    position="absolute"
                    left={0}
                    top={0}
                  />
                  {objectiveFailed? "OBJECTIVE FAILED" : "OBJECTIVE COMPLETE"}
                </Button>
              </Tooltip>
            )
              : null}
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

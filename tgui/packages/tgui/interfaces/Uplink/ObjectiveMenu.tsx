import { Section, Stack } from "../../components";
import { Objective } from './index';

type ObjectiveMenuProps = {
  activeObjectives: Objective[];
  potentialObjectives: Objective[];

  handleStartObjective: (objective: Objective) => void;
  handleObjectiveAction: (objective: Objective, action: string) => void;
}

export const ObjectiveMenu = (props: ObjectiveMenuProps, context) => {
  const {
    activeObjectives,
    potentialObjectives,
    handleObjectiveAction,
    handleStartObjective,
  } = props;
  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Section
            title="Active Objectives"
          >
            {activeObjectives.map(objective => (
              <Stack.Item key={objective.id}>
                {objective.name}
              </Stack.Item>
            ))}
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Section
            title="Potential Objectives"
          >
            {potentialObjectives.map(objective => (
              <Stack.Item key={objective.id}>
                {objective.name}
              </Stack.Item>
            ))}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

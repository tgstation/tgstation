import { Section } from "../../components";
import { Objective } from './index';

type ObjectiveMenuProps = {
  activeObjectives: Objective[];
  potentialObjectives: Objective[];

  handleStartObjective: (index: number) => void;
  handleObjectiveAction: (index: number, action: string) => void;
}

export const ObjectiveMenu = (props: ObjectiveMenuProps, context) => {
  const {
    activeObjectives,
    potentialObjectives,
    handleObjectiveAction,
    handleStartObjective,
  } = props;
  return (
    <Section />
  );
};

import { useBackend } from '../../backend';
import { Stack } from '../../components';
import { OperatorData } from './data';
import { ModulesPane } from './ModulesPane';
import { MechStatPane } from './MechStatPane';

export const OperatorMode = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { left_arm_weapon, right_arm_weapon, mech_view } = data;
  return (
    <Stack fill>
      <Stack.Item grow={1}>
        <MechStatPane />
      </Stack.Item>
      <Stack.Item grow={2}>
        <ModulesPane />
      </Stack.Item>
    </Stack>
  );
};

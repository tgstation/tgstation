import { useBackend } from '../../backend';
import { Stack, Section } from '../../components';
import { OperatorData } from './data';
import { RadioPane } from './RadioPane';
import { AlertPane } from './AlertPane';
import { ModulesPane } from './ModulesPane';
import { MechStatPane } from './MechStatPane';
import { UtilityModulesPane } from './UtilityModulesPane';
import { PowerModulesPane } from './PowerModulesPane';
import { ArmPane } from './ArmPane';

export const OperatorMode = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { left_arm_weapon, right_arm_weapon, mech_view } = data;
  return (
    <Stack fill>
      <Stack.Item width="200px">
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill>
              <MechStatPane />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <ModulesPane />
      </Stack.Item>
      <Stack.Item width="200px">
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill>
              {left_arm_weapon ? <ArmPane weapon={left_arm_weapon} /> : null}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Power Modules">
              <PowerModulesPane />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Alerts">
              <AlertPane />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item width="200px">
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill>
              {right_arm_weapon ? <ArmPane weapon={right_arm_weapon} /> : null}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Utility Modules">
              <UtilityModulesPane />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Radio Control">
              <RadioPane />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

import { useBackend } from '../../backend';
import { ByondUi, Stack, Section } from '../../components';
import { OperatorData } from './data';
import { RadioPane } from './RadioPane';
import { AlertPane } from './AlertPane';
import { MechStatPane } from './MechStatPane';
import { ArmorPane } from './ArmorPane';
import { UtilityModulesPane } from './UtilityModulesPane';
import { PowerModulesPane } from './PowerModulesPane';
import { ArmPane } from './ArmPane';

export const OperatorMode = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { left_arm_weapon, right_arm_weapon, mech_view } = data;
  return (
    <Stack fill>
      <Stack.Item grow>
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
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <ByondUi
              height="170px"
              params={{
                id: mech_view,
                zoom: 5,
                type: 'map',
              }}
            />
          </Stack.Item>
          <Stack.Item>
            <Section title="Armor modules">
              <ArmorPane />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
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
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill>
              <MechStatPane />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

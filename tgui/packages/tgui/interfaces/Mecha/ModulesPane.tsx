import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
import { OperatorData } from './data';

const moduleIcon = (param) => {
  switch (param) {
    case 'mecha_l_arm':
      return 'hand';
    case 'mecha_r_arm':
      return 'hand';
    case 'mecha_utility':
      return 'screwdriver-wrench';
    case 'mecha_power':
      return 'bolt';
    case 'mecha_armor':
      return 'shield-halved';
    default:
      return 'screwdriver-wrench';
  }
};

const emptyModuleText = (param) => {
  switch (param) {
    case 'mecha_l_arm':
      return 'Left Arm Slot';
    case 'mecha_r_arm':
      return 'Right Arm Slot';
    case 'mecha_utility':
      return 'Utility Module Slot';
    case 'mecha_power':
      return 'Power Module Slot';
    case 'mecha_armor':
      return 'Armor Module Slot';
    default:
      return 'Module Slot';
  }
};

export const ModulesPane = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { mech_electronics, airtank_present, modules } = data;
  return (
    <Section title="Equipment" fill>
      {modules.map((module) =>
        !module.ref ? (
          <Button
            p={1}
            fluid
            icon={moduleIcon(module.type)}
            key={module.ref}
            color="transparent">
            {emptyModuleText(module.type)}
          </Button>
        ) : (
          <Button
            p={1}
            fluid
            icon={moduleIcon(module.type)}
            key={module.ref}
            style={{ 'text-transform': 'capitalize' }}>
            {/* <Box className={classes(['mecha_equipment32x32', module.icon])} /> */}
            {module.name}
          </Button>
        )
      )}
      {!mech_electronics || (
        <Button p={1} fluid icon="tower-cell" content="Radio" />
      )}
      {!airtank_present || <Button p={1} fluid icon="fan" content="Air Tank" />}
    </Section>
  );
};

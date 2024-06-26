import { useBackend } from '../backend';
import { Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  target_name: string;
  physics_flags: number;
  angle: number;
  horizontal_velocity: number;
  vertical_velocity: number;
  horizontal_friction: number;
  vertical_friction: number;
  horizontal_conservation_of_momentum: number;
  vertical_conservation_of_momentum: number;
  z_floor: number;
  visual_angle_velocity: number;
  visual_angle_friction: number;
  spin_speed: number;
  spin_loops: number;
  spin_clockwise: number;
  bounce_spin_speed: number;
  bounce_spin_loops: number;
  bounce_spin_clockwise: number;
  bounce_sound: string;
};

type VariableButtonProps = {
  label: any;
  variable: any;
  value: any;
};

const VariableItem = (props: VariableButtonProps) => {
  const { act } = useBackend<Data>();
  const { label, variable, value } = props;

  return (
    <LabeledList.Item label={label}>
      <Button onClick={() => act('edit_variable', { variable: variable })}>
        {value !== null ? value : 'NULL'}
      </Button>
    </LabeledList.Item>
  );
};

export const MovablePhysicsTester = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    target_name,
    physics_flags,
    angle,
    horizontal_velocity,
    vertical_velocity,
    horizontal_friction,
    vertical_friction,
    horizontal_conservation_of_momentum,
    vertical_conservation_of_momentum,
    z_floor,
    visual_angle_velocity,
    visual_angle_friction,
    spin_speed,
    spin_loops,
    spin_clockwise,
    bounce_spin_speed,
    bounce_spin_loops,
    bounce_spin_clockwise,
    bounce_sound,
  } = data;

  const variableItems = [
    ['Physics Flags', 'physics_flags', physics_flags],
    ['Angle', 'angle', angle],
    ['Horizontal Velocity', 'horizontal_velocity', horizontal_velocity],
    ['Vertical Velocity', 'vertical_velocity', vertical_velocity],
    ['Horizontal Friction', 'horizontal_friction', horizontal_friction],
    ['Vertical Friction', 'vertical_friction', vertical_friction],
    [
      'Horizontal Conservation of Momentum',
      'horizontal_conservation_of_momentum',
      horizontal_conservation_of_momentum,
    ],
    [
      'Vertical Conservation of Momentum',
      'vertical_conservation_of_momentum',
      vertical_conservation_of_momentum,
    ],
    ['Z Floor', 'z_floor', z_floor],
    ['Visual Angle Velocity', 'visual_angle_velocity', visual_angle_velocity],
    ['Visual Angle Friction', 'visual_angle_friction', visual_angle_friction],
    ['Spin Speed', 'spin_speed', spin_speed],
    ['Spin Loops', 'spin_loops', spin_loops],
    ['Spin Clockwise', 'spin_clockwise', spin_clockwise],
    ['Bounce Spin Speed', 'bounce_spin_speed', bounce_spin_speed],
    ['Bounce Spin Loops', 'bounce_spin_loops', bounce_spin_loops],
    ['Bounce Spin Clockwise', 'bounce_spin_clockwise', bounce_spin_clockwise],
    ['Bounce Sound', 'bounce_sound', bounce_sound],
  ];

  return (
    <Window title="Movable Physics Tester" width={400} height={600}>
      <Window.Content>
        <Section fill title={target_name}>
          <Stack vertical>
            <Stack.Item>
              <LabeledList>
                {variableItems.map((item) => (
                  <VariableItem
                    key={item[1]}
                    label={item[0]}
                    variable={item[1]}
                    value={item[2]}
                  />
                ))}
              </LabeledList>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  <Button
                    width="100%"
                    height="100%"
                    color={!(physics_flags & 2) ? 'bad' : 'good'}
                    onClick={() => act('pause')}
                  >
                    {!(physics_flags & 2) ? 'Paused' : 'Running'}
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    width="100%"
                    height="100%"
                    onClick={() => act('physics_chungus_deluxe')}
                  >
                    PCD
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

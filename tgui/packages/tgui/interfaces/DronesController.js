import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Modal, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const DronesController = (props, context) => {
  const { act, data } = useBackend(context);
  const drones = data.drones || [];

  return (
    <Window
      width={500}
      height={400}>
      <Window.Content scrollable>
        {drones.map(drone => (
          <Section title={drone.name+" "+drone.coord}>
            <LabeledList>
              <LabeledList.Item>
                <Button
                  key={drone.drone_id}
                  content={'Connect'}
                  color={"green"}
                  onClick={() => act('connect', {
                    drone_id: drone.drone_id,
                  })} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
          ))}
      </Window.Content>
    </Window>
  );
};

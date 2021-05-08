import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Modal, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const DrillsController = (props, context) => {
  const { act, data } = useBackend(context);
  const onlineDrills = data.online_drills || [];

  return (
    <Window
      width={500}
      height={400}>
      <Window.Content>
        <Section>
          {onlineDrills.map(drill => (
            <LabeledList>
              <LabeledList.Item>
                <Box>
                  drill.name
                  drill.coord
                </Box>
              </LabeledList.Item>
            </LabeledList>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

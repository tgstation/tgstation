import { multiline } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section, Tabs } from '../components';

export const NtosRoboControl = props => {
  const { act, data } = useBackend(props);
  const bots = data.bots || [];
  return (
    <Section
      title="Robot Control Console">
      <Box>
        Bots detected in range:{data.botcount} 
      </Box>
      <Section>
        {bots.map(robot => (
          <Box
            key={robot.name}
            backgroundColor="#3b3578">
            <Section
              title={robot.name}>
              <Box>
                Model: {robot.model}
              </Box>
              <Box>
                Location: {robot.locat}
              </Box>
              <Box>
                Status: {robot.mode}
              </Box>
            </Section>
            {robot.mule_check === 1 && (
              <Box>
                Creeper? Aww man.
              </Box>
            )}
            <Box m={1} />
            {robot.mule_check === 0 && (
              <Box>
                <Button
                  content="Stop Patrol"
                  color="black"
                  onClick={() => act('patroloff', {
                    robot: robot.bot_ref,
                  })} />
                <Button
                  content="Start Patrol"
                  color="black"
                  onClick={() => act('patrolon', {
                    robot: robot.bot_ref,
                  })} />
                <Button
                  content="Summon"
                  color="black"
                  onClick={() => act('summon', {
                    robot: robot.bot_ref,
                  })} />
                <Button
                  content="Eject PAi"
                  color="black"
                  onClick={() => act('ejectpai', {
                    robot: robot.bot_ref,
                  })} />
              </Box>
            )}
          </Box>
        ))}
		
      </Section>
    </Section>
  );
};

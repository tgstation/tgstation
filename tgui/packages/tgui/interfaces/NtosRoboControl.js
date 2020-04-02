import { multiline } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section, Tabs } from '../components';

export const NtosRoboControl = props => {
  const { act, data } = useBackend(props);
  const bots = data.bots || [];
  const mules = data.mules || [];
  return (
    <Section
      title="Robot Control Console"
      buttons={(
        <Button
          content="Eject ID"
          onClick={() => act('ejectcard')} 
        />
      )}>
      <Box>
        Bots detected in range: {data.botcount} 
		
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
            {robot.mule_check === 1 &&(
              mules.map(mulebot => (
                {(robot.bot_ref === mulebot.mule_ref) &&(
				<Box
                  key={mulebot.mule_ref}
                  backgroundColor="#a87b32">
                  <Button
                    content="Stop"
                    onClick={() => act('stop', {
                      robot: mulebot.mule_ref,
                    })} />
                  <Button
                    content="Go"
                    onClick={() => act('go', {
                      robot: mulebot.mule_ref,
                    })} />
                  <Button
                    content="Home"
                    onClick={() => act('home', {
                      robot: mulebot.mule_ref,
                    })} />
                  <Button
                    content="To Destination"
                    onClick={() => act('destination', {
                      robot: mulebot.mule_ref,
                    })} />
                  <Button
                    content="Set ID"
                    onClick={() => act('setid', {
                      robot: mulebot.mule_ref,
                    })} />
                  <Button
                    content="Set Home"
                    onClick={() => act('sethome', {
                      robot: mulebot.mule_ref,
                    })} />
                  <Button
                    content="Unload Cargo"
                    onClick={() => act('unload', {
                      robot: mulebot.mule_ref,
                    })} />
                  <Button
                    content="Toggle Auto Return"
                    onClick={() => act('autoret', {
                      robot: mulebot.mule_ref,
                    })} />
                  <Button
                    content="Toggle Auto Pickup"
                    onClick={() => act('autopick', {
                      robot: mulebot.mule_ref,
                    })} />
                  <Button
                    content="Report"
                    onClick={() => act('report', {
                      robot: mulebot.mule_ref,
                    })} />
                </Box>
				)}
              ))
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

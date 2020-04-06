import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, LabeledList, ProgressBar, Section, Tabs } from '../components';

export const NtosRoboControl = props => {
  const { act, data } = useBackend(props);
  const bots = data.bots || [];
  const mules = data.mules || [];
  const { autoReturn,
    autoPickup,
    reportDelivery = [],
  } = data;
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
        Id Card: {data.id_owner}
      </Box>
      <Box>
        Bots detected in range: {data.botcount}
      </Box>
      <Section>
        {bots.map(robot => (
          <Grid
            key={robot.name}>
            <Grid.Column>
              <Box
                backgroundColor={robot.mule_check === 1? "#6e4b0e" : "#342963"}
                m={1}>
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
                  {robot.mule_check === 1 &&(
                    mules.map(mulebot => (
                      (robot.bot_ref === mulebot.mule_ref) &&(
                        <Section
                          key={mulebot.mule_ref}>
                          <Box>
                            Loaded Cargo: {data.load ? (data.load) : "N/A"}
                          </Box>
                          <Box>
                            Home: {mulebot.home}
                          </Box>
                          <Box>
                            Destination: {mulebot.dest ? mulebot.dest: "N/A"}
                          </Box>
                          <ProgressBar
                            value={mulebot.power}
                            minValue={0}
                            maxValue={100}
                            ranges={{
                              good: [60, Infinity],
                              average: [20, 59],
                              bad: [-Infinity, 19],
                            }}>
                            Power at {mulebot.power}%
                          </ProgressBar>
                        </Section>
                      ))))}
                </Section>
              </Box>
            </Grid.Column>
            <Grid.Column>
              <Box m={1}>
                {robot.mule_check === 1 &&(
                  mules.map(mulebot => (
                    (robot.bot_ref === mulebot.mule_ref) &&(
                      <Box
                        key={mulebot.mule_ref}
                        textAlign="center">
                        <Button
                          tooltip="Stop Moving."
                          icon="pause"
                          onClick={() => act('stop', {
                            robot: mulebot.mule_ref,
                          })} />
                        <Button
                          tooltip="Go to Destination."
                          icon="play"
                          onClick={() => act('go', {
                            robot: mulebot.mule_ref,
                          })} />
                        <Button
                          icon="home"
                          tooltip="Travel Home."
                          onClick={() => act('home', {
                            robot: mulebot.mule_ref,
                          })} />
                        <Button
                          content="Set Destination"
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
                        <Button.Checkbox
                          content="Toggle Auto Return"
                          checked={mulebot.autoReturn ? true : false}
                          onClick={() => act('autoret', {
                            robot: mulebot.mule_ref,
                          })} />
                        <Button.Checkbox
                          content="Toggle Auto Pickup"
                          checked={mulebot.autoPickup ? true : false}
                          onClick={() => act('autopick', {
                            robot: mulebot.mule_ref,
                          })} />
                        <Button.Checkbox
                          content="Toggle Delivery Report"
                          checked={mulebot.reportDelivery ? true : false}
                          onClick={() => act('report', {
                            robot: mulebot.mule_ref,
                          })} />
                      </Box>
                    )
                  ))
                )}
                <Box />
                {robot.mule_check === 0 && (
                  <Box
                    textAlign="center">
                    <Button
                      content="Stop Patrol"
                      onClick={() => act('patroloff', {
                        robot: robot.bot_ref,
                      })} />
                    <Button
                      content="Start Patrol"
                      onClick={() => act('patrolon', {
                        robot: robot.bot_ref,
                      })} />
                    <Button
                      content="Summon"
                      onClick={() => act('summon', {
                        robot: robot.bot_ref,
                      })} />
                    <Button
                      content="Eject PAi"
                      onClick={() => act('ejectpai', {
                        robot: robot.bot_ref,
                      })} />
                  </Box>
                )}
              </Box>
            </Grid.Column>
          </Grid>
        ))}

      </Section>
    </Section>
  );
};

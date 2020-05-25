import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, LabeledList, ProgressBar, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosArcade = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <NtosWindow>
      <NtosWindow.Content>
        <Section
          title="Outbomb Cuban Pete Ultra"
          textAlign="center">
          <Box>
            <Grid>
              <Grid.Column size={2}>
                <Box m={1} />
                <LabeledList>
                  <LabeledList.Item
                    label="Player Health">
                    <ProgressBar
                      value={data.PlayerHitpoints}
                      minValue={0}
                      maxValue={30}
                      ranges={{
                        olive: [31, Infinity],
                        good: [20, 31],
                        average: [10, 20],
                        bad: [-Infinity, 10],
                      }}>
                      {data.PlayerHitpoints}HP
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Player Magic">
                    <ProgressBar
                      value={data.PlayerMP}
                      minValue={0}
                      maxValue={10}
                      ranges={{
                        purple: [11, Infinity],
                        violet: [3, 11],
                        bad: [-Infinity, 3],
                      }}>
                      {data.PlayerMP}MP
                    </ProgressBar>
                  </LabeledList.Item>
                </LabeledList>
                <Box my={1} mx={4} />
                <Section
                  backgroundColor={
                    data.PauseState === 1 ? "#1b3622" : "#471915"
                  }>
                  {data.Status}
                </Section>
              </Grid.Column>
              <Grid.Column>
                <ProgressBar
                  value={data.Hitpoints}
                  minValue={0}
                  maxValue={45}
                  ranges={{
                    good: [30, Infinity],
                    average: [5, 30],
                    bad: [-Infinity, 5],
                  }}>
                  <AnimatedNumber value={data.Hitpoints} />
                  HP
                </ProgressBar>
                <Box m={1} />
                <Section
                  inline
                  width="156px"
                  textAlign="center">
                  <img src={data.BossID} />
                </Section>
              </Grid.Column>
            </Grid>
            <Box my={1} mx={4} />
            <Button
              icon="fist-raised"
              tooltip="Go in for the kill!"
              tooltipPosition="top"
              disabled={data.GameActive === 0 || data.PauseState === 1}
              onClick={() => act('Attack')}
              content="Attack!" />
            <Button
              icon="band-aid"
              tooltip="Heal yourself!"
              tooltipPosition="top"
              disabled={data.GameActive === 0 || data.PauseState === 1}
              onClick={() => act('Heal')}
              content="Heal!" />
            <Button
              icon="magic"
              tooltip="Recharge your magic!"
              tooltipPosition="top"
              disabled={data.GameActive === 0 || data.PauseState === 1}
              onClick={() => act('Recharge_Power')}
              content="Recharge!" />
          </Box>
          <Box>
            <Button
              icon="sync-alt"
              tooltip="One more game couldn't hurt."
              tooltipPosition="top"
              disabled={data.GameActive === 1}
              onClick={() => act('Start_Game')}
              content="Begin Game" />
            <Button
              icon="ticket-alt"
              tooltip="Claim at your local Arcade Computer for Prizes!"
              tooltipPosition="top"
              disabled={data.GameActive === 1}
              onClick={() => act('Dispense_Tickets')}
              content="Claim Tickets" />
          </Box>
          <Box color={data.TicketCount >= 1 ? 'good' : 'normal'}>
            Earned Tickets: {data.TicketCount}
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

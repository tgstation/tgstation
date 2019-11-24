import { act } from '../byond';
import { Component, Fragment } from 'inferno';
import { Box, Button, Chart, ColorBox, Flex, Icon, LabeledList, ProgressBar, Section, Table } from '../components';

export const NtosArcade = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
 
  return (
    <Section title="Outbomb Cuban Pete Ultra"
      textAlign="center">
      <Box>
        <Section>
          <img
            src={data.BossID} />
        </Section>
        <LabeledList>
          <LabeledList.Item 
            color={(data.Hitpoints <= 5) ? "bad" : data.Hitpoints >= 30 ? "good" : "average"}
            label="Boss Health">
            {data.Hitpoints}
          </LabeledList.Item>
          <LabeledList.Item 
            color={(data.PlayerHitpoints <= 10) ? "bad" : data.Hitpoints >= 20 ? "good" : "average"}
            label="Player Health">
            {data.PlayerHitpoints}
          </LabeledList.Item>
          <LabeledList.Item 
            color="purple"
            label="Player Magic">
            {data.PlayerMP}
          </LabeledList.Item>
          <LabeledList.Item label="Status">
            <Section>
              {data.Status}
            </Section>
          </LabeledList.Item>
          <LabeledList.Item label="Earned Tickets"
            color={data.TicketCount >= 1 ? "good" : "normal"}>
            {data.TicketCount}
          </LabeledList.Item>
        </LabeledList>
        <Button
          icon="fist-raised"
          tooltip="Go in for the kill!"
          tooltipPosition="top"
          disabled={data.GameActive === 0 || data.PauseState === 1}
          onClick={() => act(ref, 'Attack')}
          content="Attack!" />
        <Button
          icon="band-aid"
          tooltip="Heal yourself!"
          tooltipPosition="top"
          disabled={data.GameActive === 0 || data.PauseState === 1}
          onClick={() => act(ref, 'Heal')}
          content="Heal!" />
        <Button
          icon="magic"
          tooltip="Recharge your magic!"
          tooltipPosition="top"
          disabled={data.GameActive === 0 || data.PauseState === 1}
          onClick={() => act(ref, 'Recharge_Power')}
          content="Recharge!" />
      </Box>
      <Box>
        <Button
          icon="sync-alt"
          tooltip="One more game couldn't hurt."
          tooltipPosition="top"
          disabled={data.GameActive === 1}
          onClick={() => act(ref, 'Start_Game')}
          content="Begin Game?" />
        <Button
          icon="ticket-alt"
          tooltip="Redeem your arcade tickets! (Claim at your local Arcade Computer for Prizes!)"
          tooltipPosition="top"
          disabled={data.GameActive === 1}
          onClick={() => act(ref, 'Dispense_Tickets')}
          content="Claim Tickets" />
      </Box>
    </Section>
  );
};
import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

export const AntagInfoVenom = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={430} height={400} theme="spookyconsole">
      <Window.Content>
        <Section fill>
          <Stack vertical fill textAlign="center">
            <Stack.Item fontSize="12px">
              You are a <b>sentient alien lifeform</b> that landed on a space
              station.
            </Stack.Item>
            <Stack.Item fontSize="15px">
              Your goals are to end everyone. You require a <b>host</b> to do
              that.
            </Stack.Item>
            <Stack.Item fontSize="12px">
              Your <b>host</b> requires a MODsuit for you to hook into. You are
              able to speak, and you have came out of a breach causing meteor,
              So you could try asking an engineer to fix it.
            </Stack.Item>
            <Stack.Item fontSize="12px">
              After hooking onto someone, their MODsuit gets major upgrades and
              deadly abilities. One of those is the <b>piercer</b>, which they
              must use on corpses of <i>crewmembers</i>. After a short process,
              the piercer absorbs their energy which increases your <b>power</b>
              .
            </Stack.Item>
            <Stack.Item fontSize="12px">
              Their other abilities also passively heal them, shorten their
              status effects and give them a tentacle they may use to move
              around and attack from range, all of the abilities increase in
              strength as your <b>power</b> grows.
            </Stack.Item>
            <Stack.Item fontSize="12px">
              You can talk directly to your host with <b>Telepathy</b>, and as
              you gain <b>power</b>, your <b>Mind Control</b> length increases,
              going from 1 second at the start, to 2, 4, 8, 16, 32, 64, etc.
              Using Mind Control to initiate conflict is great if your host is
              advert to it. The strength of your abilities is also stronger
              under your direct control.
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

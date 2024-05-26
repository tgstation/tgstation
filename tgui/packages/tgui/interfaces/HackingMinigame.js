import { useBackend } from '../backend';
import { Button, Stack, Section, LabeledList, Box, BlockQuote, ProgressBar } from '../components';
import { Window } from '../layouts';

export const HackingMinigame = (props, context) => {
  const { act, data } = useBackend(context);
  const { hacked, holder_name, hacking_name, current_hacking_action } = data;
  return (
    <Window
      title={hacking_name ? hacking_name + ' Hacking' : 'Unknown Hacking'}
      width={400}
      height={500}>
      <Window.Content>
        <Stack vertical width="100%" height="100%">
          <Stack.Item>
            <Box className={hacked ? 'Namebox__Hacked' : 'Namebox'}>
              {holder_name}
            </Box>
          </Stack.Item>
          {(current_hacking_action && (
            <Stack.Item>
              <HackingMenu />
            </Stack.Item>
          )) || (
            <Stack.Item>
              <ActionsMenu />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ActionsMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hacking_actions = [],
    holder_attack,
    holder_health,
    holder_defense,
  } = data;
  return (
    <Stack vertical={false}>
      <Stack.Item width="50%">
        <Section height="100%" title={<Box textAlign="center">Actions</Box>}>
          <Stack vertical textAlign="center">
            {hacking_actions.map((action) => (
              <Stack.Item key={action} mb={0.5}>
                <Button
                  width="75%"
                  icon="bug"
                  onClick={() =>
                    act('start_hacking', {
                      hacking_action: action,
                    })
                  }
                  style={{
                    'font-size': '140%',
                  }}>
                  {action}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item width="50%">
        <Section height="100%" title={<Box textAlign="center">Defender</Box>}>
          <LabeledList>
            <LabeledList.Item label="Attack">{holder_attack}</LabeledList.Item>
            <LabeledList.Item label="Health">{holder_health}</LabeledList.Item>
            <LabeledList.Item label="Defense">
              {holder_defense}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const HackingMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_hacking_action } = data;
  return (
    <Stack vertical>
      <Stack.Item>
        <BlockQuote
          style={{
            'font-weight': 'bold',
            'font-size': '150%',
          }}>
          Current Hack: {current_hacking_action}
        </BlockQuote>
      </Stack.Item>
      <Stack.Item>
        <Stack vertical={false}>
          <HackerInfo />
          <HolderInfo />
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section title={<Box textAlign="center">Options</Box>}>
          <Stack vertical>
            <HackingAttack icon="skull" attack_type="Attack" />
            <HackingAttack icon="mask" attack_type="Mask" />
            <HackingAttack icon="shield-slash" attack_type="Scan" />
            <HackingAttack icon="shield" attack_type="Shield" />
            <HackingAttack icon="bolt" attack_type="Overflow" />
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const HackerInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hacker_cooldown,
    hacker_attack,
    hacker_health,
    hacker_defense,
    hacker_last_attack,
  } = data;
  return (
    <Stack.Item>
      <Section title={<Box textAlign="center">Hacker</Box>}>
        <LabeledList>
          <LabeledList.Item label="Attack">{hacker_attack}</LabeledList.Item>
          <LabeledList.Item label="Health">{hacker_health}</LabeledList.Item>
          <LabeledList.Item label="Defense">{hacker_defense}</LabeledList.Item>
          <LabeledList.Item label="Last Attack">
            {hacker_last_attack}
          </LabeledList.Item>
          <LabeledList.Item label="Cooldown">
            <ProgressBar
              value={hacker_cooldown}
              minValue={0}
              maxValue={100}
              color="good">
              {hacker_cooldown}%
            </ProgressBar>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const HolderInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    holder_cooldown,
    holder_attack,
    holder_health,
    holder_defense,
    holder_last_attack,
  } = data;
  return (
    <Stack.Item>
      <Section title={<Box textAlign="center">Defender</Box>}>
        <LabeledList>
          <LabeledList.Item label="Attack">{holder_attack}</LabeledList.Item>
          <LabeledList.Item label="Health">{holder_health}</LabeledList.Item>
          <LabeledList.Item label="Defense">{holder_defense}</LabeledList.Item>
          <LabeledList.Item label="Last Attack">
            {holder_last_attack}
          </LabeledList.Item>
          <LabeledList.Item label="Cooldown">
            <ProgressBar
              value={holder_cooldown}
              minValue={0}
              maxValue={100}
              color="bad">
              {holder_cooldown}%
            </ProgressBar>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const HackingAttack = (props, context) => {
  const { act, data } = useBackend(context);
  const { attack_type, icon } = props;
  return (
    <Stack.Item textAlign="center" mb={0.5}>
      <Button
        width="50%"
        icon={icon}
        onClick={() =>
          act('do_attack', {
            hacking_attack: attack_type,
          })
        }
        style={{
          'font-size': '140%',
        }}>
        {attack_type}
      </Button>
    </Stack.Item>
  );
};

import { useBackend } from '../backend';
import { BlockQuote, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

type Info = {
  antag_name: string;
  gang_name: string;
  gang_objective: string;
  gang_clothes: string[];
};

export const AntagInfoGangmember = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { gang_name, antag_name } = data;
  return (
    <Window width={620} height={500}>
      <Window.Content
        style={{
          'background-image': 'none',
        }}>
        <Section fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              {gang_name} for life! You are a {antag_name}!
            </Stack.Item>
            <Stack.Item fontSize="18px">
              As a gang member, support your family above all! Tag turf with a
              spraycan, wear your family&apos;s clothes, induct new members with
              induction packages, and accomplish your family objective.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow basis={0}>
                  <GangClothesPrintout />
                </Stack.Item>
                <Stack.Item grow basis={0}>
                  <GangPhonePrintout />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item grow basis={0}>
              <GangObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const GangClothesPrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { gang_name, gang_clothes } = data;
  return (
    <Stack vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item mt={0.5} mb={1}>
            <Icon size={2} name="tshirt" />
          </Stack.Item>
          <Stack.Item bold>
            Wear the following to represent the {gang_name}:
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <BlockQuote>
        {gang_clothes && gang_clothes.length
          ? gang_clothes.map((clothes_item) => (
            <Stack.Item key={clothes_item}>- {clothes_item}</Stack.Item>
          ))
          : '- Anything!'}
      </BlockQuote>
    </Stack>
  );
};

const GangPhonePrintout = () => {
  return (
    <Stack vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item mt={0.5}>
            <Icon size={2} name="phone" />
          </Stack.Item>
          <Stack.Item bold>
            You were given a cell phone with your induction package!
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <BlockQuote>
          Use it in hand to activate it, then speak into it to talk with your
          other family members.
        </BlockQuote>
      </Stack.Item>
    </Stack>
  );
};

const GangObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { gang_objective } = data;
  return (
    <Stack vertical>
      <Stack.Item bold fontSize="16px">
        Your family&apos;s goal:
      </Stack.Item>
      <Stack.Item>
        {gang_objective || 'No objective set! This is a problem!'}
      </Stack.Item>
    </Stack>
  );
};

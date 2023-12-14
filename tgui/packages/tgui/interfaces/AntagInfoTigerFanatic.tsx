import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';
import { ObjectivePrintout, Objective } from './common/Objectives';

const absorbstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const hivemindstyle = {
  color: 'violet',
  fontWeight: 'bold',
};

const transformstyle = {
  color: 'orange',
  fontWeight: 'bold',
};

type Info = {
  objectives: Objective[];
};

export const AntagInfoTigerFanatic = (props) => {
  return (
    <Window width={540} height={510}>
      <Window.Content
        style={{
          'backgroundImage': 'none',
        }}>
        <Stack vertical fill>
          <Stack.Item>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow={4}>
            <AbilitiesSection />
          </Stack.Item>
          <Stack.Item grow={2}>
            <AscensionSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AscensionSection = (props) => {
  return (
    <Section fill title="Ascension">
      <Stack vertical fill>
        <Stack.Item textColor="label">
          To be assimilated is to serve the
          <span style={hivemindstyle}>&ensp;Hive</span>, and is the path towards
          eternal life. You must be
          <span style={absorbstyle}>&ensp;absorbed</span> by your changeling
          idols in order to forever be one with the
          <span style={hivemindstyle}>&ensp;Hive.</span>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const IntroductionSection = (props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Section
      fill
      title="Intro"
      scrollable={!!objectives && objectives.length > 4}>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          You are the Tiger Cooperative Fanatic
        </Stack.Item>
        <Stack.Item>
          <ObjectivePrintout objectives={objectives} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = (props) => {
  return (
    <Section fill title="Abilities">
      <Stack fill>
        <Stack.Item basis={0} grow>
          <Stack fill vertical>
            <Stack.Item basis={0} textColor="label" grow>
              Through many rituals, psychedelic induced comas, and scarification
              you have managed to forge a weak connection to the
              <span style={hivemindstyle}>&ensp;changeling hivemind. </span>
              You can speak over the hivemind by using
              <span style={absorbstyle}>&ensp;:g</span>. Contact the
              <span style={absorbstyle}>holy ones</span> so you may humbly serve
              them.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item basis={0} textColor="label" grow>
              Your body has been
              <span style={transformstyle}>adapted</span> to best receive the
              blessings from the changelings. Their holy abilities will work
              wonders on your mortal flesh. Be
              <span style={absorbstyle}>&ensp;stung</span> by them to receive
              blessings of health, enlightenment, and strength. Listen to their
              screams and be filled with vigor.
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

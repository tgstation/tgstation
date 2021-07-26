import { multiline } from 'common/string';
import { url } from 'node:inspector';
import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Button, Dimmer, Modal, Section, Stack } from '../components';
import { Window } from '../layouts';

const hivestyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const absorbstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const revivestyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

const transformstyle = {
  color: 'orange',
  fontWeight: 'bold',
};

const storestyle = {
  color: 'green',
  fontWeight: 'bold',
};

type Objective = {
  count: number;
  name: string;
  explanation: string;
}

type Info = {
  hive_name: string;
  stolen_antag_info: string;
  memories: string[];
  objectives: Objective[];
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    objectives,
  } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>
        Your current objectives:
      </Stack.Item>
      <Stack.Item>
        {!objectives && "None!"
        || objectives.map(objective => (
          <Stack.Item key={objective.count}>
            #{objective.count}: {objective.explanation}
          </Stack.Item>
        )) }
      </Stack.Item>
    </Stack>
  );
};

const IntroductionSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    hive_name,
    objectives,
  } = data;
  return (
    <Section
      fill
      title="Intro"
      scrollable={
        !!objectives && objectives.length > 4
      }>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          You are the Changeling from the
          <span style={hivestyle}>
            &ensp;{hive_name}
          </span>.
        </Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  return (
    <Section fill title="Abilities">
      <Stack mt={-0.5} fill>
        <Stack.Item basis={0} grow>
          <Stack fill vertical>
            <Stack.Item basis={0} textColor="label" grow>
              Your
              <span style={absorbstyle}>
                &ensp;Absorb
              </span> ability
              allows you to steal the DNA and memories of a victim. The
              <span style={absorbstyle}>
                &ensp;Transform Sting
              </span> ability
              does the same instantly and quietly, but doesn&apos;t
              count for objectives, kill them, or
              include their memories and speech patterns.
            </Stack.Item>
            <Stack.Divider mb={-0.7} />
            <Stack.Item basis={0} textColor="label" grow>
              Your
              <span style={revivestyle}>
                &ensp;Reviving Stasis
              </span> ability
              allows you to revive. It means nothing short of a complete body
              destruction can stop you! Obviously, this is loud and
              so should not be done in front of people you are not
              planning on silencing.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item basis={0} grow>
          <Stack fill vertical>
            <Stack.Item basis={0} textColor="label" grow>
              Your
              <span style={transformstyle}>
                &ensp;Transform
              </span> ability
              allows you to change into the form of those you have
              collected DNA from, lethally and nonlethally. It will
              also mimic (NOT REAL CLOTHING) the clothing they were wearing
              for every slot you have open.
            </Stack.Item>
            <Stack.Divider mb={-0.7} />
            <Stack.Item basis={0} textColor="label" grow>
              The
              <span style={storestyle}>
                &ensp;Cellular Emporium
              </span> is
              where you purchase more abilities beyond your starting kit.
              You have 10 genetic points to spend on abilities and you are
              able to readapt after absorbing a body, refunding your points
              for different kits.
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MemoriesSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const {
    memories,
  } = data;
  return (
    <Section
      fill
      scrollable={!!memories[0].length}
      title="Stolen Memories"
      buttons={
        <Button
          icon="info"
          tooltipPosition="left"
          tooltip={multiline`
            Absorbing targets allows
            you to collect their memories. They should
            help you impersonate your target!
          `} />
      }>
      <Stack vertical>
        {!memories[0].length && (
          <Dimmer mr="-100%" bold>
            You need to absorb a victim first!
          </Dimmer>
        ) || memories.map(memory => (
          <Stack.Item key={memory}>
            <Button
              onClick={() => act('read_memory', {
                name: memory,
              })}>
              {memory}
            </Button>
          </Stack.Item>
        )) }
      </Stack>
    </Section>
  );
};

const VictimPatternsSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    stolen_antag_info,
  } = data;
  return (
    <Section
      fill
      scrollable={!!stolen_antag_info}
      title="Additional Stolen Information">
      {!!stolen_antag_info && (
        stolen_antag_info
      )}
    </Section>
  );
};

export const AntagInfoChangeling = (props, context) => {
  const { data } = useBackend<Info>(context);
  return (
    <Window
      width={620}
      height={580}>
      <Window.Content
        style={{
          "backgroundImage": "none",
        }}>
        <Stack vertical fill>
          <Stack.Item maxHeight={13.5} grow>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow>
            <AbilitiesSection />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <MemoriesSection />
              </Stack.Item>
              <Stack.Item grow ml={0} basis={0}>
                <VictimPatternsSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

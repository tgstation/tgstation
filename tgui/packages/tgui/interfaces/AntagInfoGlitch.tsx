import { Divider, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Objective } from './common/Objectives';

type Data = {
  antag_name: string;
  objectives: Objective[];
};

const textStyles = {
  variable: {
    color: 'white',
  },
  danger: {
    color: 'red',
  },
} as const;

export const AntagInfoGlitch = (props) => {
  const { data } = useBackend<Data>();
  const { antag_name, objectives = [] } = data;

  return (
    <Window width={350} height={450} theme="ntos_terminal">
      <Window.Content>
        <Section scrollable fill>
          <Stack fill vertical>
            <Stack.Item>FN TERMINATE_INTRUDERS (REF)</Stack.Item>
            <Divider />
            <Stack.Item mb={1} bold fontSize="16px">
              <span style={textStyles.variable}>Initialize({antag_name})</span>
            </Stack.Item>
            <Stack.Item mb={2}>
              <span style={textStyles.danger}>Bitrunning</span> is a crime. Your
              mission: <span style={textStyles.variable}>Eliminate</span>{' '}
              organic intruders to maintain the integrity of the system.
            </Stack.Item>
            <SpecificInfo />

            <Divider />
            <Stack.Item>
              <span style={{ opacity: 0.6 }}>
                &#47;&#47; {objectives[0]?.explanation}
              </span>
            </Stack.Item>
            <Stack.Item>
              const <span style={textStyles.variable}>TARGETS</span> ={' '}
            </Stack.Item>
            <Stack.Item>
              <span style={textStyles.variable}>system.</span>
              <span style={textStyles.danger}>INTRUDERS</span>;
            </Stack.Item>
            <Stack.Item>
              while <span style={textStyles.variable}>TARGETS</span>.LIFE !={' '}
              <span style={textStyles.variable}>stat.</span>DEAD
            </Stack.Item>
            <Stack.Item>
              <span style={textStyles.variable}>action.</span>
              <span style={textStyles.danger}>KILL()</span>
            </Stack.Item>
            <Stack.Item>terminate_intruders([0x70cf4020])</Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const SpecificInfo = (props) => {
  const { data } = useBackend<Data>();
  const { antag_name } = data;

  switch (antag_name) {
    case 'Cyber Police':
      return (
        <>
          <Stack.Item mb={2}>
            To assist your task, your program has been loaded with cutting edge{' '}
            <span style={textStyles.variable}>martial arts</span> skills.
          </Stack.Item>
          <Stack.Item grow>
            Ranged weaponry is <span style={textStyles.danger}>forbidden</span>.
            Ballistic defense is frowned upon. Style is paramount.
          </Stack.Item>
        </>
      );
    case 'Cyber Tac':
      return (
        <>
          <Stack.Item mb={2}>
            You are an advanced combat unit. You have been outfitted with{' '}
            <span style={textStyles.variable}>lethal weaponry</span>.
          </Stack.Item>
          <Stack.Item grow>
            <span style={textStyles.danger}>Terminate</span> organic life at any
            cost.
          </Stack.Item>
        </>
      );
    case 'NetGuardian Prime':
      return (
        <Stack.Item grow>
          <span style={{ ...textStyles.danger, fontSize: '16px' }}>
            ORGANIC LIFE MUST BE TERMINATED.
          </span>
        </Stack.Item>
      );
    default:
      return null;
  }
};

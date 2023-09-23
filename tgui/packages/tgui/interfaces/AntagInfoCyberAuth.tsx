import { useBackend } from '../backend';
import { Divider, Section, Stack } from '../components';
import { Window } from '../layouts';
import { Objective } from './common/Objectives';

type Info = {
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

export const AntagInfoCyberAuth = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives = [] } = data;

  return (
    <Window width={350} height={450} theme="ntos_terminal">
      <Window.Content>
        <Section scrollable fill>
          <Stack fill vertical>
            <Stack.Item>FN CYBER AUTHORITY UNIT (REF)</Stack.Item>
            <Divider />
            <Stack.Item mb={1} bold fontSize="16px">
              <span style={textStyles.variable}>
                You are a cyber authority unit.
              </span>
            </Stack.Item>
            <Stack.Item>
              Your mission: <span style={textStyles.variable}>Eliminate</span>{' '}
              organic intruders to maintain the integrity of the system.
            </Stack.Item>
            <Stack.Item mb={1}>
              <span style={textStyles.danger}>Bitrunning</span> is a crime. To
              assist your task, your program has been loaded with cutting edge{' '}
              <span style={textStyles.variable}>martial arts</span> skills.
            </Stack.Item>
            <Stack.Item grow>
              Ranged weaponry is{' '}
              <span style={textStyles.danger}>forbidden</span>. Ballistic
              defense is frowned upon. Style is paramount.
            </Stack.Item>
            <Stack.Item>
              <marquee scrollamount="2">{objectives[0].explanation}</marquee>
            </Stack.Item>
            <Divider />
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
            <Stack.Item>cyber_authority_unit([0x70cf4020])</Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

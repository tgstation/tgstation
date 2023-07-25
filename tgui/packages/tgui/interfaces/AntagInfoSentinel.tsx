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

export const AntagInfoSentinel = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives = [] } = data;

  return (
    <Window width={300} height={370} theme="ntos_terminal">
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item fontSize="20px">
              FN CYBER AUTHORITY UNIT (REF)
            </Stack.Item>
            <Divider />
            <Stack.Item>
              const <span style={textStyles.variable}>OBJECTIVE</span> =
            </Stack.Item>
            <Stack.Item>&apos;{objectives[0].explanation}&apos;;</Stack.Item>{' '}
            <Stack.Item mt={4}>
              const <span style={textStyles.variable}>TARGETS</span> ={' '}
            </Stack.Item>
            <Stack.Item>
              <span style={textStyles.variable}>system.</span>
              <span style={textStyles.danger}>INTRUDERS</span>;
            </Stack.Item>
            <Stack.Item mt={4}>
              while <span style={textStyles.variable}>TARGETS</span>.LIFE !={' '}
              <span style={textStyles.variable}>stat.</span>DEAD
            </Stack.Item>
            <Stack.Item mb={4}>
              <span style={textStyles.variable}>action.</span>
              <span style={textStyles.danger}>KILL()</span>
            </Stack.Item>
            <Divider />
            <Stack.Item>cyber_authority_unit([0x70cf4020])</Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

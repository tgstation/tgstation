import { useBackend } from '../backend';
import { Divider, Section, Stack } from '../components';
import { Window } from '../layouts';
import { Objective, ObjectivePrintout } from './common/Objectives';

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
    <Window width={300} height={370} theme="ntos_terminal">
      <Window.Content>
        <Section scrollable fill>
          <Stack fill vertical>
            <Stack.Item fontSize="20px">
              FN CYBER AUTHORITY UNIT (REF)
            </Stack.Item>
            <Divider />
            <Stack.Item grow>
              <ObjectivePrintout objectives={objectives} />
            </Stack.Item>
            <Divider />
            <Stack.Item>
              const <span style={textStyles.variable}>TARGETS</span> ={' '}
            </Stack.Item>
            <Stack.Item>
              <span style={textStyles.variable}>system.</span>
              <span style={textStyles.danger}>INTRUDERS</span>;
            </Stack.Item>
            <Stack.Item mt={1}>
              self.learn(<span style={textStyles.variable}>martial.</span>
              <span style={textStyles.danger}>CARP</span>)
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

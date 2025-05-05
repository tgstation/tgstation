import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ObjectiveElement } from './ObjectiveElement';

type PrimaryObjectiveMenuProps = {
  primary_objectives;
  can_renegotiate;
};

export const PrimaryObjectiveMenu = (props: PrimaryObjectiveMenuProps) => {
  const { act } = useBackend();
  const { primary_objectives, can_renegotiate } = props;
  return (
    <Section fill scrollable align="center">
      <Box my={4} bold fontSize={1.2} color="green">
        WELCOME, AGENT.
      </Box>
      <Box my={4} bold fontSize={1.2}>
        Your Primary Objectives are as follows. Complete these at all costs.
      </Box>
      <Stack vertical>
        {primary_objectives.map((prim_obj, index) => (
          <Stack.Item key={index}>
            <ObjectiveElement
              key={prim_obj.id}
              name={prim_obj['task_name']}
              description={prim_obj['task_text']}
            />
          </Stack.Item>
        ))}
      </Stack>
      {!!can_renegotiate && (
        <Box mt={3} mb={5} bold fontSize={1.2} align="center" color="white">
          <Button
            content={'Renegotiate Contract'}
            tooltip={
              'Replace your existing primary objectives with a custom one. This action can only be performed once.'
            }
            onClick={() => act('renegotiate_objectives')}
          />
        </Box>
      )}
      <Box my={4} fontSize={0.8}>
        <Box>SyndOS Version 3.17</Box>
        <Box color="green">Connection Secure</Box>
      </Box>
    </Section>
  );
};

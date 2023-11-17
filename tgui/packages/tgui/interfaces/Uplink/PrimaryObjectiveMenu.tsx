import { useBackend } from '../../backend';
import { Box, Button, Section, Stack } from '../../components';
import { ObjectiveElement } from './ObjectiveMenu';

type PrimaryObjectiveMenuProps = {
  primary_objectives;
  can_renegotiate;
};

export const PrimaryObjectiveMenu = (
  props: PrimaryObjectiveMenuProps,
  context
) => {
  const { act } = useBackend(context);
  const { primary_objectives, can_renegotiate } = props;
  return (
    <Section fill>
      <Section>
        <Box mt={3} mb={3} bold fontSize={1.2} align="center" color="white">
          {
            'Agent, your Primary Objectives are as follows. Complete these at all costs.'
          }
        </Box>
        <Box mt={3} mb={5} bold fontSize={1.2} align="center" color="white">
          {
            'Completing Secondary Objectives may allow you to aquire additional equipment.'
          }
        </Box>
      </Section>
      <Section>
        <Stack vertical fill scrollable>
          {primary_objectives.map((prim_obj, index) => (
            <Stack.Item key={index}>
              <ObjectiveElement
                key={prim_obj.id}
                name={prim_obj['task_name']}
                description={prim_obj['task_text']}
                dangerLevel={{
                  minutesLessThan: 0,
                  title: 'none',
                  gradient:
                    index === primary_objectives.length - 1
                      ? 'reputation-good'
                      : 'reputation-very-good',
                }}
                telecrystalReward={0}
                telecrystalPenalty={0}
                progressionReward={0}
                originalProgression={0}
                hideTcRep
                canAbort={false}
                grow={false}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Section>
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
    </Section>
  );
};

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
        ПРИВЕТСТВУЕМ, АГЕНТ.
      </Box>
      <Box my={4} bold fontSize={1.2}>
        Агент, это ваши основные задачи. Выполните их любой ценой.
      </Box>
      <Stack vertical>
        {primary_objectives.map((prim_obj, index) => (
          <Stack.Item key={index}>
            <ObjectiveElement
              key={prim_obj.id}
              name={prim_obj.task_name}
              description={prim_obj.task_text}
            />
          </Stack.Item>
        ))}
      </Stack>
      {!!can_renegotiate && (
        <Box mt={3} mb={5} bold fontSize={1.2} align="center" color="white">
          <Button
            content={'Перезаключить контракт'}
            tooltip={
              'Замените свои текущие основные задачи на пользовательские. Это действие можно совершить лишь единожды.'
            }
            onClick={() => act('renegotiate_objectives')}
          />
        </Box>
      )}
      <Box my={4} fontSize={0.8}>
        <Box>SyndOS Version 3.17</Box>
        <Box color="green">Безопасное соединение</Box>
      </Box>
    </Section>
  );
};

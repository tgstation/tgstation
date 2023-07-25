import { useBackend } from '../../backend';
import { Stack } from '../../components';
import { OperatorData } from './data';
import { ModulesPane } from './ModulesPane';
import { MechStatPane } from './MechStatPane';
import { AlertPane } from './AlertPane';

export const OperatorMode = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  return (
    <Stack fill>
      <Stack.Item grow={1}>
        <Stack vertical fill>
          <Stack.Item grow overflow="hidden">
            <MechStatPane />
          </Stack.Item>
          <Stack.Item>
            <AlertPane />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow={2}>
        <ModulesPane />
      </Stack.Item>
    </Stack>
  );
};

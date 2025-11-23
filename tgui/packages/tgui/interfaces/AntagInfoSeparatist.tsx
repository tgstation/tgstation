import { Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  objectives: Objective[];
  nation: string;
  nationColor: string;
};

export const AntagInfoSeparatist = (props) => {
  const { data } = useBackend<Info>();
  const { nationColor } = data;
  return (
    <Window width={620} height={450}>
      <Window.Content backgroundColor={nationColor}>
        <Stack vertical fill>
          <Stack.Item grow>
            <IntroductionObjectives />
          </Stack.Item>
          <Stack.Item>
            <FrequentlyAskedQuestions />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const IntroductionObjectives = (props) => {
  const { data } = useBackend<Info>();
  const { nation, objectives } = data;
  return (
    <Section fill>
      <Stack vertical>
        <Stack.Item textColor="red" fontSize="20px">
          You are the Separatist for a free {nation}!
        </Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout
            objectives={objectives}
            titleMessage={`${nation}'s objectives:`}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const FrequentlyAskedQuestions = (props) => {
  const { data } = useBackend<Info>();
  const { nation } = data;
  return (
    <Section fill>
      <Stack vertical>
        <Stack.Item fontSize="18px" bold>
          <Icon name="info" color="label" /> Frequently Asked Questions:
        </Stack.Item>
        <Stack.Item fontSize="16px">
          &quot;What even IS a Separatist?&quot;
        </Stack.Item>
        <Stack.Item>
          Separatists are semi-antagonists that every department is filled with
          when the round starts. They do not have the permission to freely go
          about and kill, but rather defend the soverignity of their department.
          You may actually recognize them by their historical mode they existed
          from: Nations!
        </Stack.Item>
        <Stack.Item fontSize="16px">
          &quot;What am I supposed to do?&quot;
        </Stack.Item>
        <Stack.Item>
          Each department (nation) has an objective. It&apos;s a freeform
          objective, so try your best to follow it as you would a freeform
          abductor objective. From experience, eventually nations conflict and
          devolve into war. As long as both departments know what and why
          conflict is starting, that&apos;s a green light to attack opposing
          nations.
        </Stack.Item>
        <Stack.Item fontSize="16px">
          &quot;Is {nation} the best nation?&quot;
        </Stack.Item>
        <Stack.Item>Yes.</Stack.Item>
      </Stack>
    </Section>
  );
};

import {
  Box,
  Button,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// Похуй сойдёт и так. Если кому интересно то это первый интерфейс автодока на новотг на реакте.
interface Surgery {
  name: string;
  path: string;
  selected: boolean;
}

interface Step {
  name: string;
  current: boolean;
}

interface AutodocData {
  mode: number;
  surgeries: Surgery[];
  steps: Step[];
  s_name: string;
}

interface AutodocProps {
  context: any;
}

export const Autodoc: React.FC<AutodocProps> = ({ context }) => {
  const { act, data } = useBackend<AutodocData>(context);
  const operations = data.surgeries;

  if (data.mode === 1) {
    return (
      <Window width={496} height={440}>
        <Section title="Конечность">
          {[
            ['head', 'Голова'],
            ['chest', 'Грудь'],
            ['l_arm', 'Л. рука'],
            ['r_arm', 'П. рука'],
            ['l_leg', 'Л. нога'],
            ['r_leg', 'П. нога'],
            ['groin', 'Пах'],
            ['eyes', 'Глаза'],
            ['mouth', 'Рот'],
          ].map(([part, label]) => (
            <Button
              key={part}
              content={label}
              onClick={() => act('target', { part })}
            />
          ))}
        </Section>

        <Section>
          {operations.map((op) => (
            <Button
              icon="vial"
              key={op.name}
              content={op.name}
              selected={op.selected}
              onClick={() => act('surgery', { path: op.path })}
            />
          ))}
        </Section>

        <Section>
          <Button
            key="start_op"
            content="Начать операцию"
            onClick={() => act('start')}
          />
        </Section>
      </Window>
    );
  } else if (data.mode === 2) {
    return (
      <Window>
        <Section textAlign="center" title={`Операция: ${data.s_name}`}>
          {data.steps.map((step) => (
            <Box
              key={step.name}
              fontSize={step.current ? '16px' : '12px'}
            >
              {step.current ? '>> ' : ''}
              {step.name}
              {step.current ? ' <<' : ''}
            </Box>
          ))}
        </Section>
        <NoticeBox textAlign="center">Выполняется операция</NoticeBox>
      </Window>
    );
  } else {
    return <NoticeBox textAlign="center">Нет доступа</NoticeBox>;
  }
};

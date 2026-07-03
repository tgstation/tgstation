import {
  Box,
  Button,
  Icon,
  LabeledList,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export type Techweb = {
  all_servers: string[];
  ref: string;
  selected: number;
  web_id: string;
  web_org: string;
};

export type ExperimentData = {
  description: string;
  name: string;
  performance_hint: string;
  progress: Stage[];
  ref: string;
  selected?: BooleanLike;
  completed?: BooleanLike;
  tag: string;
};

// Value type, Description, Value, AltValue
type Stage = [string, string, number, number];

type Data = {
  always_active: boolean;
  experiments: ExperimentData[];
  has_start_callback: boolean;
  techwebs: Techweb[];
};

type ExperimentStageRowProps = {
  stage: Stage;
};

function ExperimentStageRow(props: ExperimentStageRowProps) {
  const [type, description, value, altValue] = props.stage;

  // Determine completion based on type of stage
  let completion = false;
  switch (type) {
    case 'bool':
    case 'detail':
      completion = !!value;
      break;
    case 'integer':
      completion = value === altValue;
      break;
    case 'float':
      completion = value >= 1;
      break;
  }

  return (
    <Table.Row
      className={`ExperimentStage__StageContainer
        ${completion ? 'complete' : 'incomplete'}`}
    >
      <Table.Cell
        collapsing
        className={`ExperimentStage__Indicator ${type}`}
        color={completion ? 'good' : 'bad'}
      >
        {(type === 'bool' && <Icon name={value ? 'check' : 'times'} />) ||
          (type === 'integer' && `${value}/${altValue}`) ||
          (type === 'float' && `${value * 100}%`) ||
          (type === 'detail' && '⤷')}
      </Table.Cell>
      <Table.Cell className="ExperimentStage__Description">
        {description}
      </Table.Cell>
    </Table.Row>
  );
}

type TechwebServerProps = {
  techwebs: Techweb[];
  can_select?: boolean;
};

export function TechwebServer(props: TechwebServerProps) {
  const { act } = useBackend<Data>();
  const { techwebs, can_select = true } = props;

  return techwebs.map((server, index) => (
    <Box key={index} m={1} className="ExperimentTechwebServer__Web">
      <Stack
        align="center"
        justify="space-between"
        className="ExperimentTechwebServer__WebHeader"
      >
        <Stack.Item className="ExperimentTechwebServer__WebName">
          {server.web_id} / {server.web_org}
        </Stack.Item>
        {can_select && (
          <Stack.Item>
            <Button
              onClick={() =>
                server.selected
                  ? act('clear_server')
                  : act('select_server', { ref: server.ref })
              }
              backgroundColor={server.selected ? 'good' : 'rgba(0, 0, 0, 0.4)'}
              className="ExperimentTechwebServer__ConnectButton"
            >
              {server.selected ? 'Отключиться' : 'Подключиться'}
            </Button>
          </Stack.Item>
        )}
      </Stack>
      <Box className="ExperimentTechwebServer__WebContent">
        <span>Соединение к этой сети поддерживают следующие сервера...</span>
        <LabeledList>
          {server.all_servers.map((individual_servers, new_index) => (
            <Box key={new_index}>{individual_servers}</Box>
          ))}
        </LabeledList>
      </Box>
    </Box>
  ));
}

type ExperimentTitleElementProps = {
  selected: boolean;
  ref: string;
  can_select?: boolean;
  children?: React.ReactNode;
};

function ExperimentTitleElement(props: ExperimentTitleElementProps) {
  const { act } = useBackend<Data>();
  const { selected, ref, can_select = true, children } = props;

  if (!can_select) {
    return (
      <Box className="ExperimentConfigure__ExperimentNameFakeButton">
        {children}
      </Box>
    );
  }

  return (
    <Button
      fluid
      onClick={() =>
        selected
          ? act('clear_experiment')
          : act('select_experiment', { ref: ref })
      }
      selected={selected}
      className="ExperimentConfigure__ExperimentName"
    >
      {children}
    </Button>
  );
}

type ExperimentProps = {
  exp: ExperimentData;
  children?: React.ReactNode;
  can_select?: boolean;
};

export function Experiment(props: ExperimentProps) {
  const { exp, children, can_select } = props;
  const { name, description, tag, selected, progress, performance_hint, ref } =
    exp;

  return (
    <Box
      m={1}
      key={ref}
      className={`ExperimentConfigure__ExperimentPanel${selected ? '--selected' : ''}`}
    >
      <ExperimentTitleElement
        selected={!!selected}
        ref={ref}
        can_select={can_select}
      >
        <Stack>
          <Stack.Item>{name}</Stack.Item>
          <Stack.Item color="rgba(255, 255, 255, 0.5)">
            <div className="ExperimentConfigure__TagContainer">
              <Stack>
                <Stack.Item>{tag}</Stack.Item>
                <Stack.Item>
                  <Tooltip content={performance_hint} position="bottom-start">
                    <Icon name="question-circle" mx={0.5} />
                    <div className="ExperimentConfigure__PerformanceHint" />
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </div>
          </Stack.Item>
        </Stack>
      </ExperimentTitleElement>
      <div className="ExperimentConfigure__ExperimentContent">
        <Box mb={1}>{description}</Box>
        {children}
        <Table ml={2} className="ExperimentStage__Table">
          {progress.map((stage, idx) => (
            <ExperimentStageRow key={idx} stage={stage} />
          ))}
        </Table>
      </div>
    </Box>
  );
}

export function ExperimentConfigure(props) {
  const { act, data } = useBackend<Data>();
  const { always_active, has_start_callback } = data;

  const techwebs = data.techwebs ?? [];

  const experiments = data.experiments.sort((a, b) =>
    a.name.localeCompare(b.name),
  );

  // Group servers together by web
  const webs = new Map();
  for (const x of techwebs) {
    if (x.web_id !== null) {
      if (!webs.has(x.web_id)) {
        webs.set(x.web_id, []);
      }
      webs.get(x.web_id).push(x);
    }
  }

  let textContent = '';
  if (experiments.length === 0) {
    textContent = 'Не найдены эксперименты в этой сети';
  } else if (always_active) {
    textContent =
      'Это устройство настроено для выполнения всех доступных экспериментов. Дальнейшие настройки не нужны.';
  } else {
    textContent = 'Выберите один из следующих экспериментов...';
  }

  return (
    <Window width={600} height={735}>
      <Window.Content scrollable>
        <Section title="Сервера">
          <Box color="label">
            {webs.size > 0
              ? 'Пожалуйста, выберите техсеть для подключения...'
              : 'Не найдены сервера, подключенные к техсети!'}
          </Box>
          {webs.size > 0 &&
            Array.from(webs, ([techweb, techwebs]) => (
              <TechwebServer key={techweb} techwebs={techwebs} />
            ))}
        </Section>
        <Stack vertical>
          {techwebs.some((e) => e.selected) && (
            <Stack.Item>
              <Section
                title="Эксперименты"
                className="ExperimentConfigure__ExperimentsContainer"
                fill
              >
                <Box mb={1} color="label">
                  {textContent}
                </Box>
                {experiments.map((exp, i) => (
                  <Experiment key={i} exp={exp} />
                ))}
              </Section>
            </Stack.Item>
          )}

          {!!has_start_callback && (
            <Stack.Item>
              <Button
                fluid
                className="ExperimentConfigure__PerformExperiment"
                onClick={() => act('start_experiment_callback')}
                disabled={!experiments.some((e) => e.selected)}
                icon="flask"
              >
                Выполнить эксперимент
              </Button>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
}

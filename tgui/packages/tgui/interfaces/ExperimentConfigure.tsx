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

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Techweb = {
  all_servers: string[];
  ref: string;
  selected: number;
  web_id: string;
  web_org: string;
};

type ExperimentData = {
  description: string;
  name: string;
  performance_hint: string;
  progress: Progress[];
  ref: string;
  selected: number;
  tag: string;
};

type Progress = [string, string, number, number];

type Data = {
  always_active: boolean;
  experiments: ExperimentData[];
  has_start_callback: boolean;
  techwebs: Techweb[];
};

function ExperimentStages(props) {
  return (
    <Table ml={2} className="ExperimentStage__Table">
      {props.children.map((stage, idx) => (
        <ExperimentStageRow key={idx} {...stage} />
      ))}
    </Table>
  );
}

function ExperimentStageRow(props) {
  const [type, description, value, altValue] = props;

  // Determine completion based on type of stage
  let completion = false;
  switch (type) {
    case 'bool':
    case 'detail':
      completion = value;
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

function TechwebServer(props) {
  const { act } = useBackend<Data>();
  const { techwebs } = props;

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
            {server.selected ? 'Disconnect' : 'Connect'}
          </Button>
        </Stack.Item>
      </Stack>
      <Box className="ExperimentTechwebServer__WebContent">
        <span>
          Connectivity to this web is maintained by the following servers...
        </span>
        <LabeledList>
          {server.all_servers.map((individual_servers, new_index) => (
            <Box key={new_index}>{individual_servers}</Box>
          ))}
        </LabeledList>
      </Box>
    </Box>
  ));
}

export function Experiment(props) {
  const { act } = useBackend<Data>();
  const { exp } = props;
  const { name, description, tag, selected, progress, performance_hint, ref } =
    exp;

  return (
    <Box m={1} key={ref} className="ExperimentConfigure__ExperimentPanel">
      <Button
        fluid
        onClick={() =>
          selected
            ? act('clear_experiment')
            : act('select_experiment', { ref: ref })
        }
        backgroundColor={selected ? 'good' : '#40628a'}
        className="ExperimentConfigure__ExperimentName"
      >
        <Stack>
          <Stack.Item>{name}</Stack.Item>
          <Stack.Item color="rgba(255, 255, 255, 0.5)">
            <div className="ExperimentConfigure__TagContainer">
              {tag}
              <Tooltip content={performance_hint} position="bottom-start">
                <Icon name="question-circle" mx={0.5} />
                <div className="ExperimentConfigure__PerformanceHint" />
              </Tooltip>
            </div>
          </Stack.Item>
        </Stack>
      </Button>
      <div className="ExperimentConfigure__ExperimentContent">
        <Box mb={1}>{description}</Box>
        {props.children}
        <ExperimentStages>{progress}</ExperimentStages>
      </div>
    </Box>
  );
}

export function ExperimentConfigure(props) {
  const { act, data } = useBackend<Data>();
  const { always_active, has_start_callback } = data;

  let techwebs = data.techwebs ?? [];

  const experiments = data.experiments.sort((a, b) =>
    a.name.localeCompare(b.name),
  );

  // Group servers together by web
  let webs = new Map();
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
    textContent = 'No experiments found on this web';
  } else if (always_active) {
    textContent =
      'This device is configured to attempt to perform all available experiments, so no further configuration is necessary.';
  } else {
    textContent = 'Select one of the following experiments...';
  }

  return (
    <Window width={600} height={735}>
      <Window.Content scrollable>
        <Section title="Servers">
          <Box color="label">
            {webs.size > 0
              ? 'Please select a techweb to connect to...'
              : 'Found no servers connected to a techweb!'}
          </Box>
          {webs.size > 0 &&
            Array.from(webs, ([techweb, techwebs]) => (
              <TechwebServer key={techweb} techwebs={techwebs} />
            ))}
        </Section>

        {techwebs.some((e) => e.selected) && (
          <Section
            title="Experiments"
            className="ExperimentConfigure__ExperimentsContainer"
          >
            <Box mb={1} color="label">
              {textContent}
            </Box>
            {experiments.map((exp, i) => (
              <Experiment key={i} exp={exp} />
            ))}
          </Section>
        )}

        {!!has_start_callback && (
          <Button
            fluid
            className="ExperimentConfigure__PerformExperiment"
            onClick={() => act('start_experiment_callback')}
            disabled={!experiments.some((e) => e.selected)}
            icon="flask"
          >
            Perform Experiment
          </Button>
        )}
      </Window.Content>
    </Window>
  );
}

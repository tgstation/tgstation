import { sortBy } from 'common/collections';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Section,
  Table,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

const ExperimentStages = (props) => {
  return (
    <Table ml={2} className="ExperimentStage__Table">
      {props.children.map((stage, idx) => (
        <ExperimentStageRow key={idx} {...stage} />
      ))}
    </Table>
  );
};

const ExperimentStageRow = (props) => {
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
};

export const TechwebServer = (props) => {
  const { act, data } = useBackend();
  const { techwebs } = props;

  return techwebs.map((server, index) => (
    <Box key={index} m={1} className="ExperimentTechwebServer__Web">
      <Flex
        align="center"
        justify="space-between"
        className="ExperimentTechwebServer__WebHeader"
      >
        <Flex.Item className="ExperimentTechwebServer__WebName">
          {server.web_id} / {server.web_org}
        </Flex.Item>
        <Flex.Item>
          <Button
            onClick={() =>
              server.selected
                ? act('clear_server')
                : act('select_server', { ref: server.ref })
            }
            content={server.selected ? 'Disconnect' : 'Connect'}
            backgroundColor={server.selected ? 'good' : 'rgba(0, 0, 0, 0.4)'}
            className="ExperimentTechwebServer__ConnectButton"
          />
        </Flex.Item>
      </Flex>
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
};

export const ExperimentConfigure = (props) => {
  const { act, data } = useBackend();
  const { always_active, has_start_callback } = data;
  let techwebs = data.techwebs ?? [];

  const experiments = sortBy(data.experiments ?? [], (exp) => exp.name);

  // Group servers together by web
  let webs = new Map();
  techwebs.forEach((x) => {
    if (x.web_id !== null) {
      if (!webs.has(x.web_id)) {
        webs.set(x.web_id, []);
      }
      webs.get(x.web_id).push(x);
    }
  });

  return (
    <Window resizable width={600} height={735}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item mb={1}>
            <Section title="Servers">
              <Box>
                {webs.size > 0
                  ? 'Please select a techweb to connect to...'
                  : 'Found no servers connected to a techweb!'}
              </Box>
              {webs.size > 0 &&
                Array.from(webs, ([techweb, techwebs]) => (
                  <TechwebServer key={techweb} techwebs={techwebs} />
                ))}
            </Section>
          </Flex.Item>
          <Flex.Item mb={has_start_callback ? 1 : 0} grow={1}>
            {techwebs.some((e) => e.selected) && (
              <Section
                title="Experiments"
                className="ExperimentConfigure__ExperimentsContainer"
              >
                <Flex.Item mb={1}>
                  {(experiments.length &&
                    always_active &&
                    'This device is configured to attempt to perform all available' +
                      ' experiments, so no further configuration is necessary.') ||
                    (experiments.length &&
                      'Select one of the following experiments...') ||
                    'No experiments found on this web'}
                </Flex.Item>
                <Flex.Item>
                  {experiments.map((exp, i) => {
                    return <Experiment key={i} exp={exp} />;
                  })}
                </Flex.Item>
              </Section>
            )}
          </Flex.Item>
          {!!has_start_callback && (
            <Flex.Item>
              <Button
                fluid
                className="ExperimentConfigure__PerformExperiment"
                onClick={() => act('start_experiment_callback')}
                disabled={!experiments.some((e) => e.selected)}
                icon="flask"
              >
                Perform Experiment
              </Button>
            </Flex.Item>
          )}
        </Flex>
      </Window.Content>
    </Window>
  );
};

export const Experiment = (props) => {
  const { act, data } = useBackend();
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
        <Flex align="center" justify="space-between">
          <Flex.Item color={'white'}>{name}</Flex.Item>
          <Flex.Item color={'rgba(255, 255, 255, 0.5)'}>
            <Box className="ExperimentConfigure__TagContainer">
              {tag}
              <Tooltip content={performance_hint} position="bottom-start">
                <Icon name="question-circle" mx={0.5} />
                <Box className="ExperimentConfigure__PerformanceHint" />
              </Tooltip>
            </Box>
          </Flex.Item>
        </Flex>
      </Button>
      <Box className={'ExperimentConfigure__ExperimentContent'}>
        <Box mb={1}>{description}</Box>
        {props.children}
        <ExperimentStages>{progress}</ExperimentStages>
      </Box>
    </Box>
  );
};

import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Section, Box, Button, Flex, Icon, LabeledList, Table, Tooltip } from '../components';
import { sortBy } from 'common/collections';

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
        ${completion ? 'complete' : 'incomplete'}`}>
      <Table.Cell
        collapsing
        className={`ExperimentStage__Indicator ${type}`}
        color={completion ? 'good' : 'bad'}>
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

export const TechwebServer = (props, context) => {
  const { act, data } = useBackend(context);
  const { servers } = props;

  return (
    <Box m={1} className="ExperimentTechwebServer__Web">
      <Flex
        align="center"
        justify="space-between"
        className="ExperimentTechwebServer__WebHeader">
        <Flex.Item className="ExperimentTechwebServer__WebName">
          {servers[0].web_id} / {servers[0].web_org}
        </Flex.Item>
        <Flex.Item>
          <Button
            onClick={() =>
              servers[0].selected
                ? act('clear_server')
                : act('select_server', { 'ref': servers[0].ref })
            }
            content={servers[0].selected ? 'Disconnect' : 'Connect'}
            backgroundColor={
              servers[0].selected ? 'good' : 'rgba(0, 0, 0, 0.4)'
            }
            className="ExperimentTechwebServer__ConnectButton"
          />
        </Flex.Item>
      </Flex>
      <Box className="ExperimentTechwebServer__WebContent">
        <span>
          Connectivity to this web is maintained by the following servers...
        </span>
        <LabeledList>
          {servers.map((server, index) => {
            return (
              <LabeledList.Item key={index} label={server.name}>
                <i>Located in {server.location}</i>
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      </Box>
    </Box>
  );
};

export const ExperimentConfigure = (props, context) => {
  const { act, data } = useBackend(context);
  const { always_active, has_start_callback } = data;
  let servers = data.servers ?? [];

  const experiments = sortBy((exp) => exp.name)(data.experiments ?? []);

  // Group servers together by web
  let webs = new Map();
  servers.forEach((x) => {
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
                  : 'Found no available techwebs!'}
              </Box>
              {webs.size > 0 &&
                Array.from(webs, ([techweb, servers]) => (
                  <TechwebServer key={techweb} servers={servers} />
                ))}
            </Section>
          </Flex.Item>
          <Flex.Item mb={has_start_callback ? 1 : 0} grow={1}>
            {servers.some((e) => e.selected) && (
              <Section
                title="Experiments"
                className="ExperimentConfigure__ExperimentsContainer">
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
                    return <Experiment key={i} exp={exp} controllable />;
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
                icon="flask">
                Perform Experiment
              </Button>
            </Flex.Item>
          )}
        </Flex>
      </Window.Content>
    </Window>
  );
};

export const Experiment = (props, context) => {
  const { act, data } = useBackend(context);
  const { exp, controllable } = props;
  const {
    name,
    description,
    tag,
    selectable,
    selected,
    progress,
    performance_hint,
    ref,
  } = exp;

  return (
    <Box m={1} key={ref} className="ExperimentConfigure__ExperimentPanel">
      <Button
        fluid
        onClick={() =>
          controllable &&
          (selected
            ? act('clear_experiment')
            : act('select_experiment', { 'ref': ref }))
        }
        backgroundColor={selected ? 'good' : '#40628a'}
        className="ExperimentConfigure__ExperimentName"
        disabled={controllable && !selectable}>
        <Flex align="center" justify="space-between">
          <Flex.Item
            color={
              !controllable || selectable ? 'white' : 'rgba(0, 0, 0, 0.6)'
            }>
            {name}
          </Flex.Item>
          <Flex.Item
            color={
              !controllable || selectable
                ? 'rgba(255, 255, 255, 0.5)'
                : 'rgba(0, 0, 0, 0.5)'
            }>
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

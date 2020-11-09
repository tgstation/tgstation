import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Section, Box, Button, Flex, Icon, LabeledList, Table } from '../components';
import { sortBy } from 'common/collections';

export const ExperimentStage = props => {
  const [type, description, value, altValue] = props;

  // Determine completion based on type of stage
  let completion = false;
  switch (type) {
    case "bool":
    case "detail":
      completion = value;
      break;
    case "integer":
      completion = value === altValue;
      break;
    case "float":
      completion = value >= 1;
      break;
  }

  return (
    <Box
      className={`ExperimentStage__StageContainer ${completion ? "complete" : "incomplete"}`}
      m={0.5}
      ml={2}>
      <Flex>
        <Flex.Item
          className={`ExperimentStage__Indicator ${type}`}
          color={completion ? "good" : "bad"}>
          {(type === "bool" && <Icon name={value ? "check" : "times"} />)
            || (type === "integer" && `${value}/${altValue}`)
            || (type === "float" && `${value * 100}%`)
            || (type === "detail" && "⤷")}
        </Flex.Item>
        <Flex.Item className="ExperimentStage__Description">
          {description}
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const ExperimentStages = props => {
  return (
    <Table ml={2} className="ExperimentStage__Table">
      {props.children.map((stage, idx) =>
        (<ExperimentStageRow key={idx} {...stage} />))}
    </Table>
  );
};

const ExperimentStageRow = props => {
  const [type, description, value, altValue] = props;

  // Determine completion based on type of stage
  let completion = false;
  switch (type) {
    case "bool":
    case "detail":
      completion = value;
      break;
    case "integer":
      completion = value === altValue;
      break;
    case "float":
      completion = value >= 1;
      break;
  }

  return (
    <Table.Row
      className={`ExperimentStage__StageContainer
        ${completion ? "complete" : "incomplete"}`}>
      <Table.Cell
        collapsing
        className={`ExperimentStage__Indicator ${type}`}
        color={completion ? "good" : "bad"}>
        {(type === "bool" && <Icon name={value ? "check" : "times"} />)
          || (type === "integer" && `${value}/${altValue}`)
          || (type === "float" && `${value * 100}%`)
          || (type === "detail" && "⤷")}
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
      <Flex align="center" justify="space-between"
        className="ExperimentTechwebServer__WebHeader">
        <Flex.Item className="ExperimentTechwebServer__WebName">
          {servers[0].web_id} / {servers[0].web_org}
        </Flex.Item>
        <Flex.Item>
          <Button
            onClick={() => servers[0].selected
              ? act("clear_server")
              : act("select_server", { "ref": servers[0].ref })}
            content={servers[0].selected ? "Disconnect" : "Connect"}
            backgroundColor={servers[0].selected ? "good" : "rgba(0, 0, 0, 0.4)"}
            className="ExperimentTechwebServer__ConnectButton" />
        </Flex.Item>
      </Flex>
      <Box className="ExperimentTechwebServer__WebContent">
        <span>
          Connectivity to this web is maintained by the following servers...
        </span>
        <LabeledList>
          {servers.map((server, index) => {
            return (
              <LabeledList.Item
                key={index}
                label={server.name}>
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
  let servers = data.servers ?? [];

  const experiments = sortBy(
    exp => exp.name
  )(data.experiments ?? []);

  // Group servers together by web
  let webs = new Map();
  servers.forEach(x => {
    if (x.web_id !== null) {
      if (!webs.has(x.web_id)) {
        webs.set(x.web_id, []);
      }
      webs.get(x.web_id).push(x);
    }
  });

  return (
    <Window
      resizable
      width={600}
      height={800}>
      <Window.Content>
        <Section title="Servers">
          <Box>
            {webs.size > 0
              ? "Please select a techweb to connect to..."
              : "Found no available techwebs!"}
          </Box>
          {webs.size > 0 && Array.from(webs, ([techweb, servers]) =>
            <TechwebServer key={techweb} servers={servers} />)}
        </Section>
        {servers.some(e => e.selected) && (
          <Section title="Experiments">
            <Box>
              {experiments.length
                ? "Select one of the following experiments..."
                : "No experiments found on this web"}
            </Box>
            {experiments.map((exp, i) => {
              return (
                <Experiment key={`e${i}`} exp={exp} controllable />
              );
            })}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

export const Experiment = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    exp,
    controllable,
  } = props;

  return (
    <Box m={1} key={exp.ref}
      className="ExperimentConfigure__ExperimentPanel">
      <Button fluid
        onClick={() => controllable && (exp.selected
          ? act("clear_experiment")
          : act("select_experiment", { "ref": exp.ref }))}
        backgroundColor={exp.selected ? "good" : "#40628a"}
        className="ExperimentConfigure__ExperimentName"
        disabled={controllable && !exp.selectable}>
        <Flex align="center" justify="space-between">
          <Flex.Item
            color={!controllable || exp.selectable
              ? "white"
              : "rgba(0, 0, 0, 0.6)"}>
            {exp.name}
          </Flex.Item>
          <Flex.Item
            color={!controllable || exp.selectable
              ? "rgba(255, 255, 255, 0.5)"
              : "rgba(0, 0, 0, 0.5)"}>
            {exp.tag}
          </Flex.Item>
        </Flex>
      </Button>
      <Box className={"ExperimentConfigure__ExperimentContent"}>
        <Box mb={1}>
          {exp.description}
        </Box>
        {props.children}
        <ExperimentStages>
          {exp.progress}
        </ExperimentStages>
      </Box>
    </Box>
  );
};

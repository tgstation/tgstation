import { Fragment } from 'inferno';
import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Section, Box, Button, Flex, Icon, LabeledList } from '../components';

export const ExperimentStage = props => {
  const [type, description, value, altValue] = props;

  // Determine completion based on type of stage
  let completion = false;
  switch (type) {
    case "bool":
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
    <div className={`ExperimentStage__StageContainer ${completion ? "complete" : "incomplete"}`}>
      <Flex>
        <Flex.Item
          className={`ExperimentStage__Indicator ${type}`}
          color={completion ? "good" : "bad"}>
          {(type === "bool" && <Icon name={value ? "check" : "times"} />)
            || (type === "integer" && `${value}/${altValue}`)
            || (type === "float" && `${value * 100}%`)}
        </Flex.Item>
        <Flex.Item className="ExperimentStage__Description">
          {description}
        </Flex.Item>
      </Flex>
    </div>
  );
};

export const Techweb = (props, context) => {
  const { act, data } = useBackend(context);
  const { servers } = props;

  return (
    <Box m={1} className="ExperimentTechweb__Web">
      <Flex align="center" justify="space-between"
        className="ExperimentTechweb__WebHeader">
        <Flex.Item className="ExperimentTechweb__WebName">
          {servers[0].web_id} / {servers[0].web_org}
        </Flex.Item>
        <Flex.Item>
          <Button
            onClick={() => servers[0].selected
              ? act("clear_server")
              : act("select_server", { "ref": servers[0].ref })}
            content={servers[0].selected ? "Disconnect" : "Connect"}
            backgroundColor={servers[0].selected ? "good" : "rgba(0, 0, 0, 0.4)"}
            className="ExperimentTechweb__ConnectButton" />
        </Flex.Item>
      </Flex>
      <Box className="ExperimentTechweb__WebContent">
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
  let experiments = data.experiments ?? [];

  // Toss the selected experiment to the top if it isn't already, sort lexically
  experiments = experiments.sort((a, b) => {
    if (a.selected !== b.selected) {
      return a.selected ? -1 : 1;
    }
    else {
      if (a.name === b.name) {
        return 0;
      }
      else {
        return a.name < b.name ? -1 : 1;
      }
    }
  });

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
      width={525}
      height={650}>
      <Window.Content scrollable>
        <Section title="Servers">
          <Box>
            {webs.size > 0
              ? "Please select a techweb to connect to..."
              : "Found no available techwebs!"}
          </Box>
          {webs.size > 0 && Array.from(webs, ([techweb, servers]) =>
            <Techweb key={techweb} servers={servers} />)}
        </Section>
        {servers.some(e => e.selected) && (
          <Section title="Experiments">
            <Box>
              {experiments.length
                ? "Select one of the following experiments..."
                : "No experiments found on this web"}
            </Box>
            {experiments.map(exp => {
              return (
                <Box m={1} key={exp.ref}
                  className="ExperimentConfigure__ExperimentPanel">
                  <Button fluid
                    onClick={() => exp.selected
                      ? act("clear_experiment")
                      : act("select_experiment", { "ref": exp.ref })}
                    backgroundColor={exp.selected ? "good" : "#40628a"}
                    className="ExperimentConfigure__ExperimentName"
                    disabled={!exp.selectable}>
                    <Flex align="center" justify="space-between">
                      <Flex.Item
                        color={exp.selectable
                          ? "white"
                          : "rgba(0, 0, 0, 0.6)"}>
                        {exp.name}
                      </Flex.Item>
                      <Flex.Item
                        color={exp.selectable
                          ? "rgba(255, 255, 255, 0.5)"
                          : "rgba(0, 0, 0, 0.5)"}>
                        {exp.tag}
                      </Flex.Item>
                    </Flex>
                  </Button>
                  <Box className={"ExperimentConfigure__ExperimentContent"}>
                    {exp.description} <br /><br />
                    {exp.progress?.map((progressItem, index) => {
                      return (
                        <ExperimentStage key={index} {...progressItem} />
                      );
                    })}
                  </Box>
                </Box>
              );
            })}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

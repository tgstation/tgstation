import { Fragment } from 'inferno';
import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Section, Box, Button, Flex } from '../components';

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

  return (
    <Window
      resizable
      width={525}
      height={650}>
      <Window.Content scrollable>
        <Section title="Servers">
          <Box>
            {servers.length > 0
              ? "Please select a server to connect to..."
              : "Found no powered servers"}
          </Box>
          {servers.map(s => {
            return (
              <Box m={1} key={s.ref} className="ExperimentConfigure__Server">
                <Flex align="center" justify="space-between"
                  className="ExperimentConfigure__ServerHeader">
                  <Flex.Item className="ExperimentConfigure__ServerName">
                    {s.name} / {s.web_org}
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      onClick={() => s.selected
                        ? act("clear_server")
                        : act("select_server", { "ref": s.ref })}
                      content={s.selected ? "Disconnect" : "Connect"}
                      backgroundColor={s.selected ? "good" : "rgba(0, 0, 0, 0.4)"}
                      className="ExperimentConfigure__ConnectButton" />
                  </Flex.Item>
                </Flex>
                <Box className="ExperimentConfigure__ServerContent">
                  Contained TechWeb: {s.web_id} <br />
                  Location: {s.location} <br />
                </Box>
              </Box>
            );
          })}
        </Section>
        {servers.some(e => e.selected) && (
          <Section title="Experiments">
            <Box>
              {experiments.length
                ? "Select one of the following experiments..."
                : "No experiments found on this server"}
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
                    {exp.progress?.split("\n").map((line, index) => {
                      return (
                        <Fragment key={index}>
                          <span>{line}</span>
                          <br />
                        </Fragment>
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

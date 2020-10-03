import { capitalize, multiline } from "common/string";
import { useBackend } from "../backend";
import { Box, Button, Flex, Section, Table } from "../components";
import { Window } from "../layouts";

const AlertButton = (props, context) => {
  const { act, data } = useBackend(context);

  return (<Button
    icon="exclamation-triangle"
    color={data.alertLevel === props.alertLevel ? "good" : undefined}
    content={capitalize(props.alertLevel)}
  />);
};

const PageMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    alertLevel,
    canMakeAnnouncement,
    canSetAlertLevel,
    canToggleEmergencyAccess,
    emergencyAccess,
    shuttleCalled,
    shuttleCalledPreviously,
    shuttleLastCalled,
    shuttleRecallable,
  } = data;

  const children = [];
  const generalFunctions = [];

  if (canMakeAnnouncement) {
    generalFunctions.push(<Button
      icon="bullhorn"
      content="Make Priority Announcement"
    />);
  }

  if (canToggleEmergencyAccess) {
    generalFunctions.push(<Button
      icon="id-card-o"
      content={`${emergencyAccess ? "Disable" : "Enable"} Emergency Maintenance Access`}
      color={emergencyAccess ? "bad" : undefined}
    />);
  }

  generalFunctions.push(<Button
    icon="desktop"
    content="Set Status Display"
  />);

  generalFunctions.push(<Button
    icon="envelope-o"
    content="Message List"
  />);

  let emergencyShuttleButton;

  if (shuttleCalled) {
    emergencyShuttleButton = (<Button
      icon="space-shuttle"
      content="Recall Emergency Shuttle"
      color="bad"
      disabled={!shuttleRecallable}
      tooltip={shuttleRecallable ? undefined : "It's too late for the emergency shuttle to be recalled."}
      tooltipPosition="bottom-right"
    />);
  } else {
    emergencyShuttleButton = (<Button
      icon="space-shuttle"
      content="Call Emergency Shuttle"
    />);
  }

  children.push(
    <Section title="Emergency Shuttle">
      {emergencyShuttleButton}

      {shuttleCalledPreviously
        ? (
          <Box>
            {
              shuttleLastCalled
                ? `Most recent shuttle call/recall traced to: `
                  + `<b>${shuttleLastCalled}</b>`
                : "Unable to trace most recent shuttle/recall signal."
            }
          </Box>
        )
        : null}
    </Section>
  );

  if (canSetAlertLevel) {
    children.push(
      <Section title="Alert Level">
        <Flex justify="space-between">
          <Flex.Item>
            <Box>
              Currently on <b>{capitalize(alertLevel)}</b> Alert
            </Box>
          </Flex.Item>

          <Flex.Item>
            <AlertButton alertLevel="green" />
            <AlertButton alertLevel="blue" />
          </Flex.Item>
        </Flex>
      </Section>
    );
  }

  children.push(
    <Section title="Functions">
      <Table>
        {generalFunctions.map((button, index) => (
          <Table.Row key={index}>
            <Table.Cell>
              {button}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );

  return children;
};

export const CommunicationsConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    authenticated,
    authorizeName,
    canLogOut,
    page,
  } = data;

  let pageComponent = null;

  if (authenticated) {
    switch (page) {
      case "main":
        pageComponent = <PageMain />;
        break;
      default:
        pageComponent = <Box>Page not implemented: {page}</Box>;
    }
  }

  return (
    <Window resizable>
      <Window.Content scrollable>
        {(canLogOut || !authenticated)
          ? (
            <Section title="Authentication">
              <Button
                icon={authenticated ? "sign-out-alt" : "sign-in-alt"}
                content={authenticated ? `Log Out${authorizeName ? ` (${authorizeName}` : ""})` : "Log In"}
                color={authenticated ? "bad" : "good"}
                onClick={() => act("toggleAuthentication")}
              />
            </Section>
          )
          : null}

        {pageComponent}
      </Window.Content>
    </Window>
  );
};

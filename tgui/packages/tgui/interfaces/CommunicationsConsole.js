import { capitalize, multiline } from "common/string";
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Flex, Modal, Section, Table, TextArea } from "../components";
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
    callShuttleReasonMinLength,
    canMakeAnnouncement,
    canSetAlertLevel,
    canToggleEmergencyAccess,
    emergencyAccess,
    shuttleCalled,
    shuttleCalledPreviously,
    shuttleCanEvacOrFailReason,
    shuttleLastCalled,
    shuttleRecallable,
  } = data;

  const children = [];
  const generalFunctions = [];

  const [callingShuttle, setCallingShuttle] = useLocalState(context, "calling_shuttle", false);
  const [shuttleCallReason, setShuttleCallReason] = useLocalState(context, "shuttle_call_reason", "");

  if (canMakeAnnouncement) {
    generalFunctions.push(<Button
      icon="bullhorn"
      content="Make Priority Announcement"
      onClick={() => act("makePriorityAnnouncement")}
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
    emergencyShuttleButton = (<Button.Confirm
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
      disabled={shuttleCanEvacOrFailReason !== 1}
      tooltip={
        shuttleCanEvacOrFailReason !== 1
          ? shuttleCanEvacOrFailReason
          : undefined
      }
      tooltipPosition="bottom-right"
      onClick={() => {
        setShuttleCallReason("");
        setCallingShuttle(true);
      }}
    />);
  }

  if (callingShuttle) {
    const reasonLongEnough = shuttleCallReason.length
      >= callShuttleReasonMinLength;

    children.push((
      <Modal>
        <Flex direction="column">
          <Flex.Item fontSize="16px">
            Nature of emergency:
          </Flex.Item>

          <Flex.Item mr={2} mb={1}>
            <TextArea
              fluid
              height="35vh"
              width="80vw"
              backgroundColor="black"
              textColor="white"
              onInput={(_, value) => setShuttleCallReason(value)}
            />
          </Flex.Item>

          <Flex.Item>
            <Button
              icon="space-shuttle"
              content="Call Shuttle"
              color="good"
              disabled={!reasonLongEnough}
              tooltip={!reasonLongEnough ? "You need a longer call reason." : ""}
              tooltipPosition="right"
              onClick={() => {
                if (reasonLongEnough) {
                  setCallingShuttle(false);
                  act("callShuttle", {
                    reason: shuttleCallReason,
                  });
                }
              }}
            />

            <Button
              icon="times"
              content="Cancel"
              color="bad"
              onClick={() => setCallingShuttle(false)}
            />
          </Flex.Item>
        </Flex>
      </Modal>
    ));
  }

  children.push(
    <Section title="Emergency Shuttle">
      {emergencyShuttleButton}

      {shuttleCalledPreviously
        ? (
          shuttleLastCalled
            ? (
              <Box>
                Most recent shuttle call/recall traced to:
                <b>{shuttleLastCalled}</b>
              </Box>
            )
            : <Box>Unable to trace most recent shuttle/recall signal.</Box>
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
                content={authenticated ? `Log Out${authorizeName ? ` (${authorizeName})` : ""}` : "Log In"}
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

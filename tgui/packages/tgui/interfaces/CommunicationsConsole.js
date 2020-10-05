import { capitalize } from "common/string";
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Flex, Input, Modal, Section, Table, TextArea } from "../components";
import { Window } from "../layouts";
import { logger } from "../logging";

const STATE_BUYING_SHUTTLE = "buying_shuttle";
const STATE_CHANGING_STATUS = "changing_status";
const STATE_MAIN = "main";
const STATE_MESSAGES = "messages";

// Used for whether or not you need to swipe to confirm an alert level change
const SWIPE_NEEDED = "SWIPE_NEEDED";

const AlertButton = (props, context) => {
  const { act, data } = useBackend(context);
  const thisIsCurrent = data.alertLevel === props.alertLevel;
  const { alertLevelTick, canSetAlertLevel } = data;

  return (<Button
    icon="exclamation-triangle"
    color={thisIsCurrent ? "good" : undefined}
    content={capitalize(props.alertLevel)}
    onClick={thisIsCurrent ? undefined : () => {
      if (canSetAlertLevel === SWIPE_NEEDED) {
        props.setShowAlertLevelConfirm([props.alertLevel, alertLevelTick]);
      } else {
        act("changeSecurityLevel", {
          newSecurityLevel: props.alertLevel,
        });
      }
    }}
  />);
};

const PageBuyingShuttle = (props, context) => {
  const { act, data } = useBackend(context);

  const buyableShuttles = [...data.shuttles];
  buyableShuttles.sort((a, b) => a.creditCost - b.creditCost);

  const shuttles = [];

  for (const shuttle of buyableShuttles) {
    shuttles.push((
      <Section
        title={(
          <span
            style={{
              display: "inline-block",
              width: "70%",
            }}>
            {shuttle.name}
          </span>
        )}
        key={shuttle.ref}
        buttons={(
          <Button
            content={`Buy for ${shuttle.creditCost.toLocaleString()} credits`}
            disabled={data.budget < shuttle.creditCost}
            onClick={() => act("purchaseShuttle", {
              shuttle: shuttle.ref,
            })}
            tooltip={
              data.budget < shuttle.creditCost
                ? `You need ${(shuttle.creditCost - data.budget)} more credits.`
                : undefined
            }
            tooltipPosition="left"
          />
        )}>
        <Box>{shuttle.description}</Box>
        {
          shuttle.prerequisites
            ? <b>Prerequisites: {shuttle.prerequisites}</b>
            : null
        }
      </Section>
    ));
  }

  return (
    <Box>
      <Section>
        <Button
          icon="chevron-left"
          content="Back"
          onClick={() => act("setState", { state: STATE_MAIN })}
        />
      </Section>

      <Section>
        Budget: <b>{data.budget.toLocaleString()}</b> credits
      </Section>

      {shuttles}
    </Box>
  );
};

const PageChangingStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const { maxStatusLineLength } = data;

  const [lineOne, setLineOne] = useLocalState(context, "lineOne", data.lineOne);
  const [lineTwo, setLineTwo] = useLocalState(context, "lineTwo", data.lineTwo);

  return (
    <Box>
      <Section>
        <Button
          icon="chevron-left"
          content="Back"
          onClick={() => act("setState", { state: STATE_MAIN })}
        />
      </Section>

      <Section>
        <Flex direction="column">
          <Flex.Item>
            <Button
              icon="times"
              content="Clear Alert"
              color="bad"
              onClick={() => act("setStatusPicture", { picture: "blank" })}
            />
          </Flex.Item>

          <Flex.Item mt={1}>
            <Button
              icon="check-square-o"
              content="Default"
              onClick={() => act("setStatusPicture", { picture: "default" })}
            />

            <Button
              icon="bell-o"
              content="Red Alert"
              onClick={() => act("setStatusPicture", { picture: "redalert" })}
            />

            <Button
              icon="exclamation-triangle"
              content="Lockdown"
              onClick={() => act("setStatusPicture", { picture: "lockdown" })}
            />

            <Button
              icon="exclamation-circle"
              content="Biohazard"
              onClick={() => act("setStatusPicture", { picture: "biohazard" })}
            />

            <Button
              icon="space-shuttle"
              content="Shuttle ETA"
              onClick={() => act("setStatusPicture", { picture: "shuttle" })}
            />
          </Flex.Item>
        </Flex>
      </Section>

      <Section title="Message">
        <Flex direction="column">
          <Flex.Item mb={1}>
            <Input
              maxLength={maxStatusLineLength}
              value={lineOne}
              width="200px"
              onChange={(_, value) => setLineOne(value)}
            />
          </Flex.Item>

          <Flex.Item mb={1}>
            <Input
              maxLength={maxStatusLineLength}
              value={lineTwo}
              width="200px"
              onChange={(_, value) => setLineTwo(value)}
            />
          </Flex.Item>

          <Flex.Item>
            <Button
              icon="comment-o"
              content="Message"
              onClick={() => act("setStatusMessage", {
                lineOne,
                lineTwo,
              })}
            />
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const PageMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    alertLevel,
    alertLevelTick,
    callShuttleReasonMinLength,
    canBuyShuttles,
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
  const [
    [showAlertLevelConfirm, confirmingAlertLevelTick],
    setShowAlertLevelConfirm,
  ] = useLocalState(context, "showConfirmPrompt", [null, null]);

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
    onClick={() => act("setState", { state: STATE_CHANGING_STATUS })}
  />);

  generalFunctions.push(<Button
    icon="envelope-o"
    content="Message List"
    onClick={() => act("setState", { state: STATE_MESSAGES })}
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
      onClick={() => act("recallShuttle")}
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

  if (canBuyShuttles !== 0) {
    generalFunctions.push(<Button
      icon="shopping-cart"
      content="Purchase Shuttle"
      disabled={canBuyShuttles !== 1}
      // canBuyShuttles is a string detailing the fail reason
      // if one can be given
      tooltip={canBuyShuttles !== 1 ? canBuyShuttles : undefined}
      tooltipPosition="right"
      onClick={() => act("setState", { state: STATE_BUYING_SHUTTLE })}
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
                {" "}<b>{shuttleLastCalled}</b>
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
            <AlertButton
              alertLevel="green"
              showAlertLevelConfirm={showAlertLevelConfirm}
              setShowAlertLevelConfirm={setShowAlertLevelConfirm}
            />

            <AlertButton
              alertLevel="blue"
              showAlertLevelConfirm={showAlertLevelConfirm}
              setShowAlertLevelConfirm={setShowAlertLevelConfirm}
            />
          </Flex.Item>
        </Flex>
      </Section>
    );

    if (showAlertLevelConfirm && confirmingAlertLevelTick === alertLevelTick) {
      children.push(
        <Modal>
          <Flex
            direction="column"
            textAlign="center"
            width="300px">
            <Flex.Item fontSize="16px" mb={2}>
              Swipe ID to confirm change
            </Flex.Item>

            <Flex.Item mr={2} mb={1}>
              <Button
                icon="id-card-o"
                content="Swipe ID"
                color="good"
                fontSize="16px"
                onClick={() => act("changeSecurityLevel", {
                  newSecurityLevel: showAlertLevelConfirm,
                })}
              />

              <Button
                icon="times"
                content="Cancel"
                color="bad"
                fontSize="16px"
                onClick={() => setShowAlertLevelConfirm(false)}
              />
            </Flex.Item>
          </Flex>
        </Modal>
      );
    }
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

const PageMessages = (props, context) => {
  const { act, data } = useBackend(context);
  const messages = data.messages || [];

  const children = [];

  children.push((
    <Section>
      <Button
        icon="chevron-left"
        content="Back"
        onClick={() => act("setState", { state: STATE_MAIN })}
      />
    </Section>
  ));

  const messageElements = [];

  for (const [messageIndex, message] of Object.entries(messages)) {
    let answers = null;

    if (message.possibleAnswers.length > 0) {
      answers = (
        <Box mt={1}>
          {message.possibleAnswers.map((answer, answerIndex) => (
            <Button
              content={answer}
              color={message.answered === answerIndex + 1 ? "good" : undefined}
              key={answerIndex}
              onClick={message.answered ? undefined : () => act("answerMessage", {
                message: messageIndex + 1,
                answer: answerIndex + 1,
              })}
            />
          ))}
        </Box>
      );
    }

    messageElements.push((
      <Section title={message.title} key={messageIndex}>
        <Box>{message.content}</Box>

        {answers}
      </Section>
    ));
  }

  children.push(messageElements.reverse());

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
      case STATE_BUYING_SHUTTLE:
        pageComponent = <PageBuyingShuttle />;
        break;
      case STATE_CHANGING_STATUS:
        pageComponent = <PageChangingStatus />;
        break;
      case STATE_MAIN:
        pageComponent = <PageMain />;
        break;
      case STATE_MESSAGES:
        pageComponent = <PageMessages />;
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

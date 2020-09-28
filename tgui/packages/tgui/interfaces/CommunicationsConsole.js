import { useBackend } from "../backend";
import { Box, Button, LabeledList, Section } from "../components";
import { Window } from "../layouts";

const PageMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    canMakeAnnouncement,
  } = data;

  const children = [];

  if (canMakeAnnouncement) {
    children.push(<Box>
      <Button
        icon="bullhorn"
        content="Make Priority Announcement"
      />
    </Box>);
  }

  return children;
}

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
          ? <Section title="Authentication">
            <Button
              icon={authenticated ? "sign-out-alt" : "sign-in-alt"}
              content={authenticated ? `Log Out${authorizeName ? ` (${authorizeName}` : ""})` : "Log In"}
              color={authenticated ? "bad" : "good"}
            />
          </Section>
          : null}

        {pageComponent}
      </Window.Content>
    </Window>
  );
};

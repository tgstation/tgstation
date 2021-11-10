import { BooleanLike } from "common/react";
import { useBackend, useLocalState } from "../backend";
import { TextArea, Stack, Button, NoticeBox } from "../components";
import { Window } from "../layouts";

type AdminhelpData = {
  adminCount: number,
  bannedFromUrgentAhelp: BooleanLike
}

export const Adminhelp = (props, context) => {
  const { act, data } = useBackend<AdminhelpData>(context);
  const {
    adminCount,
    bannedFromUrgentAhelp,
  } = data;
  const [requestforadmin, setRequestForAdmin] = useLocalState(context, "requestforadmin", false);
  const [ahelpMessage, setAhelpMessage] = useLocalState(context, "ahelp_message", "");
  return (
    <Window
      title="Create Adminhelp"
      theme="admin"
      height={300}
      width={500}>
      <Window.Content style={{
        "background-image": "none",
      }}>
        <Stack vertical fill>
          <Stack.Item grow>
            <TextArea
              height="100%"
              value={ahelpMessage}
              placeholder="Admin help"
              onChange={(e, value) => setAhelpMessage(value)}
            />
          </Stack.Item>
          {adminCount <= 0 && (
            <Stack.Item>
              <NoticeBox info>
                There are no admins currently on.
                Do not press the button below if your ahelp is
                a joke or a request, use it only for cases of rulebreak.
                <Button
                  mt={1}
                  content="Request an admin?"
                  onClick={() => setRequestForAdmin(!requestforadmin)}
                  icon={requestforadmin? 'check-square-o' : 'square-o'}
                  disabled={bannedFromUrgentAhelp}
                  fluid
                  textAlign="center"
                  tooltip="Examples of bad ahelps to use this button for: TC trades, joke ahelps, "
                />
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Button
              color="good"
              fluid
              content="Submit"
              textAlign="center"
              onClick={() => act("ahelp", {
                urgent: requestforadmin,
                message: ahelpMessage,
              })}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>

  );
};

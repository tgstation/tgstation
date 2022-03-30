import { useBackend, useLocalState } from "../../backend";
import { logger } from "../../logging";
import { Box, Button, Divider } from "../../components";
import { ListMapper } from "./ListMapper";

export const Log = (props, context) => {
  const { act, data } = useBackend(context);
  const { stateLog } = data;
  const [, setViewedChunk] = useLocalState(context, "viewedChunk");
  const [, setModal] = useLocalState(context, "modal");
  // We only kvpify logs so that the return values are kvpified.
  const mappedLog = stateLog.map(({ value }) => value);
  return (
    mappedLog.map((element, i) => {
      const { name, status, param, chunk } = element;
      let message;
      let messageColor;
      switch (status) {
        case "sleeping":
          if (chunk) {
            messageColor = "blue";
            message = (
              <>
                <b>{name}</b> slept.
              </>
            );
          }
          break;
        case "yielded":
          message = (
            <>
              <b>{name}</b> yielded.
              <ListMapper
                list={param}
                skipNulls
                name="Return Value"
                collapsible
                vvAct={(path) => act("vvReturnValue", {
                  entryIndex: i+1,
                  tableIndices: path,
                })} />
            </>
          );
          messageColor = "yellow";
          break;
        case "finished":
          message = (
            <>
              <b>{name}</b> returned.
              <ListMapper
                list={param}
                skipNulls
                name="Return Value"
                collapsible
                vvAct={(path) => act("vvReturnValue", {
                  entryIndex: i+1,
                  tableIndices: path,
                })} />
            </>
          );
          messageColor = "green";
          break;
        case "errored":
          message = (
            <>
              <b>{name}</b> errored with the message &quot;{param}&quot;
            </>
          );
          messageColor = "red";
          break;
        default:
          logger.warn(`unknown log status ${status}`);
      }
      if (message === undefined) {
        return;
      }
      if (chunk) {
        message = (
          <>
            {message}
            <Button
              onClick={() => {
                setViewedChunk(chunk);
                setModal("viewChunk");
              }}>
              View Source
            </Button>
          </>
        );
      }
      return (
        <>
          {i > 0 && <Divider />}
          <Box
            width="100%"
            key={i}
            color={messageColor}>
            {message}
          </Box>
        </>
      );
    })
  );
};

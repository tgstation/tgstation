import { useBackend, useLocalState } from "../../backend";
import { Box, Button, Flex, Section, Tabs, TextArea, Modal } from "../../components";
import { Window } from "../../layouts";
import { CallModal } from "./CallModal";
import { ChunkViewModal } from "./ChunkViewModal";
import { StateSelectModal } from "./StateSelectModal";
import { ListMapper } from "./ListMapper";
import { Log } from "./Log";
import { TaskManager } from "./TaskManager";
import { sanitizeText } from "../../sanitize";

export const LuaEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const { noStateYet, importedCode, globals, documentation } = data;
  const [
    modal,
    setModal,
  ] = useLocalState(context, "modal", "states");
  const [activeTab, setActiveTab] = useLocalState(context, "activeTab", "globals");
  const [input, setInput] = useLocalState(context, "scriptInput", "");
  if (importedCode) {
    setInput(importedCode);
  }
  let tabContent;
  switch (activeTab) {
    case "globals": {
      tabContent = (
        <ListMapper
          list={globals}
          skipNulls
          vvAct={(path) => act("vvGlobal", { indices: path })}
          callType="callFunction" />
      );
      break;
    }
    case "tasks": {
      tabContent = <TaskManager />;
      break;
    }
    case "log": {
      tabContent = <Log />;
      break;
    }
  }
  return (
    <Window
      width={800}
      height={600} >
      <Window.Content>
        <Button
          icon="file"
          onClick={() => setModal("states")}>
          States
        </Button>
        {noStateYet ? (
          <Flex
            width="100%"
            height="100%"
            align="center"
            justify="space-around">
            <h1>
              Please select or create a lua state to get started.
            </h1>
          </Flex>
        ) : (
          <Section fill title="Input" buttons={(
            <>
              <Button onClick={() => act("loadCode")} >
                Import
              </Button>
              <Button onClick={() => setModal("documentation")}>
                Help
              </Button>
            </>
          )} >
            <TextArea
              fluid
              width="750px"
              height="400px"
              value={importedCode || input}
              onInput={(_, value) => setInput(value)} />
            <Button onClick={() => act("runCode", { code: input })} >
              Run
            </Button>
            <Section width="100%">
              <Tabs>
                <Tabs.Tab
                  selected={activeTab === "globals"}
                  onClick={() => {
                    setActiveTab("globals");
                  }}>
                  Globals
                </Tabs.Tab>
                <Tabs.Tab
                  selected={activeTab === "tasks"}
                  onClick={() => setActiveTab("tasks")}>
                  Tasks
                </Tabs.Tab>
                <Tabs.Tab
                  selected={activeTab === "log"}
                  onClick={() => {
                    setActiveTab("log");
                  }}>
                  Log
                </Tabs.Tab>
              </Tabs>
              <Section width="100%">
                {tabContent}
              </Section>
            </Section>
          </Section>
        )}
      </Window.Content>
      {modal === "states" && (
        <StateSelectModal />
      )}
      {modal === "viewChunk" && (
        <ChunkViewModal />
      )}
      {modal === "call" && (
        <CallModal />
      )}
      {modal === "documentation" && (
        <Modal>
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(null);
            }}>
            Close
          </Button>
          <Section
            height="500px"
            width="700px"
            fill
            scrollable>
            <Box
              dangerouslySetInnerHtml={
                { __html: sanitizeText(documentation) }
              } />
          </Section>
        </Modal>
      )}
    </Window>
  );
};

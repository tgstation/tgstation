import { useBackend, useLocalState } from "../../backend";
import { Button, Flex, Section, Tabs, TextArea } from "../../components";
import { Window } from "../../layouts";
import { CallModal } from "./CallModal";
import { ChunkViewModal } from "./ChunkViewModal";
import { ContextSelectModal } from "./ContextSelectModal";
import { ListMapper } from "./ListMapper";
import { Log } from "./Log";
import { TaskManager } from "./TaskManager";

export const LuaEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const { noContextYet, importedCode, globals } = data;
  const [
    modal,
    setModal,
  ] = useLocalState(context, "modal", "contexts");
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
          onClick={() => setModal("contexts")}>
          Contexts
        </Button>
        {noContextYet ? (
          <Flex
            align="center"
            justify="space-evenly">
            Please select or create a lua context to get started.
          </Flex>
        ) : (
          <Section fill title="Input">
            <Section buttons={(
              <Button onClick={() => act("loadCode")} >
                Import
              </Button>
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
            </Section>
            <Section>
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
              <Section width="100%" scrollable>
                {tabContent}
              </Section>
            </Section>
          </Section>
        )}
      </Window.Content>
      {modal === "contexts" && (
        <ContextSelectModal />
      )}
      {modal === "viewChunk" && (
        <ChunkViewModal />
      )}
      {modal === "call" && (
        <CallModal />
      )}
    </Window>
  );
};

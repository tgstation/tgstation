import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Flex, Section, Tabs, TextArea, Modal, Stack } from '../../components';
import { Window } from '../../layouts';
import { CallModal } from './CallModal';
import { ChunkViewModal } from './ChunkViewModal';
import { StateSelectModal } from './StateSelectModal';
import { ListMapper } from './ListMapper';
import { Log } from './Log';
import { TaskManager } from './TaskManager';
import { sanitizeText } from '../../sanitize';
import { marked } from 'marked';
import hljs from 'highlight.js/lib/core';
import lua from 'highlight.js/lib/languages/lua';
hljs.registerLanguage('lua', lua);

export const LuaEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const { noStateYet, globals, documentation, tasks } = data;
  const [modal, setModal] = useLocalState(
    context,
    'modal',
    noStateYet ? 'states' : null
  );
  const [activeTab, setActiveTab] = useLocalState(
    context,
    'activeTab',
    'globals'
  );
  const [input, setInput] = useLocalState(context, 'scriptInput', '');
  let tabContent;
  switch (activeTab) {
    case 'globals': {
      if (!globals) {
        tabContent = (
          <h1>
            Could not retrieve the global table. Was it corrupted or shadowed?
          </h1>
        );
      } else {
        tabContent = (
          <ListMapper
            list={globals}
            skipNulls
            vvAct={(path) => act('vvGlobal', { indices: path })}
            callType="callFunction"
          />
        );
      }
      break;
    }
    case 'tasks': {
      if (!tasks) {
        tabContent = (
          <h1>
            Could not retrieve task info. Was the global table corrupted or
            shadowed?
          </h1>
        );
      } else {
        tabContent = <TaskManager />;
      }
      break;
    }
    case 'log': {
      tabContent = <Log />;
      break;
    }
  }
  return (
    <Window width={1280} height={720}>
      <Window.Content>
        <Button icon="file" onClick={() => setModal('states')}>
          States
        </Button>
        {noStateYet ? (
          <Flex
            width="100%"
            height="100%"
            align="center"
            justify="space-around">
            <h1>Please select or create a lua state to get started.</h1>
          </Flex>
        ) : (
          <Stack>
            <Stack.Item>
              <Section
                fill
                title="Input"
                buttons={
                  <>
                    <Button.File
                      onSelectFiles={(file) => setInput(file)}
                      accept=".lua,.luau">
                      Import
                    </Button.File>
                    <Button onClick={() => setModal('documentation')}>
                      Help
                    </Button>
                  </>
                }>
                <TextArea
                  fluid
                  width="700px"
                  height="590px"
                  value={input}
                  fontFamily="Consolas"
                  onInput={(_, value) => setInput(value)}
                  displayedValue={
                    <Box
                      style={{
                        'pointer-events': 'none',
                      }}
                      dangerouslySetInnerHTML={{
                        __html: hljs.highlight(input, { language: 'lua' })
                          .value,
                      }}
                    />
                  }
                />
                <Button onClick={() => act('runCode', { code: input })}>
                  Run
                </Button>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill height="95%" width="100%">
                <Tabs>
                  <Tabs.Tab
                    selected={activeTab === 'globals'}
                    onClick={() => {
                      setActiveTab('globals');
                    }}>
                    Globals
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={activeTab === 'tasks'}
                    onClick={() => setActiveTab('tasks')}>
                    Tasks
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={activeTab === 'log'}
                    onClick={() => {
                      setActiveTab('log');
                    }}>
                    Log
                  </Tabs.Tab>
                </Tabs>
                <Section fill scrollable scrollableHorizontal width="100%">
                  {tabContent}
                </Section>
              </Section>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
      {modal === 'states' && <StateSelectModal />}
      {modal === 'viewChunk' && <ChunkViewModal />}
      {modal === 'call' && <CallModal />}
      {modal === 'documentation' && (
        <Modal>
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(null);
            }}>
            Close
          </Button>
          <Section height="500px" width="700px" fill scrollable>
            <Box
              dangerouslySetInnerHTML={{
                __html: marked(sanitizeText(documentation), {
                  breaks: true,
                  smartypants: true,
                  smartLists: true,
                  langPrefix: 'hljs language-',
                  highlight: (code) => {
                    return hljs.highlight(code, { language: 'lua' }).value;
                  },
                }),
              }}
            />
          </Section>
        </Modal>
      )}
    </Window>
  );
};

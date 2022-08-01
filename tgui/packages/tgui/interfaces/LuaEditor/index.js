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
import { Component, createRef } from 'inferno';
import hljs from 'highlight.js/lib/core';
import lua from 'highlight.js/lib/languages/lua';
hljs.registerLanguage('lua', lua);

export class LuaEditor extends Component {
  constructor(props) {
    super(props);
    this.sectionRef = createRef();
    this.state = {
      showJumpToBottomButton: false,
    };

    this.handleSectionScroll = () => {
      const scrollableCurrent = this.sectionRef.current?.scrollableRef.current;
      if (
        !this.state.showJumpToBottomButton &&
        scrollableCurrent?.scrollHeight >
          scrollableCurrent?.scrollTop + scrollableCurrent?.clientHeight
      ) {
        this.setState({ showJumpToBottomButton: true });
      } else if (
        this.state.showJumpToBottomButton &&
        scrollableCurrent?.scrollTop + scrollableCurrent?.clientHeight >=
          scrollableCurrent?.scrollHeight
      ) {
        this.setState({ showJumpToBottomButton: false });
      }
    };

    window.addEventListener('resize', () =>
      this.forceUpdate(this.handleSectionScroll)
    );
  }

  render() {
    const { act, data } = useBackend(this.context);
    const { noStateYet, globals, documentation, tasks } = data;
    const [modal, setModal] = useLocalState(
      this.context,
      'modal',
      noStateYet ? 'states' : null
    );
    const [activeTab, setActiveTab] = useLocalState(
      this.context,
      'activeTab',
      'globals'
    );
    const [input, setInput] = useLocalState(this.context, 'scriptInput', '');
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
            <Stack height="calc(100% - 16px)">
              <Stack.Item grow shrink basis="55%">
                <Section
                  fill
                  pb="16px"
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
                    width="100%"
                    height="100%"
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
              <Stack.Item grow shrink basis="45%">
                <Section
                  fill
                  pb="24px"
                  height={
                    this.state.showJumpToBottomButton
                      ? 'calc(100% - 32px)'
                      : '100%'
                  }
                  width="100%">
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
                  <Section
                    ref={this.sectionRef}
                    fill
                    scrollable
                    scrollableHorizontal
                    onScroll={this.handleSectionScroll}
                    width="100%">
                    {tabContent}
                  </Section>
                  {this.state.showJumpToBottomButton && (
                    <Button
                      width="100%"
                      onClick={() => {
                        const sectionCurrent = this.sectionRef.current;
                        const scrollableCurrent =
                          sectionCurrent.scrollableRef.current;
                        scrollableCurrent.scrollTop =
                          scrollableCurrent.scrollHeight;
                      }}>
                      Jump to Bottom
                    </Button>
                  )}
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
            <Section
              height={`${window.innerHeight * 0.8}px`}
              width={`${window.innerWidth * 0.5}px`}
              fill
              scrollable>
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
  }
}

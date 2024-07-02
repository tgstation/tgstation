import hljs from 'highlight.js/lib/core';
import lua from 'highlight.js/lib/languages/lua';
import { Component, createRef, RefObject } from 'react';

import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Flex,
  MenuBar,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  TextArea,
} from '../../components';
import { Window } from '../../layouts';
import { CallModal } from './CallModal';
import { ChunkViewModal } from './ChunkViewModal';
import { ListMapper } from './ListMapper';
import { Log } from './Log';
import { StateSelectModal } from './StateSelectModal';
import { TaskManager } from './TaskManager';
hljs.registerLanguage('lua', lua);

type Modal = 'states' | 'viewChunk' | 'call' | undefined;

export type VariantList = ({
  key: Variant | null;
  value?: Variant | null;
} | null)[];

type ParameterizedVariant =
  | ['list', VariantList]
  | ['cycle', [number, 'key' | 'value'][]]
  | ['ref', string];

export type Variant =
  | 'error'
  | 'function'
  | 'thread'
  | 'userdata'
  | 'error_as_value'
  | ParameterizedVariant
  | null;

type LuaGlobals = {
  values: { key: any; value: any }[];
  variants: VariantList;
};

type LuaTasks = {
  sleeps: string[];
  yields: string[];
};

type LuaEditorData = {
  forceModal: Modal;
  forceViewChunk?: string;
  forceInput?: string;
  noStateYet: boolean;
  page: number;
  pageCount: number;
  lastError?: string;
  showGlobalTable: boolean;
  globals: LuaGlobals;
  tasks: LuaTasks;
};

type LuaEditorState = {
  showJumpToBottomButton: boolean;
  activeTab: 'tasks' | 'log' | 'globals';
  scriptInput: string;
  openOnHover: boolean;
  openMenuBar: string | null;
};

export class LuaEditor extends Component<unknown, LuaEditorState> {
  sectionRef: RefObject<HTMLDivElement>;
  fileInputRef: RefObject<HTMLInputElement>;
  saveButtonRef: RefObject<HTMLAnchorElement>;
  handleSectionScroll: () => void;

  constructor(props) {
    super(props);
    this.sectionRef = createRef();
    this.fileInputRef = createRef();
    this.saveButtonRef = createRef();
    this.state = {
      showJumpToBottomButton: false,
      activeTab: 'tasks',
      scriptInput: '',
      openOnHover: false,
      openMenuBar: null,
    };

    this.handleSectionScroll = () => {
      const { showJumpToBottomButton } = this.state;
      const scrollableCurrent = this.sectionRef.current;
      if (scrollableCurrent) {
        if (
          !showJumpToBottomButton &&
          scrollableCurrent.scrollHeight >
            scrollableCurrent.scrollTop + scrollableCurrent.clientHeight
        ) {
          this.setState({ showJumpToBottomButton: true });
        } else if (
          showJumpToBottomButton &&
          scrollableCurrent.scrollTop + scrollableCurrent.clientHeight >=
            scrollableCurrent.scrollHeight
        ) {
          this.setState({ showJumpToBottomButton: false });
        }
      }
    };

    window.addEventListener('resize', () =>
      this.forceUpdate(this.handleSectionScroll),
    );
  }

  componentDidMount() {
    const { data } = useBackend<LuaEditorData>();
    const { forceModal, forceViewChunk, forceInput } = data;
    if (forceModal || forceViewChunk) {
      const [, setModal] = useLocalState<Modal>('modal', undefined);
      const [, setViewedChunk] = useLocalState<string | undefined>(
        'viewedChunk',
        undefined,
      );
      setModal(forceModal);
      setViewedChunk(forceViewChunk);
    }
    if (forceInput) {
      this.setState({ scriptInput: forceInput });
    }
  }

  componentDidUpdate() {
    this.handleSectionScroll();
  }

  render() {
    const { act, data } = useBackend<LuaEditorData>();
    const {
      noStateYet,
      globals,
      tasks,
      showGlobalTable,
      page,
      pageCount,
      lastError,
    } = data;
    const [modal, setModal] = useLocalState(
      'modal',
      noStateYet ? 'states' : null,
    );
    const {
      activeTab,
      showJumpToBottomButton,
      scriptInput,
      openMenuBar,
      openOnHover,
    } = this.state;
    const { fileInputRef, saveButtonRef } = this;
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
          const { values, variants } = globals;
          tabContent = (
            <ListMapper
              list={values}
              variants={variants}
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
          tabContent = <h1>Could not retrieve task info.</h1>;
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

    const menuBarProps = {
      openMenuBar: openMenuBar,
      setOpenMenuBar: (entry) => this.setState({ openMenuBar: entry }),
      openOnHover: openOnHover,
      setOpenOnHover: (openOnHover) =>
        this.setState({ openOnHover: openOnHover }),
    };

    const closeMenuAndThen = (func?: () => void) => {
      return () => {
        this.setState({
          openMenuBar: null,
          openOnHover: false,
        });
        func?.();
      };
    };

    return (
      <Window width={1280} height={720}>
        <Window.Content>
          <input
            type="file"
            hidden
            accept=".lua,.luau"
            ref={fileInputRef}
            onChange={async (event) => {
              if (event.target.files?.length) {
                this.setState({
                  scriptInput: await event.target.files[0].text(),
                });
                event.target.value = '';
              }
            }}
          />
          <a hidden download ref={saveButtonRef} />
          <MenuBar>
            <MenuBar.Dropdown
              entry="file"
              openWidth="22rem"
              display="File"
              {...menuBarProps}
            >
              <MenuBar.Dropdown.MenuItem
                displayText="States"
                onClick={closeMenuAndThen(() => {
                  setModal('states');
                })}
              />
              <MenuBar.Dropdown.MenuItem
                displayText="Open"
                onClick={closeMenuAndThen(() => fileInputRef.current?.click())}
              />
              <MenuBar.Dropdown.MenuItem
                displayText="Save"
                onClick={closeMenuAndThen(() => {
                  if (saveButtonRef.current) {
                    const outFile = new File([scriptInput], 'script.lua');
                    let outUrl = URL.createObjectURL(outFile);
                    saveButtonRef.current.href = outUrl;
                    saveButtonRef.current.click();
                    URL.revokeObjectURL(outUrl);
                  }
                })}
              />
              <MenuBar.Dropdown.MenuItem
                displayText="Run"
                onClick={closeMenuAndThen(() => act('runFile'))}
              />
            </MenuBar.Dropdown>
          </MenuBar>
          {noStateYet ? (
            <Flex
              width="100%"
              height="100%"
              align="center"
              justify="space-around"
            >
              <h1>Please select or create a lua state to get started.</h1>
            </Flex>
          ) : (
            <Stack height="calc(100% - 16px)">
              <Stack.Item grow shrink basis="55%">
                <Stack fill vertical>
                  <Stack.Item shrink basis="100%">
                    <Section fill pb="16px">
                      <TextArea
                        fluid
                        width="100%"
                        height="100%"
                        value={scriptInput}
                        fontFamily="Consolas"
                        onChange={(_, value) =>
                          this.setState({ scriptInput: value })
                        }
                        /* displayedValue={
                          <Box
                            style={{
                              pointerEvents: 'none',
                            }}
                            dangerouslySetInnerHTML={{
                              __html: hljs.highlight(scriptInput, {
                                language: 'lua',
                              }).value,
                            }}
                          />
                        }*/
                        onDrop={async (
                          event: React.DragEvent<HTMLDivElement>,
                        ) => {
                          if (event.dataTransfer?.files.length) {
                            event.preventDefault();
                            this.setState({
                              scriptInput:
                                await event.dataTransfer.files[0].text(),
                            });
                          }
                        }}
                      />
                      <Button
                        onClick={() => act('runCode', { code: scriptInput })}
                      >
                        Run
                      </Button>
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box bold textColor="red" mb="1rem">
                      {lastError}
                    </Box>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item grow shrink basis="45%">
                <Section fill pb="24px" height="100%" width="100%">
                  <Stack justify="space-between">
                    <Stack.Item>
                      <Tabs>
                        {!!showGlobalTable && (
                          <Tabs.Tab
                            selected={activeTab === 'globals'}
                            onClick={() => {
                              this.setState({ activeTab: 'globals' });
                            }}
                          >
                            Globals
                          </Tabs.Tab>
                        )}
                        <Tabs.Tab
                          selected={activeTab === 'tasks'}
                          onClick={() => this.setState({ activeTab: 'tasks' })}
                        >
                          Tasks
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={activeTab === 'log'}
                          onClick={() => {
                            this.setState({ activeTab: 'log' });
                            setTimeout(this.handleSectionScroll, 0);
                          }}
                        >
                          Log
                        </Tabs.Tab>
                      </Tabs>
                    </Stack.Item>
                    <Stack.Item>
                      <Button.Checkbox
                        inline
                        checked={showGlobalTable}
                        tooltip="WARNING: Displaying the global table can cause significant lag for the entire server, especially when there is a large number of global variables."
                        onClick={() => {
                          if (showGlobalTable && activeTab === 'globals') {
                            this.setState({ activeTab: 'tasks' });
                          }
                          act('toggleShowGlobalTable');
                        }}
                      >
                        Show Global Table
                      </Button.Checkbox>
                    </Stack.Item>
                  </Stack>
                  <Stack fill vertical>
                    <Stack.Item grow>
                      <Box position="relative" width="100%" height="100%">
                        <Section
                          ref={this.sectionRef}
                          fill
                          scrollable
                          scrollableHorizontal
                          onScroll={this.handleSectionScroll}
                          buttons={
                            activeTab === 'log' && (
                              <Button.Confirm
                                inline
                                color="red"
                                tooltip="Delete All Logs"
                                icon="trash-alt"
                                confirmIcon="trash-alt"
                                confirmContent={null}
                                onClick={() => act('nukeLog')}
                              />
                            )
                          }
                          width="100%"
                        >
                          {tabContent}
                        </Section>
                        {activeTab === 'log' && showJumpToBottomButton && (
                          <Stack fill justify="space-around" bottom="2rem">
                            <Stack.Item>
                              <Button
                                position="absolute"
                                icon="arrow-down"
                                onClick={() => {
                                  const sectionCurrent =
                                    this.sectionRef.current;
                                  if (sectionCurrent) {
                                    sectionCurrent.scrollTop =
                                      sectionCurrent.scrollHeight;
                                  }
                                }}
                              >
                                Jump to Bottom
                              </Button>
                            </Stack.Item>
                          </Stack>
                        )}
                      </Box>
                    </Stack.Item>
                    {activeTab === 'log' && pageCount > 1 && (
                      <Stack.Item>
                        <Stack justify="space-between">
                          <Stack.Item width="25%">
                            <Button
                              width="100%"
                              align="center"
                              icon="arrow-left"
                              disabled={page <= 0}
                              onClick={() => {
                                act('previousPage');
                              }}
                            />
                          </Stack.Item>
                          <Stack.Item width="50%">
                            <ProgressBar
                              width="100%"
                              value={page / (pageCount - 1)}
                            >
                              <Box width="100%" align="center">
                                {`Page ${page + 1}/${pageCount}`}
                              </Box>
                            </ProgressBar>
                          </Stack.Item>
                          <Stack.Item width="25%">
                            <Button
                              width="100%"
                              align="center"
                              icon="arrow-right"
                              disabled={page >= pageCount - 1}
                              onClick={() => {
                                act('nextPage');
                              }}
                            />
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    )}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          )}
        </Window.Content>
        {modal === 'states' && <StateSelectModal />}
        {modal === 'viewChunk' && <ChunkViewModal />}
        {modal === 'call' && <CallModal />}
      </Window>
    );
  }
}

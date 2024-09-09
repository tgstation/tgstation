import 'blob-polyfill';

import hljs from 'highlight.js/lib/core';
import lua from 'highlight.js/lib/languages/lua';
import {
  ReactNode,
  useCallback,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from 'react';

import { useBackend } from '../../backend';
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
import { CallInfo, LuaEditorData, LuaEditorModal } from './types';
hljs.registerLanguage('lua', lua);

export const LuaEditor = () => {
  const { act, data } = useBackend<LuaEditorData>();
  const {
    noStateYet,
    globals,
    tasks,
    showGlobalTable,
    page,
    pageCount,
    lastError,
    supressRuntimes,
  } = data;

  const modalState = useState<LuaEditorModal>(
    noStateYet ? 'states' : undefined,
  );
  const [modal, setModal] = modalState;
  const [activeTab, setActiveTab] = useState<'tasks' | 'log' | 'globals'>(
    'log',
  );
  const [showJumpToBottomButton, setShowJumpToBottomButton] =
    useState<boolean>();
  const [scriptInput, setScriptInput] = useState<string>('');
  const [openMenuBar, setOpenMenuBar] = useState<string | null>(null);
  const [openOnHover, setOpenOnHover] = useState<boolean>(false);

  const [viewedChunk, setViewedChunk] = useState<string>();

  const [toCall, setToCall] = useState<CallInfo>();

  const sectionRef = useRef<HTMLDivElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useLayoutEffect(() => {
    const { data } = useBackend<LuaEditorData>();
    const { forceModal, forceViewChunk, forceInput } = data;
    if (forceModal || forceViewChunk) {
      setModal(forceModal);
      setViewedChunk(forceViewChunk);
    }
    if (forceInput) {
      setScriptInput(forceInput);
    }
  }, []);

  const handleSectionScroll = useCallback(() => {
    const scrollableCurrent = sectionRef.current;
    if (scrollableCurrent) {
      const { scrollHeight, scrollTop, clientHeight } = scrollableCurrent;
      if (!showJumpToBottomButton && scrollHeight > scrollTop + clientHeight) {
        setShowJumpToBottomButton(true);
      } else if (
        showJumpToBottomButton &&
        scrollTop + clientHeight >= scrollHeight
      ) {
        setShowJumpToBottomButton(false);
      }
    }
  }, [showJumpToBottomButton, sectionRef]);

  useEffect(handleSectionScroll);

  useLayoutEffect(() => {
    handleSectionScroll();
    window.addEventListener('resize', handleSectionScroll);
    return () => window.removeEventListener('resize', handleSectionScroll);
  }, [handleSectionScroll]);

  let tabContent: ReactNode;
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
            setToCall={setToCall}
            setModal={setModal}
          />
        );
      }
      break;
    }
    case 'tasks': {
      if (!tasks) {
        tabContent = <h1>Could not retrieve task info.</h1>;
      } else {
        tabContent = <TaskManager setModal={setModal} setToCall={setToCall} />;
      }
      break;
    }
    case 'log': {
      tabContent = <Log setViewedChunk={setViewedChunk} setModal={setModal} />;
      break;
    }
  }

  const menuBarProps = {
    openMenuBar: openMenuBar,
    setOpenMenuBar: setOpenMenuBar,
    openOnHover: openOnHover,
    setOpenOnHover: setOpenOnHover,
  };

  const closeMenuAndThen = (func?: () => void) => {
    return () => {
      setOpenMenuBar(null);
      setOpenOnHover(false);
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
              setScriptInput(await event.target.files[0].text());
              event.target.value = '';
            }
          }}
        />
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
              displayText="Upload and Run"
              onClick={closeMenuAndThen(() => act('runCodeFile'))}
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
                <Stack.Item grow>
                  <Section fill>
                    <Stack fill vertical>
                      <Stack.Item grow>
                        <TextArea
                          fluid
                          width="100%"
                          height="100%"
                          value={scriptInput}
                          fontFamily="Consolas"
                          onChange={(_, value) => setScriptInput(value)}
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
                              setScriptInput(
                                await event.dataTransfer.files[0].text(),
                              );
                            }
                          }}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          onClick={() => act('runCode', { code: scriptInput })}
                        >
                          Run
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
                <Stack.Item>
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
                            setActiveTab('globals');
                          }}
                        >
                          Globals
                        </Tabs.Tab>
                      )}
                      <Tabs.Tab
                        selected={activeTab === 'tasks'}
                        onClick={() => setActiveTab('tasks')}
                      >
                        Tasks
                      </Tabs.Tab>
                      <Tabs.Tab
                        selected={activeTab === 'log'}
                        onClick={() => {
                          setActiveTab('log');
                          setTimeout(handleSectionScroll, 0);
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
                          setActiveTab('tasks');
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
                    <Section
                      title={<Box height="1rem" width="1rem" />}
                      ref={sectionRef}
                      fill
                      scrollable
                      scrollableHorizontal
                      onScroll={handleSectionScroll}
                      buttons={
                        activeTab === 'log' && (
                          <Box position="relative" bottom="1.25rem">
                            <Button.Checkbox
                              checked={supressRuntimes}
                              onClick={() => act('toggleSupressRuntimes')}
                            >
                              Supress Runtime Logging
                            </Button.Checkbox>
                            <Button.Confirm
                              color="red"
                              tooltip="Delete All Logs"
                              icon="trash-alt"
                              confirmIcon="trash-alt"
                              confirmContent={null}
                              onClick={() => act('nukeLog')}
                            />
                          </Box>
                        )
                      }
                      width="100%"
                    >
                      {tabContent}
                    </Section>
                    {activeTab === 'log' && showJumpToBottomButton && (
                      <Flex
                        position="absolute"
                        bottom="2.5rem"
                        width="100%"
                        justify="center"
                      >
                        <Button
                          icon="arrow-down"
                          onClick={() => {
                            const sectionCurrent = sectionRef.current;
                            if (sectionCurrent) {
                              sectionCurrent.scrollTop =
                                sectionCurrent.scrollHeight;
                            }
                          }}
                        >
                          Jump to Bottom
                        </Button>
                      </Flex>
                    )}
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
      {modal === 'states' && <StateSelectModal setModal={setModal} />}
      {modal === 'viewChunk' && (
        <ChunkViewModal
          viewedChunk={viewedChunk ?? ''}
          setViewedChunk={setViewedChunk}
          setModal={setModal}
        />
      )}
      {modal === 'call' && toCall && (
        <CallModal toCall={toCall} setToCall={setToCall} setModal={setModal} />
      )}
    </Window>
  );
};

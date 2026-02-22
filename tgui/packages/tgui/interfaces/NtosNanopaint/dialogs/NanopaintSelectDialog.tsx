import { useEffect, useState } from 'react';
import { sendAct as act } from 'tgui/events/act';
import {
  Button,
  Dimmer,
  Dropdown,
  Input,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import type { NanopaintData, NanopaintFileEntry } from '../types';

type NanopaintSelectDialogProps = {
  title: string;
  driveFiles: NanopaintFileEntry[];
  diskFiles: NanopaintFileEntry[];
  diskInserted: BooleanLike;
  saveableTypes: NanopaintData['saveableTypes'];
  confirmText: string;
  action: string;
};

export const NanopaintSelectDialog = (props: NanopaintSelectDialogProps) => {
  const {
    title,
    driveFiles,
    diskFiles,
    diskInserted,
    saveableTypes,
    confirmText,
    action,
  } = props;
  const [pathLastPickedByInput, setPathLastPickedByInput] = useState(true);
  const [tab, setTab] = useState('drive');
  const [path, setPath] = useState('');
  const [descIndex, setDescIndex] = useState(0);
  const extension = saveableTypes[descIndex].extension;
  const typepath = saveableTypes[descIndex].typepath;
  const visibleFiles = tab === 'drive' ? driveFiles : diskFiles;
  const dropdownOptions = saveableTypes.map(({ displayText }, value) => {
    return { displayText, value };
  });
  useEffect(() => {
    if (tab === 'disk' && !diskInserted) {
      setTab('drive');
    }
  }, [diskInserted]);
  return (
    <Dimmer>
      <Section title={title} width="500px">
        <Stack vertical>
          <Stack.Item>
            <Stack fill height="300px">
              <Stack.Item>
                <Tabs vertical>
                  <Tabs.Tab selected={tab === 'drive'}>Local Drive</Tabs.Tab>
                  {!!diskInserted && (
                    <Tabs.Tab selected={tab === 'disk'}>Data Disk</Tabs.Tab>
                  )}
                </Tabs>
              </Stack.Item>
              <Stack.Divider />
              <Stack.Item width="100%">
                <Stack vertical overflowY="scroll">
                  {visibleFiles.map((file, i) => {
                    const filePath = `${file.name}.${file.extension}`;
                    return (
                      <Stack.Item key={i}>
                        <Button
                          width="100%"
                          selected={path === filePath && !pathLastPickedByInput}
                          className="NtosNanopaint__SelectDialog__EntryCell"
                          onClick={() => {
                            setPath(filePath);
                            setPathLastPickedByInput(false);
                          }}
                        >
                          {filePath}
                        </Button>
                      </Stack.Item>
                    );
                  })}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <Input
                  fluid
                  value={path}
                  onChange={(value) => {
                    setPath(value);
                    setPathLastPickedByInput(true);
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <Dropdown
                  selected={dropdownOptions[descIndex]}
                  options={dropdownOptions}
                  onSelected={(v) => {
                    const newExtension = saveableTypes[v].extension;
                    const splitPath = path.split('.');
                    if (
                      splitPath.at(-1) !== newExtension &&
                      path.length !== 0
                    ) {
                      setPath(
                        [...splitPath.slice(0, -1), newExtension].join('.'),
                      );
                    }
                    setDescIndex(v);
                  }}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack fill justify="end">
              <Stack.Item>
                <Button
                  onClick={() => {
                    const splitPath = path.split('.');
                    const pathDesc = saveableTypes.find(
                      ({ extension: entryExtension }) =>
                        splitPath.at(-1) === entryExtension,
                    );
                    const name = pathDesc
                      ? splitPath.slice(0, -1).join('.')
                      : path;
                    const inputExtension = pathDesc
                      ? splitPath.at(-1)
                      : extension;
                    const inputTypepath = pathDesc?.typepath ?? typepath;
                    const uid = visibleFiles.find(
                      (fileEntry) =>
                        fileEntry.name === name &&
                        fileEntry.extension === inputExtension,
                    )?.uid;
                    act(action, {
                      name,
                      uid: uid ?? null,
                      onDisk: tab === 'disk',
                      typepath: inputTypepath,
                    });
                  }}
                >
                  {confirmText}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button onClick={() => act('closeDialog')}>Cancel</Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </Dimmer>
  );
};

import { Button, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type FileEntry = {
  name: string;
  type: string;
  size: number;
  undeletable: BooleanLike;
  alert_able: BooleanLike;
  alert_silenced: BooleanLike;
  printable: BooleanLike;
};

type NtosFileManagerData = {
  usbconnected: BooleanLike;
  files: FileEntry[];
  usbfiles: FileEntry[];
};

export const NtosFileManager = (props) => {
  const { act, data } = useBackend<NtosFileManagerData>();
  const { usbconnected, files = [], usbfiles = [] } = data;
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <Section>
          <FileTable
            files={files}
            usbconnected={usbconnected}
            onUpload={(file) => act('PRG_copytousb', { name: file })}
            onDelete={(file) => act('PRG_deletefile', { name: file })}
            onRename={(file, newName) =>
              act('PRG_renamefile', {
                name: file,
                new_name: newName,
              })
            }
            onDuplicate={(file) => act('PRG_clone', { file: file })}
            onToggleSilence={(file) => act('PRG_togglesilence', { name: file })}
            onPrint={(file) => act('PRG_print', { name: file })}
          />
        </Section>
        {usbconnected && (
          <Section title="Data Disk">
            <FileTable
              usbmode
              files={usbfiles}
              usbconnected={usbconnected}
              onUpload={(file) => act('PRG_copyfromusb', { name: file })}
              onDelete={(file) => act('PRG_usbdeletefile', { name: file })}
              onRename={(file, newName) =>
                act('PRG_usbrenamefile', {
                  name: file,
                  new_name: newName,
                })
              }
              onDuplicate={(file) => act('PRG_clone', { file: file })}
              onPrint={(file) => act('PRG_usbprint', { name: file })}
            />
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type FileTableProps = {
  files: FileEntry[];
  usbconnected: BooleanLike;
  usbmode?: BooleanLike;
  onUpload: (file: string) => void;
  onDelete: (file: string) => void;
  onRename: (file: string, newName: string) => void;
  onDuplicate: (file: string) => void;
  onToggleSilence?: (file: string) => void;
  onPrint: (file: string) => void;
};

const FileTable = (props: FileTableProps) => {
  const {
    files = [],
    usbconnected,
    usbmode,
    onUpload,
    onDelete,
    onRename,
    onToggleSilence,
    onPrint,
  } = props;
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>File</Table.Cell>
        <Table.Cell collapsing>Type</Table.Cell>
        <Table.Cell collapsing>Size</Table.Cell>
      </Table.Row>
      {files.map((file) => (
        <Table.Row key={file.name} className="candystripe">
          <Table.Cell>
            {!file.undeletable ? (
              <Button.Input
                fluid
                value={file.name}
                onCommit={(value) => onRename(file.name, value)}
              />
            ) : (
              file.name
            )}
          </Table.Cell>
          <Table.Cell>{file.type}</Table.Cell>
          <Table.Cell>{file.size}</Table.Cell>
          <Table.Cell collapsing>
            {!!file.alert_able && (
              <Button
                icon={file.alert_silenced ? 'bell-slash' : 'bell'}
                color={file.alert_silenced ? 'red' : 'default'}
                tooltip={file.alert_silenced ? 'Unmute Alerts' : 'Mute Alerts'}
                onClick={() => onToggleSilence!(file.name)}
              />
            )}
            {!file.undeletable && (
              <>
                <Button.Confirm
                  icon="trash"
                  confirmIcon="times"
                  confirmContent=""
                  tooltip="Delete"
                  onClick={() => onDelete(file.name)}
                />
                {!!usbconnected &&
                  (usbmode ? (
                    <Button
                      icon="download"
                      tooltip="Download"
                      onClick={() => onUpload(file.name)}
                    />
                  ) : (
                    <Button
                      icon="upload"
                      tooltip="Upload"
                      onClick={() => onUpload(file.name)}
                    />
                  ))}
              </>
            )}
            {!!file.printable && (
              <Button
                icon="print"
                tooltip="Print"
                onClick={() => onPrint(file.name)}
              />
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

export const NtosFileManager = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    PC_device_theme,
    usbconnected,
    files = [],
    usbfiles = [],
  } = data;
  return (
    <NtosWindow resizable theme={PC_device_theme}>
      <NtosWindow.Content scrollable>
        <Section>
          <FileTable
            files={files}
            usbconnected={usbconnected}
            onUpload={file => act('PRG_copytousb', { name: file })}
            onDelete={file => act('PRG_deletefile', { name: file })}
            onRename={(file, newName) => act('PRG_rename', {
              name: file,
              new_name: newName,
            })}
            onDuplicate={file => act('PRG_clone', { file: file })} />
        </Section>
        {usbconnected && (
          <Section title="Data Disk">
            <FileTable
              usbmode
              files={usbfiles}
              usbconnected={usbconnected}
              onUpload={file => act('PRG_copyfromusb', { name: file })}
              onDelete={file => act('PRG_deletefile', { name: file })}
              onRename={(file, newName) => act('PRG_rename', {
                name: file,
                new_name: newName,
              })}
              onDuplicate={file => act('PRG_clone', { file: file })} />
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const FileTable = props => {
  const {
    files = [],
    usbconnected,
    usbmode,
    onUpload,
    onDelete,
    onRename,
  } = props;
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>
          File
        </Table.Cell>
        <Table.Cell collapsing>
          Type
        </Table.Cell>
        <Table.Cell collapsing>
          Size
        </Table.Cell>
      </Table.Row>
      {files.map(file => (
        <Table.Row key={file.name} className="candystripe">
          <Table.Cell>
            {!file.undeletable ? (
              <Button.Input
                fluid
                content={file.name}
                currentValue={file.name}
                tooltip="Rename"
                onCommit={(e, value) => onRename(file.name, value)} />
            ) : (
              file.name
            )}
          </Table.Cell>
          <Table.Cell>
            {file.type}
          </Table.Cell>
          <Table.Cell>
            {file.size}
          </Table.Cell>
          <Table.Cell collapsing>
            {!file.undeletable && (
              <Fragment>
                <Button.Confirm
                  icon="trash"
                  confirmIcon="times"
                  confirmContent=""
                  tooltip="Delete"
                  onClick={() => onDelete(file.name)} />
                {!!usbconnected && (
                  usbmode ? (
                    <Button
                      icon="download"
                      tooltip="Download"
                      onClick={() => onUpload(file.name)} />
                  ) : (
                    <Button
                      icon="upload"
                      tooltip="Upload"
                      onClick={() => onUpload(file.name)} />
                  )
                )}
              </Fragment>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

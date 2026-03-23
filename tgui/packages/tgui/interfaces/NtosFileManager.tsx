import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Image,
  LabeledList,
  Section,
  Slider,
  Stack,
  Table,
} from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
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
  image_ref: string;
  image_width: number;
  image_height: number;
};

type PrintType = {
  displayText: string;
  typepath: string;
  width: number;
  height: number;
};

type NtosFileManagerData = {
  usbconnected: BooleanLike;
  files: FileEntry[];
  usbfiles: FileEntry[];
  printTypes: PrintType[];
};

type PrintDialogProps = {
  toPrint: FileEntry;
  printTypes: PrintType[];
  onConfirm: (
    file: string,
    printType: PrintType,
    offsetX: number,
    offsetY: number,
  ) => void;
  onCancel: () => void;
};

const PrintDialog = (props: PrintDialogProps) => {
  const { toPrint, printTypes, onConfirm, onCancel } = props;
  const { name, image_ref, image_width, image_height } = toPrint;
  const [printType, setPrintType] = useState<PrintType>(
    printTypes.toSorted(
      (a, b) =>
        Math.abs(a.width - image_width) +
        Math.abs(a.height - image_height) -
        Math.abs(b.width - image_width) -
        Math.abs(b.height - image_height),
    )[0],
  );
  const { width, height } = printType;
  const [offsetX, setOffsetX] = useState(0);
  const [offsetY, setOffsetY] = useState(0);
  const [minOffsetX, maxOffsetX] = [width - image_width, 0].toSorted();
  const [minOffsetY, maxOffsetY] = [height - image_height, 0].toSorted();
  const pixelRatio = 200 / Math.max(width, image_width, height, image_height);
  useEffect(() => {
    if (offsetX < minOffsetX || offsetX > maxOffsetX) {
      setOffsetX(clamp(offsetX, minOffsetX, maxOffsetX));
    }
    if (offsetY < minOffsetY || offsetY > maxOffsetY) {
      setOffsetY(clamp(offsetY, minOffsetY, maxOffsetY));
    }
  }, [offsetX, offsetY, minOffsetX, maxOffsetX, minOffsetY, maxOffsetY]);
  return (
    <Dimmer>
      <Section
        title="Print"
        backgroundColor="primary"
        maxHeight="50%"
        maxWidth="90%"
        left="5%"
      >
        <Stack fill justify="space-between">
          <Stack.Item maxWidth="40%">
            <Section title="Formats">
              <Stack vertical overflowY="scroll">
                {printTypes.map((type, i) => {
                  const { displayText } = type;
                  return (
                    <Stack.Item key={i}>
                      <Button
                        selected={printType === type}
                        onClick={() => setPrintType(type)}
                      >
                        {displayText}
                      </Button>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack fill vertical>
              <Stack.Item grow align="center" verticalAlign="middle">
                <Box position="relative" width="200px" height="200px">
                  <Box
                    position="absolute"
                    backgroundColor="white"
                    left={
                      image_width > width ? `${-offsetX * pixelRatio}px` : 0
                    }
                    bottom={
                      image_height > height ? `${-offsetY * pixelRatio}px` : 0
                    }
                    width={`${width * pixelRatio}px`}
                    height={`${height * pixelRatio}px`}
                  />
                  <Image
                    fixErrors
                    src={image_ref}
                    position="absolute"
                    left={width > image_width ? `${offsetX * pixelRatio}px` : 0}
                    bottom={
                      width > image_width ? `${offsetY * pixelRatio}px` : 0
                    }
                    width={`${image_width * pixelRatio}px`}
                    height={`${image_height * pixelRatio}px`}
                  />
                  <Box
                    position="absolute"
                    style={{
                      outlineWidth: '5px',
                      outlineStyle: 'solid',
                      outlineColor: 'black',
                    }}
                    left={
                      image_width > width ? `${-offsetX * pixelRatio}px` : 0
                    }
                    bottom={
                      image_height > height ? `${-offsetY * pixelRatio}px` : 0
                    }
                    width={`${width * pixelRatio}px`}
                    height={`${height * pixelRatio}px`}
                  />
                </Box>
              </Stack.Item>
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item label="X Offset">
                    <Slider
                      tickWhileDragging
                      minValue={image_width > width ? -maxOffsetX : minOffsetX}
                      maxValue={image_width > width ? -minOffsetX : maxOffsetX}
                      value={image_width > width ? -offsetX : offsetX}
                      onChange={(_event, value) =>
                        setOffsetX(image_width > width ? -value : value)
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Y Offset">
                    <Slider
                      tickWhileDragging
                      minValue={
                        image_height > height ? -maxOffsetY : minOffsetY
                      }
                      maxValue={
                        image_height > height ? -minOffsetY : maxOffsetY
                      }
                      value={image_height > height ? -offsetY : offsetY}
                      onChange={(_event, value) =>
                        setOffsetY(image_height > height ? -value : value)
                      }
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Stack.Item>
              <Stack.Item>
                <Stack justify="end" mt={1}>
                  <Stack.Item>
                    <Button
                      onClick={() =>
                        onConfirm(name, printType, offsetX, offsetY)
                      }
                    >
                      Print
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button onClick={onCancel}>Cancel</Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </Dimmer>
  );
};

export const NtosFileManager = (props) => {
  const { act, data } = useBackend<NtosFileManagerData>();
  const { usbconnected, files = [], usbfiles = [], printTypes } = data;
  const [toPrint, setToPrint] = useState<FileEntry>();
  const [printingFromUsb, setPrintingFromUsb] = useState(false);
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        {!!toPrint && (
          <PrintDialog
            printTypes={printTypes}
            toPrint={toPrint}
            onConfirm={(name, printType, offsetX, offsetY) => {
              const { width, height, typepath } = printType;
              act(printingFromUsb ? 'PRG_usbprint' : 'PRG_print', {
                name,
                typepath,
                width,
                height,
                offsetX,
                offsetY,
              });
              setPrintingFromUsb(false);
              setToPrint(undefined);
            }}
            onCancel={() => {
              setPrintingFromUsb(false);
              setToPrint(undefined);
            }}
          />
        )}
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
            onPrint={setToPrint}
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
              onPrint={(file) => {
                setToPrint(file);
                setPrintingFromUsb(true);
              }}
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
  onPrint: (file: FileEntry) => void;
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
                onClick={() => onPrint(file)}
              />
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

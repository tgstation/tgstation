import {
  Box,
  Button,
  Image,
  Input,
  NoticeBox,
  Slider,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type NtosCameraCommonData = {
  width: number;
  height: number;
  size: string;
  minSize: number;
  maxSize: number;
  maxNameLength: number;
  maxDescLength: number;
  maxCaptionLength: number;
  printCost: number;
};

type NtosCameraPictureData = {
  photo: string;
  canEditMetadata: BooleanLike;
  name?: string;
  desc?: string;
  caption?: string;
  storedPaper: number;
};

type NtosCameraData =
  | NtosCameraCommonData
  | (NtosCameraCommonData & NtosCameraPictureData);

export const NtosCamera = (props) => {
  return (
    <NtosWindow width={400} height={600}>
      <NtosWindow.Content scrollable>
        <NtosCameraContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCameraContent = (props) => {
  const { act, data } = useBackend<NtosCameraData>();
  const {
    width,
    height,
    size,
    minSize,
    maxSize,
    maxNameLength,
    maxDescLength,
    maxCaptionLength,
    printCost,
    photo,
    canEditMetadata,
    name,
    desc,
    caption,
    storedPaper,
  } = data;

  return (
    <Stack fill vertical width="100%">
      {photo ? (
        <>
          <Stack.Item align="center">
            <Image
              width="auto"
              minWidth="50%"
              maxWidth="100%"
              height="auto"
              fixErrors
              src={`data:image/jpeg;base64,${photo}`}
            />
          </Stack.Item>
          <Stack.Item>
            <Box bold textColor="label">
              Name:
            </Box>
            <Input
              fluid
              disabled={!canEditMetadata}
              value={name}
              maxLength={maxNameLength}
              onChange={(value) =>
                act('setName', {
                  value: value,
                })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Box bold textColor="label">
              Description:
            </Box>
            <Input
              fluid
              disabled={!canEditMetadata}
              value={desc}
              maxLength={maxDescLength}
              onChange={(value) =>
                act('setDesc', {
                  value: value,
                })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Box bold textColor="label">
              Caption:
            </Box>
            <TextArea
              height="6rem"
              fluid
              disabled={!canEditMetadata}
              value={caption}
              maxLength={maxCaptionLength}
              onChange={(value) =>
                act('setCaption', {
                  value: value,
                })
              }
            />
          </Stack.Item>
          <Stack.Item align="center">
            <Button onClick={() => act('savePhoto')}>Save Photo</Button>
          </Stack.Item>
          <Stack.Item align="center">
            <Button
              disabled={storedPaper! < printCost}
              tooltip={
                !storedPaper &&
                `You need at least ${printCost} sheet${printCost === 1 ? '' : 's'} of paper to print a photo.`
              }
              onClick={() => act('printPhoto')}
            >
              Print Photo
            </Button>
          </Stack.Item>
        </>
      ) : (
        <Stack.Item>
          <NoticeBox>
            Phototrasen Images - Tap (right-click) with your tablet to snap a
            photo!
          </NoticeBox>
        </Stack.Item>
      )}
      <Stack.Item align="center">{size}</Stack.Item>
      <Stack.Item align="center">
        <Box bold inline textColor="label" mr="0.5rem">
          Half Width Aperture:
        </Box>
        <Slider
          inline
          value={width}
          minValue={minSize}
          maxValue={maxSize}
          step={1}
          onChange={(e, value) =>
            act('adjustWidth', {
              value: value,
            })
          }
        />
      </Stack.Item>
      <Stack.Item align="center">
        <Box bold inline textColor="label" mr="0.5rem">
          Half Height Aperture:
        </Box>
        <Slider
          inline
          value={height}
          minValue={minSize}
          maxValue={maxSize}
          step={1}
          onChange={(e, value) =>
            act('adjustHeight', {
              value: value,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
};

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Button, Box, NoticeBox, Stack } from '../components';

export const NtosCamera = (props, context) => {
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <NtosCameraContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCameraContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    photo,
    has_printer,
    paper_left,
  } = data;

  if (!photo) {
    return (
      <NoticeBox>
        PHOTO NOT FOUND: Right-click with the app open to snap a photo!
      </NoticeBox>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Box
          as="img"
          src={photo} />
      </Stack.Item>
      <Stack.Item>
        {!has_printer && (
          <NoticeBox>
            PRINTER NOT FOUND: Photo unable to be printed.
          </NoticeBox>
        )}
        {has_printer && (
          <Button
            content="Print photo"
            disabled={paper_left === 0}
            onClick={() => act('print_photo')}
          />
        )}
      </Stack.Item>
    </Stack>
  );
};

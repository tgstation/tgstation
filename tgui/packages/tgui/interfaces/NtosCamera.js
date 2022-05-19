import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Box, NoticeBox } from '../components';

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
    <Box
      as="img"
      src={photo} />
  );
};

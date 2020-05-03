import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { NtosWindow } from '../layouts';
import { NtosCyborgRemoteMonitorContent } from './NtosCyborgRemoteMonitor';

export const NtosCyborgRemoteMonitorSyndicate = (props, context) => {
  return (
    <NtosWindow theme="syndicate">
      <NtosWindow.Content scrollable>
        <NtosCyborgRemoteMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

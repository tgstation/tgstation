import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { classes } from 'common/react';
import { Box, Button, LabeledList, NoticeBox, Section, Table, Flex, Icon } from '../components';
import { NtosWindow } from '../layouts';
import { NtosRadarContent } from './NtosRadar';

export const NtosRadarSyndicate = (props, context) => {
  return (
    <NtosWindow theme="syndicate">
      <NtosRadarContent />
    </NtosWindow>
  );
};
import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  current_user: string;
  card_owner: string;
  paperamt: number;
  barcode_split: number;
  has_id_slot: BooleanLike;
};

export const NtosShipping = (props) => {
  return (
    <NtosWindow width={450} height={350}>
      <NtosWindow.Content scrollable>
        <ShippingHub />
        <ShippingOptions />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

/** Returns information about the current user, available paper, etc */
const ShippingHub = (props) => {
  const { act, data } = useBackend<Data>();
  const { current_user, card_owner, paperamt, barcode_split } = data;

  return (
    <Section
      title="NTOS Shipping Hub."
      buttons={
        <Button
          icon="eject"
          content="Eject Id"
          onClick={() => act('ejectid')}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Current User">
          {current_user || 'N/A'}
        </LabeledList.Item>
        <LabeledList.Item label="Inserted Card">
          {card_owner || 'N/A'}
        </LabeledList.Item>
        <LabeledList.Item label="Available Paper">{paperamt}</LabeledList.Item>
        <LabeledList.Item label="Profit on Sale">
          {barcode_split}%
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

/** Returns shipping options */
const ShippingOptions = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_id_slot, current_user } = data;

  return (
    <Section title="Shipping Options">
      <Box>
        <Button
          icon="id-card"
          tooltip="The currently ID card will become the current user."
          tooltipPosition="right"
          disabled={!has_id_slot}
          onClick={() => act('selectid')}
          content="Set Current ID"
        />
      </Box>
      <Box>
        <Button
          icon="print"
          tooltip="Print a barcode to use on a wrapped package."
          tooltipPosition="right"
          disabled={!current_user}
          onClick={() => act('print')}
          content="Print Barcode"
        />
      </Box>
      <Box>
        <Button
          icon="tags"
          tooltip="Set how much profit you'd like on your package."
          tooltipPosition="right"
          onClick={() => act('setsplit')}
          content="Set Profit Margin"
        />
      </Box>
      <Box>
        <Button
          icon="sync-alt"
          content="Reset ID"
          onClick={() => act('resetid')}
        />
      </Box>
    </Section>
  );
};

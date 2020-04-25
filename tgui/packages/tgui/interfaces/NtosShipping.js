import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosShipping = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <Section
          title="NTOS Shipping Hub."
          buttons={(
            <Button
              icon="eject"
              content="Eject Id"
              onClick={() => act('ejectid')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Current User">
              {data.current_user || "N/A"}
            </LabeledList.Item>
            <LabeledList.Item label="Inserted Card">
              {data.card_owner || "N/A"}
            </LabeledList.Item>
            <LabeledList.Item label="Available Paper">
              {data.has_printer ? data.paperamt : "N/A"}
            </LabeledList.Item>
            <LabeledList.Item label="Profit on Sale">
              {data.barcode_split}%
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Shipping Options">
          <Box>
            <Button
              icon="id-card"
              tooltip="The currently ID card will become the current user."
              tooltipPosition="right"
              disabled={!data.has_id_slot}
              onClick={() => act('selectid')}
              content="Set Current ID" />
          </Box>
          <Box>
            <Button
              icon="print"
              tooltip="Print a barcode to use on a wrapped package."
              tooltipPosition="right"
              disabled={!data.has_printer || !data.current_user}
              onClick={() => act('print')}
              content="Print Barcode" />
          </Box>
          <Box>
            <Button
              icon="tags"
              tooltip="Set how much profit you'd like on your package."
              tooltipPosition="right"
              onClick={() => act('setsplit')}
              content="Set Profit Margin" />
          </Box>
          <Box>
            <Button
              icon="sync-alt"
              content="Reset ID"
              onClick={() => act('resetid')} />
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

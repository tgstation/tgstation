import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, LabeledList, ProgressBar, Section } from '../components';

export const NtosShipping = props => {
  const { act, data } = useBackend(props);
  return (
    <Section
      title="NTOS Shipping Hub."
      buttons={(
        <Button
          icon="eject"
          content="Eject Id"
          onClick={() => act('ejectid', {
          })} />
      )}>
      <Box>
        Current User: {data.current_user ? data.current_user : "N/A"}
      </Box>
      <Box my={1}>
        Inserted Card: {data.card_owner ? data.card_owner : "N/A"}
      </Box>
      <Box my={1}>
        Available Paper: {data.has_printer?data.paperamt:"No printer detected."}
      </Box>
      <Box>
        Profit on Sale: {data.barcode_split}%
      </Box>
      <Section title="Shipping Options">
        <Box>
          <Button
            icon="id-card"
            tooltip="The currently ID card will become the current user."
            disabled={data.has_id === 0}
            onClick={() => act('selectid')}
            content="Set Current ID" />
        </Box>
        <Box>
          <Button
            icon="print"
            tooltip="Print a barcode to use on a wrapped package."
            disabled={!data.has_printer || !data.current_user}
            onClick={() => act('print')}
            content="Print Barcode" />
        </Box>
        <Box>
          <Button
            icon="tags"
            tooltip="Set how much profit you'd like on your package."
            onClick={() => act('setsplit')}
            content="Set Profit Margin" />
        </Box>
        <Box>
          <Button
            icon="sync-alt"
            content="Reset ID"
            onClick={() => act('resetid', {
            })} />
        </Box>
      </Section>
    </Section>
  );
};

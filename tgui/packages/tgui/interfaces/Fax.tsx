import { sortBy } from 'common/collections';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type FaxData = {
  faxes: FaxInfo[];
  fax_id: string;
  fax_name: string;
  has_paper: string;
};

type FaxInfo = {
  id: string;
  name: string;
};

export const Fax = (props, context) => {
  const { act } = useBackend(context);
  const { data } = useBackend<FaxData>(context);
  const faxes = sortBy((fax) => fax.name)(data.faxes);
  return (
    <Window
      width={450}
      height={340}>
      <Window.Content scrollable>
        <Section title="About Fax">
          <LabeledList.Item label='Network name'>
            {data.fax_name}
          </LabeledList.Item>
          <LabeledList.Item label='Network ID'>
            {data.fax_id}
          </LabeledList.Item>
        </Section>
        <Section title="Paper">
          <LabeledList.Item label="Paper">
            {data.has_paper ? <font color='green'>Paper in tray </font> : <font color='red'>No paper </font>}
            <Button
              onClick={() => act('remove')}
              disabled={data.has_paper ? false : true}>
              Remove
            </Button>
          </LabeledList.Item>
        </Section>
        <Section title="Send">
          <Box mt={0.4}>
          {faxes.map((fax) => (
            <Button
              key={fax.id}
              title={fax.name}
              disabled={!data.has_paper}
              onClick={() =>
                act('send', {
                  id: fax.id,
                })
              }>
              {fax.name}
            </Button>
          ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

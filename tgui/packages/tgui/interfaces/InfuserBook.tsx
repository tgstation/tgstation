import { useBackend } from '../backend';
import { BlockQuote, Box, Section, Stack } from '../components';
import { Window } from '../layouts';

type Entry = {
  name: string;
  infuse_mob_name: string;
  desc: string;
  threshold_desc: string;
  qualities: string[];
};

type DnaInfuserData = {
  entries: Entry[];
};

export const InfuserBook = (props, context) => {
  const { data } = useBackend<DnaInfuserData>(context);
  const { entries } = data;
  return (
    <Window width={620} height={320}>
      <Window.Content scrollable>
        <Stack vertical>
          {entries.map((entry) => {
            return (
              <Stack.Item key={entry.name}>
                <InfuserEntry entry={entry} />
              </Stack.Item>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};

type InfuserEntryProps = {
  entry: Entry;
};

const InfuserEntry = (props: InfuserEntryProps, context) => {
  const { entry } = props;
  return (
    <Section>
      <Stack vertical>
        <Stack.Item fontSize={'18px'}>{entry.name} Mutant</Stack.Item>
        <Stack.Item>
          <BlockQuote>
            {entry.desc} If a subject infuses with enough DNA,{' '}
            {entry.threshold_desc}
          </BlockQuote>
        </Stack.Item>
        <Stack.Item>
          Qualities:
          {entry.qualities.map((quality) => {
            return (
              <Box color="label" key={quality}>
                - {quality}
              </Box>
            );
          })}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          Created from infusing{' '}
          <Box inline color={entry.name === 'Rejected' ? 'red' : 'green'}>
            {entry.infuse_mob_name}
          </Box>{' '}
          DNA into a subject.
        </Stack.Item>
      </Stack>
    </Section>
  );
};

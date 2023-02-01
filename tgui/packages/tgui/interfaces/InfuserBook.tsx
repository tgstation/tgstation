import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';
import { multiline } from 'common/string';

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
  const [entryIndex, setEntryIndex] = useLocalState(context, 'entry', 0);

  const wrapEntries = (newIndex) => {
    if (newIndex < 0) {
      newIndex = entries.length - 1;
    } else if (newIndex > entries.length - 1) {
      newIndex = 0;
    }
    setEntryIndex(newIndex);
  };

  return (
    <Window title="DNA Infusion Manual" width={620} height={550}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <InfuserInstructions />
          </Stack.Item>
          <Stack.Item>
            <InfuserEntry entry={entries[entryIndex]} />
          </Stack.Item>
          <Stack.Item textAlign="center">
            <Stack fontSize="18px" fill>
              <Stack.Item grow={2}>
                <Button onClick={() => wrapEntries(entryIndex - 1)} fluid>
                  Last Entry
                </Button>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Section fitted fill pt="3px">
                  Entry {entryIndex + 1}/{entries.length}
                </Section>
              </Stack.Item>
              <Stack.Item grow={2}>
                <Button onClick={() => wrapEntries(entryIndex + 1)} fluid>
                  Next Entry
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const InfuserInstructions = (props, context) => {
  return (
    <Section title="DNA Infusion Guide">
      <Stack vertical>
        <Stack.Item fontSize="16px">What does it do?</Stack.Item>
        <Stack.Item color="label">
          DNA Infusion is the practice of integrating dead creature DNA into
          yourself, mutating one of your organs into a genetic slurry that sits
          somewhere between being yours or the creature&apos;s. While this does
          bring you further away from being human, and gives a slew of...
          unfortunate side effects, it also grants new capabilities.{' '}
          <b>
            Above all else, you have to understand that gene-mutants are usually
            very good at specific things, especially with their threshold
            bonuses.
          </b>
        </Stack.Item>
        <Stack.Item fontSize="16px">I&apos;m sold! How do I do it?</Stack.Item>
        <Stack.Item color="label">
          1. Load a dead creature into the machine. This is what you&apos;re
          infusing from.
          <br />
          2. Enter the machine, like you would the DNA scanner.
          <br />
          3. Have someone activate the machine externally.
          <br />
          <Box inline color="white">
            And you&apos;re done! Note that the infusion source will be
            obliterated in the process.
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type InfuserEntryProps = {
  entry: Entry;
};

const InfuserEntry = (props: InfuserEntryProps, context) => {
  const { entry } = props;
  const isLesser = !entry.threshold_desc;
  const lesserDesc = multiline`
    Lesser Mutants usually have a smaller list of potential mutations, and
    do not have bonuses for infusing many organs.
  `;
  const greaterDesc = multiline`
    Greater Mutants have more upsides and downsides in their organs, more organs
    to infuse overall, and come with special bonuses for infusing enough DNA
    into yourself.
  `;
  return (
    <Section
      fill
      title={entry.name + ' Mutant'}
      height="225px"
      buttons={
        <Button
          tooltip={isLesser ? lesserDesc : greaterDesc}
          icon={isLesser ? 'minus-circle' : 'plus-circle'}
          color={isLesser ? 'red' : 'green'}>
          {isLesser ? 'Lesser' : 'Greater'} Mutant
        </Button>
      }>
      <Stack vertical fill>
        <Stack.Item>
          <BlockQuote>
            {entry.desc}{' '}
            {!isLesser && (
              <>If a subject infuses with enough DNA, {entry.threshold_desc}</>
            )}
          </BlockQuote>
        </Stack.Item>
        <Stack.Item grow>
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

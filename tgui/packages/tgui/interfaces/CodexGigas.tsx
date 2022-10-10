import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  name: string;
  currentSection: number;
};

const PREFIXES = [
  'Dark',
  'Hellish',
  'Fallen',
  'Fiery',
  'Sinful',
  'Blood',
  'Fluffy',
] as const;

const TITLES = [
  'Lord',
  'Prelate',
  'Count',
  'Viscount',
  'Vizier',
  'Elder',
  'Adept',
] as const;

const NAMES = [
  'hal',
  've',
  'odr',
  'neit',
  'ci',
  'quon',
  'mya',
  'folth',
  'wren',
  'geyr',
  'hil',
  'niet',
  'twou',
  'phi',
  'coa',
] as const;

const SUFFIXES = [
  'the Red',
  'the Soulless',
  'the Master',
  'the Lord of all things',
  'Jr.',
] as const;

export const CodexGigas = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { name, currentSection } = data;

  return (
    <Window width={450} height={450}>
      <Window.Content>
        <Section>
          {name}
          <LabeledList>
            <Prefixes />
            <Titles />
            <Names />
            <Suffixes />
            <LabeledList.Item label="Submit">
              <Button
                content="Search"
                disabled={currentSection < 4}
                onClick={() => act('search')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

const Prefixes = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { currentSection } = data;

  return (
    <LabeledList.Item label="Prefix">
      {PREFIXES.map((prefix) => (
        <Button
          key={prefix.toLowerCase()}
          content={prefix}
          disabled={currentSection !== 1}
          onClick={() => act(prefix + ' ')}
        />
      ))}
    </LabeledList.Item>
  );
};

const Titles = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { currentSection } = data;

  return (
    <LabeledList.Item label="Title">
      {TITLES.map((title) => (
        <Button
          key={title.toLowerCase()}
          content={title}
          disabled={currentSection !== 2}
          onClick={() => act(title)}
        />
      ))}
    </LabeledList.Item>
  );
};

const Names = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { currentSection } = data;

  return (
    <LabeledList.Item label="Name">
      {NAMES.map((name) => (
        <Button
          key={name.toLowerCase()}
          content={name}
          disabled={currentSection !== 3}
          onClick={() => act(name)}
        />
      ))}
    </LabeledList.Item>
  );
};

const Suffixes = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { currentSection } = data;

  return (
    <LabeledList.Item label="Suffix">
      {SUFFIXES.map((suffix) => (
        <Button
          key={suffix.toLowerCase()}
          content={suffix}
          disabled={currentSection !== 4}
          onClick={() => act(' ' + suffix)}
        />
      ))}
    </LabeledList.Item>
  );
};

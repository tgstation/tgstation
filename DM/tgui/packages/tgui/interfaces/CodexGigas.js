import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

const PREFIXES = [
  "Dark",
  "Hellish",
  "Fallen",
  "Fiery",
  "Sinful",
  "Blood",
  "Fluffy",
];

const TITLES = [
  "Lord",
  "Prelate",
  "Count",
  "Viscount",
  "Vizier",
  "Elder",
  "Adept",
];

const NAMES = [
  "hal",
  "ve",
  "odr",
  "neit",
  "ci",
  "quon",
  "mya",
  "folth",
  "wren",
  "geyr",
  "hil",
  "niet",
  "twou",
  "phi",
  "coa",
];

const SUFFIXES = [
  "the Red",
  "the Soulless",
  "the Master",
  "the Lord of all things",
  "Jr.",
];

// TODO: refactor the backend of this it's a trainwreck
export const CodexGigas = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content>
        <Section>
          {data.name}
          <LabeledList>
            <LabeledList.Item label="Prefix">
              {PREFIXES.map(prefix => (
                <Button
                  key={prefix.toLowerCase()}
                  content={prefix}
                  disabled={data.currentSection !== 1}
                  onClick={() => act(prefix + ' ')} />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Title">
              {TITLES.map(title => (
                <Button
                  key={title.toLowerCase()}
                  content={title}
                  disabled={data.currentSection > 2}
                  onClick={() => act(title + ' ')} />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Name">
              {NAMES.map(name => (
                <Button
                  key={name.toLowerCase()}
                  content={name}
                  disabled={data.currentSection > 4}
                  onClick={() => act(name)} />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Suffix">
              {SUFFIXES.map(suffix => (
                <Button
                  key={suffix.toLowerCase()}
                  content={suffix}
                  disabled={data.currentSection !== 4}
                  onClick={() => act(' ' + suffix)} />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Submit">
              <Button
                content="Search"
                disabled={data.currentSection < 4}
                onClick={() => act('search')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

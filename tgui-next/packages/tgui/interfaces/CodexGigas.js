import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';

// TODO: refactor the backend of this it's a trainwreck
export const CodexGigas = props => {
  const { act, data } = useBackend(props);
  const prefixes = [
    "Dark",
    "Hellish",
    "Fallen",
    "Fiery",
    "Sinful",
    "Blood",
    "Fluffy",
  ];
  const titles = [
    "Lord",
    "Prelate",
    "Count",
    "Viscount",
    "Vizier",
    "Elder",
    "Adept",
  ];
  const names = [
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
  const suffixes = [
    "the Red",
    "the Soulless",
    "the Master",
    "the Lord of all things",
    "Jr.",
  ];
  return (
    <Section>
      {data.name}
      <LabeledList>
        <LabeledList.Item label="Prefix">
          {prefixes.map(prefix => (
            <Button
              key={prefix.toLowerCase()}
              content={prefix}
              disabled={data.currentSection !== 1}
              onClick={() => act(prefix + ' ')} />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Title">
          {titles.map(title => (
            <Button
              key={title.toLowerCase()}
              content={title}
              disabled={data.currentSection > 2}
              onClick={() => act(title + ' ')} />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Name">
          {names.map(name => (
            <Button
              key={name.toLowerCase()}
              content={name}
              disabled={data.currentSection > 4}
              onClick={() => act(name)} />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Suffix">
          {suffixes.map(suffix => (
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
  );
};

import { act } from '../byond';
import { Button, LabeledList, Section } from '../components';

// TODO: refactor the backend of this it's a trainwreck
export const CodexGigas = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
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
              onClick={() => act(ref, prefix + ' ')}
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Title">
          {titles.map(title => (
            <Button
              key={title.toLowerCase()}
              content={title}
              disabled={data.currentSection >= 2}
              onClick={() => act(ref, title + ' ')}
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Name">
          {names.map(name => (
            <Button
              key={name.toLowerCase()}
              content={name}
              disabled={data.currentSection >= 4}
              onClick={() => act(ref, name)}
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Suffix">
          {suffixes.map(suffix => (
            <Button
              key={suffix.toLowerCase()}
              content={suffix}
              disabled={data.currentSection !== 4}
              onClick={() => act(ref, ' ' + suffix)}
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Submit">
          <Button
            content="Search"
            disabled={data.currentSection <= 4}
            onClick={() => act(ref, 'search')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

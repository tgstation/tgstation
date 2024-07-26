import { Fragment, useMemo, useState } from 'react';
import { useBackend } from '../../backend';
import { Box, Divider, Dropdown, NoticeBox, Section } from '../../components';
import { Part, PodData } from './types';
import { DataMock, TAGNAME2TAG } from './constants';

export default function PartsDisplay(_props: any): JSX.Element {
  const { data } = useBackend<PodData>();
  const { parts } = data;

  const [selection, setSelection] = useState<string | null>(null);

  const options: string[] = parts.map((part: Part) => part.name);

  const [part, PartTag] = useMemo(() => {
    const part = parts.find((part: Part) => part.name === selection);
    const tag = part?.type ? TAGNAME2TAG[part.type] : undefined;

    return [part, tag];
  }, [selection]);

  return (
    <Section
      fill
      title={
        <Dropdown
          width="100%"
          options={options}
          selected={selection}
          placeholder="Select Part..."
          onSelected={(value: string) => setSelection(value)}
        />
      }
    >
      {part ? (
        <>
          <Box className="PartDescription">{part.desc}</Box>
          {!!PartTag && (
            <>
              <Divider />
              <PartTag />
            </>
          )}
        </>
      ) : (
        <NoticeBox info>No part information is currently avaliable.</NoticeBox>
      )}
    </Section>
  );
}

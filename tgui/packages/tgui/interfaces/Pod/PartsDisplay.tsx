import { useMemo, useState } from 'react';

import { useBackend } from '../../backend';
import { Box, Divider, Dropdown, NoticeBox, Section } from '../../components';
import { TAGNAME2TAG } from './constants';
import { Part, PodData } from './types';

export default function PartsDisplay(_props: any): JSX.Element {
  const { data } = useBackend<PodData>();
  const { parts } = data;

  const [selection, setSelection] = useState<string | null>(null);

  const options: string[] = parts.map((part: Part) => part.name);

  const [part, PartTag, partRef] = useMemo(() => {
    const part = parts.find((part: Part) => part.name === selection);
    const partRef = part?.ref;
    const tag = part?.type ? TAGNAME2TAG[part.type] : undefined;

    return [part, tag, partRef];
  }, [selection]);

  return (
    <Section
      fill
      className="Pod"
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
      {part && parts.some((found) => found === part) ? (
        <>
          <Box className="PartDescription">{part.desc}</Box>
          {!!PartTag && (
            <>
              <Divider />
              <PartTag ourData={data.partUIData[partRef as string]} />
            </>
          )}
        </>
      ) : (
        <NoticeBox info>No part information is currently avaliable.</NoticeBox>
      )}
    </Section>
  );
}

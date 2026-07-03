import { useState } from 'react';
import {
  Button,
  Floating,
  ImageButton,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { ManagerData } from './types';

export function TicketPanelEmoji(props) {
  const { data } = useBackend<ManagerData>();
  const { insertEmoji } = props;
  const { emojis } = data;
  const [open, setOpen] = useState(false);

  return (
    <Floating
      onOpenChange={setOpen}
      placement="top-end"
      content={
        <Stack className="TicketPanel__Emojis">
          <Stack.Item grow>
            <Section fill scrollable>
              {Object.keys(emojis)
                .reverse()
                .map((emoji) => (
                  <ImageButton
                    key={emoji}
                    asset={['chat16x16', `emoji-${emoji}`]}
                    assetSize={14}
                    imageSize={24}
                    onClick={() => insertEmoji(`:${emoji}:`)}
                  />
                ))}
            </Section>
          </Stack.Item>
        </Stack>
      }
    >
      <div style={{ display: 'inline-flex' }}>
        <Button
          icon="smile"
          color="transparent"
          tooltip="Эмодзи"
          tooltipPosition="top-end"
          selected={open}
        />
      </div>
    </Floating>
  );
}

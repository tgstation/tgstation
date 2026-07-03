import { useState } from 'react';
import {
  Button,
  Floating,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

export function TicketPanelEmbed(props) {
  const { insertEmbed } = props;
  const [open, setOpen] = useState(false);

  function preCommit(value: string, type: string) {
    switch (type) {
      case 'image':
        insertEmbed(`<img src='${value}'>`);
        break;
      case 'audio':
        insertEmbed(`<audio controls={true} src='${value}'>`);
        break;
      case 'link':
        insertEmbed(`<a href='${value}'>${value}</a>`);
        break;
    }
    return;
  }

  return (
    <Floating
      onOpenChange={setOpen}
      content={
        <Stack className="TicketPanel__Embed">
          <Stack.Item grow>
            <Section fill>
              <LabeledList>
                <LabeledList.Item label="Аудио">
                  <Button.Input
                    buttonText="Вставьте ссылку"
                    onCommit={(value) => preCommit(value, 'audio')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Изображение">
                  <Button.Input
                    buttonText="Вставьте ссылку"
                    onCommit={(value) => preCommit(value, 'image')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Ссылка">
                  <Button.Input
                    buttonText="Вставьте ссылку"
                    onCommit={(value) => preCommit(value, 'link')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      }
    >
      <div style={{ display: 'inline-flex' }}>
        <Button
          icon="circle-plus"
          color="transparent"
          tooltip="Добавить вложение"
          selected={open}
        />
      </div>
    </Floating>
  );
}

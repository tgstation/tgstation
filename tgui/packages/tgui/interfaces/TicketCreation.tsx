import { useState } from 'react';
import { Button, Modal, Section, Stack, TextArea } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type HelpData = {
  adminCount: Record<string, number>;
  maxMessageLength: number;
  ticketTypes: TicketType[];
};

type TicketType = {
  id: string;
  name: string;
};

const TicketCreationTitles = {
  Admin: 'Админов в сети',
  Mentor: 'Менторов в сети',
};

const InputFieldPlaceholders = {
  Admin: 'Опишите вашу проблему...',
  Mentor: 'С чем вам нужна помощь?',
};

export function TicketCreation() {
  const { act, data } = useBackend<HelpData>();
  const { adminCount, ticketTypes, maxMessageLength } = data;
  const [helpMessage, setHelpMessage] = useState('');
  const [selectedType, setSelectedType] = useState<TicketType>();
  const [selectTypeModal, setSelectTypeModal] = useState(false);

  const ticketCreationSectionTitle =
    TicketCreationTitles[selectedType?.id || 'Admin'];

  const adminsCountForSelectedType = adminCount[selectedType?.id || 'Admin'];

  const inputFieldPlaceholder =
    InputFieldPlaceholders[selectedType?.id || 'Admin'];

  return (
    <Window title="Создание тикета" theme="ss220" height={300} width={500}>
      <Window.Content>
        {(!selectedType || selectTypeModal) && (
          <TicketTypeSelectionModal
            selectedType={selectedType}
            setSelectedType={setSelectedType}
            setSelectTypeModal={setSelectTypeModal}
          />
        )}
        <Section
          fill
          title={`${ticketCreationSectionTitle}: ${adminsCountForSelectedType}`}
          buttons={
            <Button onClick={() => setSelectTypeModal(true)}>
              Выбрать тип тикета
            </Button>
          }
        >
          <Stack vertical fill>
            <Stack.Item grow>
              <TextArea
                autoFocus
                fluid
                height="100%"
                maxLength={maxMessageLength}
                placeholder={inputFieldPlaceholder}
                onChange={setHelpMessage}
                onEnter={() => {
                  act('create_ticket', {
                    message: helpMessage,
                    ticketType: selectedType?.id,
                  });
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                color="good"
                textAlign="center"
                disabled={!helpMessage || !selectedType}
                onClick={() =>
                  act('create_ticket', {
                    message: helpMessage,
                    ticketType: selectedType?.id,
                  })
                }
              >
                Отправить
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
}

type TicketTypeSelectionModalProps = {
  selectedType: TicketType | undefined;
  setSelectedType: (type: TicketType) => void;
  setSelectTypeModal: (value: boolean) => void;
};

function TicketTypeSelectionModal(props: TicketTypeSelectionModalProps) {
  const { data } = useBackend<HelpData>();
  const { ticketTypes } = data;
  const { selectedType, setSelectedType, setSelectTypeModal } = props;

  return (
    <Modal>
      <Section title="Чья помощь вам нужна?" color="label">
        Пожалуйста, выберите какой тикет создать. <br />
        Администрация может помочь вам в решении OOC проблем. <br />
        Менторы могут помочь в решении внутриигровых проблем.
        <Stack textAlign="center" mt={1}>
          {ticketTypes.map((ticketType) => (
            <Stack.Item key={ticketType.id} grow>
              <Button
                fluid
                selected={selectedType?.id === ticketType.id}
                onClick={() => {
                  setSelectedType(ticketType);
                  setSelectTypeModal(false);
                }}
              >
                {ticketType.name} тикет
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </Modal>
  );
}

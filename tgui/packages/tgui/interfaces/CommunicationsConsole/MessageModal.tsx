import { useState } from 'react';
import { Button, Flex, Modal, TextArea } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { CommsConsoleData } from './types';

type Props = {
  buttonText: string;
  icon: string;
  label: string;
  minLength?: number;
  notice?: string;
  onBack: () => void;
  onSubmit: (message: string) => void;
};

export function MessageModal(props: Props) {
  const { data } = useBackend<CommsConsoleData>();
  const { maxMessageLength } = data;
  const { label, minLength, onBack, onSubmit, notice, buttonText, icon } =
    props;

  const [input, setInput] = useState('');

  const longEnough = minLength === undefined || input.length >= minLength;

  return (
    <Modal>
      <Flex direction="column">
        <Flex.Item fontSize="16px" maxWidth="90vw" mb={1}>
          {label}:
        </Flex.Item>

        <Flex.Item mr={2} mb={1}>
          <TextArea
            fluid
            height="20vh"
            maxLength={maxMessageLength}
            onChange={setInput}
            placeholder={label}
            value={input}
            width="80vw"
          />
        </Flex.Item>

        <Flex.Item>
          <Button
            icon={icon}
            color="good"
            disabled={!longEnough}
            tooltip={!longEnough ? 'You need a longer reason.' : ''}
            tooltipPosition="right"
            onClick={() => {
              if (longEnough) {
                setInput('');
                onSubmit(input);
              }
            }}
          >
            {buttonText}
          </Button>

          <Button icon="times" color="bad" onClick={onBack}>
            Cancel
          </Button>
        </Flex.Item>

        {!!notice && <Flex.Item maxWidth="90vw">{notice}</Flex.Item>}
      </Flex>
    </Modal>
  );
}

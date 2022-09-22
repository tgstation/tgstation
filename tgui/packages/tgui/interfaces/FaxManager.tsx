import { sortBy } from '../../common/collections';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Flex,
  Dropdown,
  Section,
  Modal,
  TextArea,
  Input,
} from '../components';
import { Window } from '../layouts';

type FaxManagerData = {
  faxes: FaxInfo[];
  additional_faxes: AdditionalFaxesList[];
  requests: RequestsList[];
};

type FaxInfo = {
  fax_name: string;
  fax_id: string;
  syndicate_network: boolean;
};

type AdditionalFaxesList = {
  fax_name: string;
  button_color: string;
};

type RequestsList = {
  id_message: number;
  time: string;
  sender_name: string;
  sender_fax_id: string;
  sender_fax_name: string;
  receiver_fax_name: string;
  paper_raw_text: string;
};

export const FaxManager = (props, context) => {
  const { act } = useBackend(context);
  const { data } = useBackend<FaxManagerData>(context);
  const faxes = sortBy((sortFax: FaxInfo) => sortFax.fax_name)(data.faxes);

  const [messagingAssociates, setMessagingAssociates] = useLocalState(
    context,
    'messaging_associates',
    false
  );
  const [selectedFaxId, setSelectedFaxId] = useLocalState(
    context,
    'selectedFaxId',
    ''
  );
  const [selectedFaxName, setSelectedFaxName] = useLocalState(
    context,
    'selectedFaxName',
    ''
  );
  const [messageText, setMessageText] = useLocalState(
    context,
    'setMessageText',
    ''
  );
  return (
    <Window title="Fax Manager" width={600} height={700} theme="admin">
      <Window.Content scrollable>
        <Section title="Send">
          {faxes.map((fax: FaxInfo) => (
            <Button
              key={fax.fax_id}
              title={fax.fax_name}
              color={fax.syndicate_network ? 'red' : 'blue'}
              onClick={() => {
                setSelectedFaxId(fax.fax_id);
                setSelectedFaxName(fax.fax_name);
                setMessagingAssociates(true);
              }}>
              {fax.fax_name}/{fax.fax_id}
            </Button>
          ))}
        </Section>
        <Section title="Messages">
          <Flex direction="column">
            {!!data.requests &&
              data.requests.map((request: RequestsList) => (
                <Flex.Item key={request.id_message}>
                  <RequestControl
                    id_message={request.id_message}
                    sender_fax_id={request.sender_fax_id}
                    receiver_fax_name={request.receiver_fax_name}
                    time={request.time}
                    sender_name={request.sender_name}
                    sender_fax_name={request.sender_fax_name}
                    paper_raw_text={request.paper_raw_text}
                    onRead={(paper_raw_text) => {
                      setMessageText(paper_raw_text);
                    }}
                  />
                </Flex.Item>
              ))}
          </Flex>
        </Section>
      </Window.Content>
      {!!messagingAssociates && (
        <FaxMessageModal
          selectedFaxId={selectedFaxId}
          selectedFaxName={selectedFaxName}
          onBack={() => setMessagingAssociates(false)}
          onSubmit={(selectedFaxId, selectedSenderName, messageInput) => {
            setMessagingAssociates(false);
            act('send', {
              fax_id: selectedFaxId,
              fax_name: selectedSenderName,
              message: messageInput,
            });
          }}
          onFollow={(selectedFaxId) => {
            act('follow_fax', {
              fax_id: selectedFaxId,
            });
          }}
        />
      )}
    </Window>
  );
};

const FaxMessageModal = (props, context) => {
  const { data } = useBackend<FaxManagerData>(context);
  const [messageInput, setMessageInput] = useLocalState(
    context,
    props.messageInput,
    ''
  );

  const [selectedSenderName, setSelectedSenderName] = useLocalState(
    context,
    'selectedSenderName',
    ''
  );
  const [сustomSenderName, setCustomSenderName] = useLocalState(
    context,
    'сustomSenderName',
    ''
  );

  const additional_faxes: string[] = [];
  for (let fax of data.additional_faxes) {
    additional_faxes.push(fax.fax_name);
  }
  additional_faxes.push('Custom Name');

  return (
    <Modal>
      <Flex direction="column">
        <Flex.Item fontSize="16px" maxWidth="90vw" mb={1}>
          Send a message to {props.selectedFaxName}/{props.selectedFaxId}:
        </Flex.Item>
        <Flex.Item maxWidth="100%">
          <LabeledList.Item label="Selecting the sender: ">
            <Dropdown
              options={additional_faxes}
              selected={additional_faxes[0]}
              onSelected={(value) => setSelectedSenderName(value)}
            />
          </LabeledList.Item>
        </Flex.Item>
        {selectedSenderName === 'Custom Name' && (
          <Flex.Item maxWidth="100%">
            <LabeledList.Item label="Custom name for the sender: ">
              <Input onInput={(_, value) => setCustomSenderName(value)} />
            </LabeledList.Item>
          </Flex.Item>
        )}
        <Flex.Item mr={2} mb={1}>
          <TextArea
            fluid
            height="20vh"
            width="80vw"
            backgroundColor="black"
            textColor="white"
            onInput={(_, value) => {
              setMessageInput(value.substring(0, 5000));
            }}
            value={messageInput}
          />
        </Flex.Item>
        <Flex.Item>
          <Button
            icon={props.icon}
            content="Send"
            color="good"
            tooltipPosition="right"
            disabled={
              !messageInput || messageInput.length === 0
                ? true
                : selectedSenderName === 'Custom Name'
                ? !сustomSenderName || сustomSenderName.length === 0
                  ? true
                  : false
                : false
            }
            onClick={() => {
              if (messageInput && messageInput.length !== 0) {
                if (selectedSenderName !== 'Custom Name') {
                  props.onSubmit(
                    props.selectedFaxId,
                    selectedSenderName,
                    messageInput
                  );
                } else if (сustomSenderName && сustomSenderName.length !== 0) {
                  props.onSubmit(
                    props.selectedFaxId,
                    сustomSenderName,
                    messageInput
                  );
                  setCustomSenderName('');
                  setSelectedSenderName(additional_faxes[0]);
                  setMessageInput('');
                }
              }
            }}
          />
          <Button
            icon="times"
            content="Cancel"
            color="bad"
            onClick={() => {
              props.onBack();
              setSelectedSenderName(additional_faxes[0]);
              setMessageInput('');
            }}
          />
          <Button
            icon="times"
            content="Follow Fax"
            onClick={() => {
              props.onFollow(props.selectedFaxId);
            }}
          />
        </Flex.Item>
        {!!props.notice && (
          <Flex.Item maxWidth="90vw">{props.notice}</Flex.Item>
        )}
      </Flex>
    </Modal>
  );
};

const RequestControl = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Section
      title={props.receiver_fax_name}
      buttons={
        <>
          <Button
            onClick={() =>
              act('read_message', { id_message: props.id_message })
            }
            color="good">
            Read
          </Button>
          <Button
            onClick={() => act('flw_fax', { fax_id: props.sender_fax_id })}>
            FLW Fax
          </Button>
          <Button onClick={() => act('flw', { id_message: props.id_message })}>
            FLW
          </Button>
          <Button onClick={() => act('pp', { id_message: props.id_message })}>
            PP
          </Button>
          <Button onClick={() => act('vv', { id_message: props.id_message })}>
            VV
          </Button>
          <Button onClick={() => act('sm', { id_message: props.id_message })}>
            SM
          </Button>
          <Button onClick={() => act('logs', { id_message: props.id_message })}>
            LOGS
          </Button>
          <Button
            onClick={() => act('smite', { id_message: props.id_message })}>
            SMITE
          </Button>
        </>
      }>
      [{props.time}] Message received from {props.sender_fax_name}/
      {props.sender_name}
    </Section>
  );
};

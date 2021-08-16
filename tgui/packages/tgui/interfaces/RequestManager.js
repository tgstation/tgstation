import { Button, Collapsible, Section, Table } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { decodeHtmlEntities } from 'common/string';
import { Popper } from '../components/Popper';

export const RequestManager = (props, context) => {
  const { act, data } = useBackend(context);
  const { requests } = data;

  return (
    <Window width={575} height={600}>
      <Window.Content scrollable>
        <Section title="Requests" buttons={<NotificationPanel />}>
          {requests.map((request) => (
            <div className="RequestManager__row" key={request.id}>
              <div className="RequestManager__rowContents">
                <h2 className="RequestManager__header">
                  <span className="RequestManager__headerText">
                    {request.owner_name}
                  </span>
                  <span className="RequestManager__timestamp">
                    {request.timestamp_str}
                  </span>
                </h2>
                <div className="RequestManager__message">
                  <RequestType requestType={request.req_type} />
                  {decodeHtmlEntities(request.message)}
                </div>
              </div>
              <RequestControls request={request} />
            </div>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const PrefButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { prefs_options, user_prefs } = data;

  return (
    <>
      {Object.keys(prefs_options).map((description) => {
        const pref_val = prefs_options[description];
        const has_pref = user_prefs[`${pref_val}`];
        return (
          <Button
            key={pref_val}
            icon={has_pref ? 'bell' : 'bell-slash'}
            tooltip={description}
            onClick={() => act('toggle_pref', { pref: pref_val })}
          />
        );
      })}
    </>
  );
};

const displayTypeMap = {
  'request_prayer': 'PRAYER',
  'request_centcom': 'CENTCOM',
  'request_syndicate': 'SYNDICATE',
  'request_nuke': 'NUKE CODE',
};

const RequestType = (props) => {
  const { requestType } = props;

  return (
    <b className={`RequestManager__${requestType}`}>
      {displayTypeMap[requestType]}:
    </b>
  );
};

const NotificationPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { prefs_options, user_prefs } = data;
  const [notifVisible, setNotifVisible] = useLocalState(
    context,
    'notifVisible',
    false
  );

  return (
    <Popper
      options={{
        placement: 'bottom-start',
      }}
      popperContent={
        <div
          className="RequestManager__notificationPanel"
          style={{
            display: notifVisible ? 'block' : 'none',
          }}>
          <Table width="0">
            {Object.keys(prefs_options).map((description) => {
              const pref_val = prefs_options[description];
              const has_pref = user_prefs[`${pref_val}`];
              return (
                <Table.Row className="candystripe" key={pref_val}>
                  <Table.Cell>{description}</Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon={has_pref ? 'bell' : 'bell-slash'}
                      onClick={() => act('toggle_pref', { pref: pref_val })}
                      my={0.25}
                    />
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </div>
      }>
      <Button icon="cog" onClick={() => setNotifVisible(!notifVisible)}>
        Notifications
      </Button>
    </Popper>
  );
};

const RequestControls = (props, context) => {
  const { act, data } = useBackend(context);
  const { request } = props;

  return (
    <div className="RequestManager__controlsContainer">
      <Button onClick={() => act('sm', { id: request.id })}>SM</Button>
      <Button onClick={() => act('flw', { id: request.id })}>FLW</Button>
      <Button onClick={() => act('smite', { id: request.id })}>SMITE</Button>
      {request.req_type !== 'request_prayer' && (
        <Button onClick={() => act('rply', { id: request.id })}>RPLY</Button>
      )}
      {request.req_type === 'request_nuke' && (
        <Button onClick={() => act('setcode', { id: request.id })}>
          SETCODE
        </Button>
      )}
    </div>
  );
};

/**
 * @file
 * @copyright 2021 bobbahbrown (https://github.com/bobbahbrown)
 * @license MIT
 */

import { Button, Section } from '../components';
import { Window } from '../layouts';
import { useBackend } from '../backend';
import { decodeHtmlEntities } from 'common/string';

export const RequestManager = (props, context) => {
  const { act, data } = useBackend(context);
  const { requests } = data;

  return (
    <Window width={575} height={600}>
      <Window.Content scrollable>
        <Section title="Requests">
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

const RequestControls = (props, context) => {
  const { act, data } = useBackend(context);
  const { request } = props;

  return (
    <div className="RequestManager__controlsContainer">
      <Button onClick={() => act('pp', { id: request.id })}>PP</Button>
      <Button onClick={() => act('vv', { id: request.id })}>VV</Button>
      <Button onClick={() => act('sm', { id: request.id })}>SM</Button>
      <Button onClick={() => act('flw', { id: request.id })}>FLW</Button>
      <Button onClick={() => act('tp', { id: request.id })}>TP</Button>
      <Button onClick={() => act('logs', { id: request.id })}>LOGS</Button>
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

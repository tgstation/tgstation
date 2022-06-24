/**
 * @file
 * @copyright 2021 bobbahbrown (https://github.com/bobbahbrown)
 * @license MIT
 */

import { decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Input, Section, Table } from '../components';
import { Popper } from '../components/Popper';
import { Window } from '../layouts';

export const RequestManager = (props, context) => {
  const { act, data } = useBackend(context);
  const { requests } = data;
  const [filteredTypes, _] = useLocalState(
    context,
    'filteredTypes',
    Object.fromEntries(
      Object.entries(displayTypeMap).map(([type, _]) => [type, true])
    )
  );
  const [searchText, setSearchText] = useLocalState(context, 'searchText');

  // Handle filtering
  let displayedRequests = requests.filter(
    (request) => filteredTypes[request.req_type]
  );
  if (searchText) {
    const filterText = searchText.toLowerCase();
    displayedRequests = displayedRequests.filter(
      (request) =>
        decodeHtmlEntities(request.message)
          .toLowerCase()
          .includes(filterText) ||
        request.owner_name.toLowerCase().includes(filterText)
    );
  }

  return (
    <Window title="Request Manager" width={575} height={600} theme="admin">
      <Window.Content scrollable>
        <Section
          title="Requests"
          buttons={
            <>
              <Input
                value={searchText}
                onInput={(_, value) => setSearchText(value)}
                placeholder={'Search...'}
                mr={1}
              />
              <FilterPanel />
            </>
          }>
          {displayedRequests.map((request) => (
            <div className="RequestManager__row" key={request.id}>
              <div className="RequestManager__rowContents">
                <h2 className="RequestManager__header">
                  <span className="RequestManager__headerText">
                    {request.owner_name}
                    {request.owner === null && ' [DC]'}
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
              {request.owner !== null && <RequestControls request={request} />}
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
  const { act, _ } = useBackend(context);
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

const FilterPanel = (_, context) => {
  const [filterVisible, setFilterVisible] = useLocalState(
    context,
    'filterVisible',
    false
  );
  const [filteredTypes, setFilteredTypes] = useLocalState(
    context,
    'filteredTypes',
    Object.fromEntries(
      Object.entries(displayTypeMap).map(([type, _]) => [type, true])
    )
  );

  return (
    <Popper
      options={{
        placement: 'bottom-start',
      }}
      popperContent={
        <div
          className="RequestManager__filterPanel"
          style={{
            display: filterVisible ? 'block' : 'none',
          }}>
          <Table width="0">
            {Object.keys(displayTypeMap).map((type) => {
              return (
                <Table.Row className="candystripe" key={type}>
                  <Table.Cell collapsing>
                    <RequestType requestType={type} />
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button.Checkbox
                      checked={filteredTypes[type]}
                      onClick={() => {
                        filteredTypes[type] = !filteredTypes[type];
                        setFilteredTypes(filteredTypes);
                      }}
                      my={0.25}
                    />
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </div>
      }>
      <Button icon="cog" onClick={() => setFilterVisible(!filterVisible)}>
        Type Filter
      </Button>
    </Popper>
  );
};

/**
 * @file
 * @copyright 2021 bobbahbrown (https://github.com/bobbahbrown)
 * @license MIT
 */
import { useState } from 'react';
import {
  Button,
  Floating,
  Input,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { createSearch, decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  requests: Request[];
  fax_autoprinting: BooleanLike;
};

type Request = {
  id: string;
  req_type: string;
  owner: string;
  owner_ckey: string;
  owner_name: string;
  message: string;
  additional_info: string;
  timestamp: number;
  timestamp_str: string;
};

const displayTypeMap = {
  request_prayer: 'PRAYER',
  request_centcom: 'CENTCOM',
  request_syndicate: 'SYNDICATE',
  request_nuke: 'NUKE CODE',
  request_fax: 'FAX',
  request_internet_sound: 'INTERNET SOUND',
};

export const RequestManager = (props) => {
  const { act, data } = useBackend<Data>();
  const { requests = [] } = data;
  const [filteredTypes, setFilteredTypes] = useState(
    Object.fromEntries(
      Object.entries(displayTypeMap).map(([type, _]) => [type, true]),
    ),
  );
  const [searchText, setSearchText] = useState('');

  const updateFilter = (type) => {
    const newFilter = { ...filteredTypes };
    newFilter[type] = !newFilter[type];
    setFilteredTypes(newFilter);
  };

  // Handle filtering
  let displayedRequests = requests.filter(
    (request) => filteredTypes[request.req_type],
  );
  const search = createSearch(
    searchText,
    (requests: Request) =>
      requests.owner_name + decodeHtmlEntities(requests.message),
  );
  if (searchText.length > 0) {
    displayedRequests = displayedRequests.filter((request) => search(request));
  }

  return (
    <Window title="Request Manager" width={575} height={600} theme="admin">
      <Window.Content scrollable>
        <Section
          title="Requests"
          buttons={
            <Stack>
              <Stack.Item>
                <Button.Checkbox
                  checked={data.fax_autoprinting}
                  onClick={() => act('toggleprint')}
                  tooltip={
                    'Enables automatic printing of fax requests to the admin fax machine. By default, this fax is located in the briefing room at the central command station'
                  }
                >
                  Auto-print Faxes
                </Button.Checkbox>
                <Input
                  value={searchText}
                  onChange={setSearchText}
                  placeholder="Search..."
                  expensive
                  mr={1}
                />
              </Stack.Item>
              <Stack.Item>
                <FilterPanel
                  typesList={filteredTypes}
                  updateFilter={updateFilter}
                />
              </Stack.Item>
            </Stack>
          }
        >
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

const RequestType = (props) => {
  const { requestType } = props;

  return (
    <b className={`RequestManager__${requestType}`}>
      {displayTypeMap[requestType]}:
    </b>
  );
};

const RequestControls = (props) => {
  const { act } = useBackend<Data>();
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
      {request.req_type === 'request_fax' && (
        <>
          <Button onClick={() => act('show', { id: request.id })}>SHOW</Button>
          <Button onClick={() => act('print', { id: request.id })}>
            PRINT
          </Button>
        </>
      )}
      {request.req_type === 'request_internet_sound' && (
        <Button onClick={() => act('play', { id: request.id })}>PLAY</Button>
      )}
    </div>
  );
};

const FilterPanel = (props) => {
  const [filterVisible, setFilterVisible] = useState(false);
  const { typesList, updateFilter } = props;

  return (
    <div>
      <Floating
        placement="bottom-end"
        onOpenChange={setFilterVisible}
        contentClasses="RequestManager__filterPanel"
        content={
          <Table width="0">
            {Object.keys(displayTypeMap).map((type) => {
              return (
                <Table.Row className="candystripe" key={type}>
                  <Table.Cell collapsing>
                    <RequestType requestType={type} />
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button.Checkbox
                      checked={typesList[type]}
                      onClick={() => {
                        updateFilter(type);
                      }}
                      my={0.25}
                    />
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        }
      >
        <Button icon="cog" selected={filterVisible}>
          Type Filter
        </Button>
      </Floating>
    </div>
  );
};

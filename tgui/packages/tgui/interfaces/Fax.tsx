import { sortBy } from '../../common/collections';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type FaxData = {
  faxes: FaxInfo[];
  fax_id: string;
  fax_name: string;
  visible: boolean;
  has_paper: string;
  syndicate_network: boolean;
  fax_history: FaxHistory[];
  special_faxes: FaxSpecial[];
};

type FaxInfo = {
  fax_name: string;
  fax_id: string;
  visible: boolean;
  has_paper: boolean;
  syndicate_network: boolean;
};

type FaxHistory = {
  history_type: string;
  history_fax_name: string;
  history_time: string;
};

type FaxSpecial = {
  fax_name: string;
  fax_id: string;
  color: string;
  emag_needed: boolean;
};

export const Fax = (props) => {
  const { act } = useBackend();
  const { data } = useBackend<FaxData>();
  const faxes = data.faxes
    ? sortBy(
        data.syndicate_network
          ? data.faxes.filter((filterFax: FaxInfo) => filterFax.visible)
          : data.faxes.filter(
              (filterFax: FaxInfo) =>
                filterFax.visible && !filterFax.syndicate_network,
            ),
        (sortFax: FaxInfo) => sortFax.fax_name,
      )
    : [];
  const special_networks = data.syndicate_network
    ? data.special_faxes
    : data.special_faxes.filter((fax: FaxSpecial) => !fax.emag_needed);
  return (
    <Window width={340} height={540}>
      <Window.Content scrollable>
        <Section title="About Fax">
          <LabeledList.Item label="Network name">
            {data.fax_name}
          </LabeledList.Item>
          <LabeledList.Item label="Network ID">{data.fax_id}</LabeledList.Item>
          <LabeledList.Item label="Visible to Network">
            {data.visible ? true : false}
          </LabeledList.Item>
        </Section>
        <Section
          title="Paper"
          buttons={
            <Button
              onClick={() => act('remove')}
              disabled={data.has_paper ? false : true}
            >
              Remove
            </Button>
          }
        >
          <LabeledList.Item label="Paper">
            {data.has_paper ? (
              <Box color="green">Paper in tray</Box>
            ) : (
              <Box color="red">No paper</Box>
            )}
          </LabeledList.Item>
        </Section>
        <Section title="Send">
          {faxes.length === 0 && special_networks.length === 0 ? (
            "The fax couldn't detect any other faxes on the network."
          ) : (
            <Box mt={0.4}>
              {special_networks.map((special: FaxSpecial) => (
                <Button
                  key={special.fax_id}
                  tooltip={special.fax_name}
                  disabled={!data.has_paper}
                  color={special.color}
                  onClick={() =>
                    act('send_special', {
                      id: special.fax_id,
                      name: special.fax_name,
                    })
                  }
                >
                  {special.fax_name}
                </Button>
              ))}
              {faxes.length !== 0
                ? faxes.map((fax: FaxInfo) => (
                    <Button
                      key={fax.fax_id}
                      tooltip={fax.fax_name}
                      disabled={!data.has_paper}
                      color={fax.syndicate_network ? 'red' : 'blue'}
                      onClick={() =>
                        act('send', {
                          id: fax.fax_id,
                          name: fax.fax_name,
                        })
                      }
                    >
                      {fax.fax_name}
                    </Button>
                  ))
                : null}
            </Box>
          )}
        </Section>
        <Section
          title="History"
          buttons={
            <Button
              onClick={() => act('history_clear')}
              disabled={data.fax_history ? false : true}
            >
              Clear
            </Button>
          }
        >
          <Table>
            <Table.Cell>
              {data.fax_history !== null
                ? data.fax_history.map((history: FaxHistory) => (
                    <Table.Row key={history.history_type}>
                      {
                        <Box
                          color={
                            history.history_type === 'Send' ? 'Green' : 'Red'
                          }
                        >
                          {history.history_type}
                        </Box>
                      }
                      {history.history_fax_name} - {history.history_time}
                    </Table.Row>
                  ))
                : null}
            </Table.Cell>
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

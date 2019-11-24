import { toFixed } from 'common/math';
import { decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, Section, Table } from '../components';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';
import { classes } from 'common/react';

export const GulagItemReclaimer = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const mobs = data.name || [];
  return (
    <Section title="Stored Items">
      <Table>
        {mobs.map(mob => (
          <Table.Row key={mob.name}>
            <Table.Cell>
              {mob.name}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

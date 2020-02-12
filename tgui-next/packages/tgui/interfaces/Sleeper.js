import { useBackend } from '../backend';
import { Box, Section, LabeledList, Button, ProgressBar } from '../components';
import { Fragment } from 'inferno';

export const Sleeper = props => {
  const { act, data } = useBackend(props);

  const {
    open,
    occupant = {},
    occupied,
  } = data;

  const preSortChems = data.chems || [];
  const chems = preSortChems.sort((a, b) => {
    const descA = a.name.toLowerCase();
    const descB = b.name.toLowerCase();
    if (descA < descB) {
      return -1;
    }
    if (descA > descB) {
      return 1;
    }
    return 0;
  });

  const damageTypes = [
    {
      label: 'Brute',
      type: 'bruteLoss',
    },
    {
      label: 'Burn',
      type: 'fireLoss',
    },
    {
      label: 'Toxin',
      type: 'toxLoss',
    },
    {
      label: 'Oxygen',
      type: 'oxyLoss',
    },
  ];

  return (
    <Fragment>
      <Section
        title={occupant.name ? occupant.name : 'No Occupant'}
        minHeight="210px"
        buttons={!!occupant.stat && (
          <Box
            inline
            bold
            color={occupant.statstate}>
            {occupant.stat}
          </Box>
        )}>
        {!!occupied && (
          <Fragment>
            <ProgressBar
              value={occupant.health}
              minValue={occupant.minHealth}
              maxValue={occupant.maxHealth}
              ranges={{
                good: [50, Infinity],
                average: [0, 50],
                bad: [-Infinity, 0],
              }} />
            <Box mt={1} />
            <LabeledList>
              {damageTypes.map(type => (
                <LabeledList.Item
                  key={type.type}
                  label={type.label}>
                  <ProgressBar
                    value={occupant[type.type]}
                    minValue={0}
                    maxValue={occupant.maxHealth}
                    color="bad" />
                </LabeledList.Item>
              ))}
              <LabeledList.Item
                label="Cells"
                color={occupant.cloneLoss ? 'bad' : 'good'}>
                {occupant.cloneLoss ? 'Damaged' : 'Healthy'}
              </LabeledList.Item>
              <LabeledList.Item
                label="Brain"
                color={occupant.brainLoss ? 'bad' : 'good'}>
                {occupant.brainLoss ? 'Abnormal' : 'Healthy'}
              </LabeledList.Item>
            </LabeledList>
          </Fragment>
        )}
      </Section>
      <Section
        title="Medicines"
        minHeight="205px"
        buttons={(
          <Button
            icon={open ? 'door-open' : 'door-closed'}
            content={open ? 'Open' : 'Closed'}
            onClick={() => act('door')} />
        )}>
        {chems.map(chem => (
          <Button
            key={chem.name}
            icon="flask"
            content={chem.name}
            disabled={!(occupied && chem.allowed)}
            width="140px"
            onClick={() => act('inject', {
              chem: chem.id,
            })}
          />
        ))}
      </Section>
    </Fragment>
  );
};

import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, NumberInput, Section, NoticeBox, Grid, Input, Collapsible } from '../components';
import { map } from 'common/collections';

export const PandemicBeakerDisplay = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const {
    has_beaker,
    beaker_empty,
    has_blood,
    blood,
  } = data;

  const cant_empty = (!has_beaker || beaker_empty);

  return (
    <Section
      title="Beaker"
      buttons={(
        <Fragment>
          <Button
            icon="times"
            content="Empty and Eject"
            color="bad"
            disabled={cant_empty}
            onClick={() => act(ref, "empty_eject_beaker")}
          />
          <Button
            icon="trash"
            content="Empty"
            disabled={cant_empty}
            onClick={() => act(ref, "empty_beaker")}
          />
          <Button
            icon="eject"
            content="Eject"
            disabled={!has_beaker}
            onClick={() => act(ref, "eject_beaker")}
          />
        </Fragment>
      )}
    >
      {has_beaker ? (
        !beaker_empty ? (
          has_blood ? (
            <LabeledList>
              <LabeledList.Item label="Blood DNA">
                {(blood && blood.dna) || "Unknown"}
              </LabeledList.Item>
              <LabeledList.Item label="Blood Type">
                {(blood && blood.type) || "Unknown"}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="bad">
              No blood detected
            </Box>
          )
        ) : (
          <Box color="bad">
            Beaker is empty
          </Box>
        )
      ) : (
        <NoticeBox>
          No beaker loaded
        </NoticeBox>
      )}
    </Section>
  );
};

export const PandemicDiseaseDisplay = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const {
    is_ready,
  } = data;

  const viruses = data.viruses || [];

  return (
    viruses.map(virus => {
      const symptoms = virus.symptoms || [];
      return (
        <Section
          key={virus.name}
          title={!virus.is_adv && virus.can_rename ? (
            <Input
              value={virus.name}
              onChange={(e, value) => act(ref, "rename_disease", {index: virus.index, name: value})}
            />
          ) : (
            virus.name
          )}
          buttons={(
            <Button
              icon="flask"
              content="Create culture bottle"
              disabled={!is_ready}
              onClick={() => act(ref, "create_culture_bottle", {index: virus.index})}
            />
          )}
        >
          <Grid>
            <Grid.Column>
              {virus.description}
            </Grid.Column>
            <Grid.Column>
              <LabeledList>
                <LabeledList.Item label="Agent">
                  {virus.agent}
                </LabeledList.Item>
                <LabeledList.Item label="Spread">
                  {virus.spread}
                </LabeledList.Item>
                <LabeledList.Item label="Possible Cure">
                  {virus.cure}
                </LabeledList.Item>
              </LabeledList>
            </Grid.Column>
          </Grid>
          {!!virus.is_adv && (
            <Fragment>
              <Section
                title="Statistics"
                level={2}
              >
                <Grid>
                  <Grid.Column>
                    <LabeledList>
                      <LabeledList.Item label="Resistance">
                        {virus.resistance}
                      </LabeledList.Item>
                      <LabeledList.Item label="Stealth">
                        {virus.stealth}
                      </LabeledList.Item>
                    </LabeledList>
                  </Grid.Column>
                  <Grid.Column>
                    <LabeledList>
                      <LabeledList.Item label="Stage speed">
                        {virus.stage_speed}
                      </LabeledList.Item>
                      <LabeledList.Item label="Transmissibility">
                        {virus.transmission}
                      </LabeledList.Item>
                    </LabeledList>
                  </Grid.Column>
                </Grid>
              </Section>
              <Section
                title="Symptoms"
                level={2}
              >
                {symptoms.map(symptom => (
                  <Collapsible
                    key={symptom.name}
                    title={symptom.name}
                  >
                    <Section>
                      <PandemicSymptomDisplay symptom={symptom} />
                    </Section>
                  </Collapsible>
                ))}
              </Section>
            </Fragment>
          )}
        </Section>
      );
    })
  );
};

export const PandemicSymptomDisplay = props => {
  const { symptom } = props;
  const {
    name,
    desc,
    stealth,
    resistance,
    stage_speed,
    transmission,
    level,
    neutered,
  } = symptom;

  const thresholds = symptom.threshold_desc || {};

  return (
    <Section
      title={name}
      level={2}
      buttons={!!neutered && (
        <Box
          bold
          color="bad"
        >
          Neutered
        </Box>
      )}
    >
      <Grid>
        <Grid.Column size={2}>
          {desc}
        </Grid.Column>
        <Grid.Column>
          <LabeledList>
            <LabeledList.Item label="Level">
              {level}
            </LabeledList.Item>
            <LabeledList.Item label="Resistance">
              {resistance}
            </LabeledList.Item>
            <LabeledList.Item label="Stealth">
              {stealth}
            </LabeledList.Item>
            <LabeledList.Item label="Stage Speed">
              {stage_speed}
            </LabeledList.Item>
            <LabeledList.Item label="Transmission">
              {transmission}
            </LabeledList.Item>
          </LabeledList>
        </Grid.Column>
      </Grid>
      {thresholds !== {} && (
        <Section
          title="Thresholds"
          level={3}
        >
          <LabeledList>
            {map((desc, threshold) => {
              return (
                <LabeledList.Item
                  key={threshold}
                  label={threshold}
                >
                  {desc}
                </LabeledList.Item>
              );
            })(thresholds)}
          </LabeledList>
        </Section>
      )}
    </Section>
  );

};

export const PandemicAntibodyDisplay = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const resistances = data.resistances || [];

  return (
    <Section title="Antibodies">
      {resistances.length > 0 ? (
        <LabeledList>
          {resistances.map(resistance => (
            <LabeledList.Item
              key={resistance.name}
              label={resistance.name}
            >
              <Button
                icon="eye-dropper"
                content="Create vaccine bottle"
                disabled={!data.is_ready}
                onClick={() => act(ref, "create_vaccine_bottle", {index: resistance.id})}
              />
            </LabeledList.Item>
          ))}
        </LabeledList>
      ) : (
        <Box
          bold
          color="bad"
          mt={1}
        >
          No antibodies detected.
        </Box>
      )}
    </Section>
  );
};

export const Pandemic = props => {
  const { state } = props;
  const { data } = state;

  return (
    <Fragment>
      <PandemicBeakerDisplay state={state} />
      {!!data.has_blood && (
        <Fragment>
          <PandemicDiseaseDisplay state={state} />
          <PandemicAntibodyDisplay state={state} />
        </Fragment>
      )}
    </Fragment>
  );
};

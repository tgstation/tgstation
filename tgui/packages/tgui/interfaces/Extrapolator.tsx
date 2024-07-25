import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Section, Button, Tabs, LabeledList, Stack } from '../components';

type ExtrapolatorData = {
  varients: string[];
  diseases: DiseaseListData[];
};

type DiseaseListData = {
  name: string;
  ref: string;
  symptoms: SymptomListData[];
};

type SymptomListData = {
  name: string;
  ref: string;
};

export const Extrapolator = (props) => {
  const { act, data } = useBackend<ExtrapolatorData>();
  const { varients, diseases } = data;

  // State for selected disease and symptom
  const [selectedDisease, setSelectedDisease] = useLocalState<string | ''>(
    'selectedDisease',
    '',
  );
  const [selectedSymptom, setSelectedSymptom] = useLocalState<string | ''>(
    'selectedSymptom',
    '',
  );

  return (
    <Window title="Extrapolator" width={600} height={200}>
      <Window.Content>
        <Stack grow>
          <Stack.Item>
            <Section title="Diseases">
              <Tabs vertical>
                {diseases.map((disease) => (
                  <Tabs.Tab
                    key={disease.ref}
                    selected={selectedDisease === disease.ref}
                    onClick={() => setSelectedDisease(disease.ref)}
                  >
                    {disease.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>

          {selectedDisease && (
            <Stack.Item>
              <Section title="Symptoms">
                <Tabs vertical>
                  {diseases
                    .find((disease) => disease.ref === selectedDisease)
                    ?.symptoms.map((symptom) => (
                      <Tabs.Tab
                        key={symptom.ref}
                        selected={selectedSymptom === symptom.ref}
                        onClick={() => setSelectedSymptom(symptom.ref)}
                      >
                        {symptom.name}
                      </Tabs.Tab>
                    ))}
                </Tabs>
              </Section>
            </Stack.Item>
          )}

          {selectedSymptom && (
            <Stack.Item>
              <Stack grow>
                <Section title="Variants">
                  <LabeledList>
                    {varients.map((variant, index) => (
                      <LabeledList.Item key={index}>
                        <Button
                          onClick={() =>
                            act('add_varient', {
                              varient_name: variant,
                              disease_ref: selectedDisease,
                              symptom_ref: selectedSymptom,
                            })
                          }
                        >
                          {variant}
                        </Button>
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Section>
              </Stack>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

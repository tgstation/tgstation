import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Section, Box, LabeledList, ProgressBar } from '../components';

export const DnaConsole = props => {
  const { act, data } = useBackend(props);
  return (
    <Section
      title="DNA Console"
      textAlign="left">
      <Box>
        <Section
          title="Scanner Status"
          textAlign="left">
          <Box m={1}>
            <LabeledList>
              { data.IsScannerConnected
                ? data.ScannerOpen ? (
                  <LabeledList.Item label="Scanner Door">
                    Open
                  </LabeledList.Item>
                ) : (
                  <Fragment>
                    <LabeledList.Item label="Scanner Door">
                      Closed
                    </LabeledList.Item>
                    <LabeledList.Item label="Scanner Lock">
                      {data.ScannerLocked ? "Engaged" : "Released"}
                    </LabeledList.Item>
                  </Fragment>
                ) : (
                  <LabeledList.Item label="Scanner Door">
                    Error: No scanner connected.
                  </LabeledList.Item>
                )}
            </LabeledList>
          </Box>
        </Section>
        <Section
          title="Subject Status"
          textAlign="left">
          <Box m={1}>
            <LabeledList>
              { data.IsViableSubject
                ? (
                  <Fragment>
                    <LabeledList.Item label="Status">
                      {data.SubjectName}{" => "}
                      {data.SubjectStatus === data.CONSCIOUS
                        ? ("Conscious")
                        : data.SubjectStatus === data.UNCONSCIOUS
                          ? ("Unconscious")
                          : ("Dead")}
                    </LabeledList.Item>
                    <LabeledList.Item label="Health">
                      <ProgressBar
                        value={data.SubjectHealth}
                        minValue={0}
                        maxValue={100}
                        ranges={{
                          olive: [101, Infinity],
                          good: [70, 101],
                          average: [30, 70],
                          bad: [-Infinity, 30],
                        }}>
                        {data.SubjectHealth}%
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Radiation">
                      <ProgressBar
                        value={data.SubjectRads}
                        minValue={0}
                        maxValue={100}
                        ranges={{
                          bad: [71, Infinity],
                          average: [30, 71],
                          good: [0, 30],
                          olive: [-Infinity, 0],
                        }}>
                        {data.SubjectRads}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Unique Enzymes">
                      {data.SubjectEnzymes}
                    </LabeledList.Item>
                  </Fragment>
                ) : (
                  <LabeledList.Item label="Subject Status">
                    No viable subject in DNA Scanner.
                  </LabeledList.Item>
                )}
            </LabeledList>
          </Box>
        </Section>
      </Box>
    </Section>
  );
};

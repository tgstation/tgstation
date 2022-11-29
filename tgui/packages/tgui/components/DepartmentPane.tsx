import { Color } from 'common/color';
import { SFC } from 'inferno';
import { Box } from './Box';
import { Stack } from './Stack';

export interface BaseDepartmentInfo {
  color: string;
  jobs: { [x: string]: BaseJobInfo };
}

// Empty because the job info required can vary, and this component doesn't require any particular data from it.
export interface BaseJobInfo {}

// The cost of flexibility and prettiness.
export const DepartmentEntry: SFC<{
  style?;
  titleStyle?;
  textStyle?;
  title?;
  titleContents?;
  titleSubtext?;
}> = (props) => {
  return (
    <Box style={props.style}>
      {/* Yes, this box (line above) is missing the "Section" class. This is very intentional, as the layout looks *ugly* with it.*/}
      <Box class="Section__title" style={props.titleStyle}>
        <Box class="Section__titleText" style={props.textStyle}>
          {props.title}
          {props.titleContents}
        </Box>
        <div className="Section__buttons">{props.titleSubtext}</div>
      </Box>
      <Box class="Section__rest">
        <Box class="Section__content">{props.children}</Box>
      </Box>
    </Box>
  );
};

export const DepartmentPane: SFC<{
  departments: { [x: string]: BaseDepartmentInfo };
  jobEntryBuilder: (
    jobName: string,
    job: BaseJobInfo,
    department: BaseDepartmentInfo
  ) => object;
  titleSubtextBuilder?: (department: BaseDepartmentInfo) => object;
  entryWidth: string;
}> = (data) => {
  return (
    <Box wrap="wrap" style={{ 'columns': '20em' }}>
      {Object.entries(data.departments).map((entry) => {
        const departmentName = entry[0];
        const department = entry[1];
        return (
          <Box key={departmentName} minWidth={data.entryWidth}>
            <DepartmentEntry
              title={departmentName}
              style={{
                'background-color': department.color,
                'margin-bottom': '1em',
                'break-inside': 'avoid-column',
              }}
              titleStyle={{
                'border-bottom-color': Color.fromHex(department.color)
                  .darken(50)
                  .toString(),
                'min-height': '3.4rem',
              }}
              textStyle={{
                'color': Color.fromHex(department.color)
                  .darken(80)
                  .toString(),
              }}
              titleSubtext={
                data.titleSubtextBuilder && data.titleSubtextBuilder(department)
              }>
              <Stack vertical>
                {Object.entries(department.jobs).map((job) =>
                  data.jobEntryBuilder(job[0], job[1], department)
                )}
              </Stack>
            </DepartmentEntry>
          </Box>
        );
      })}
    </Box>
  );
};

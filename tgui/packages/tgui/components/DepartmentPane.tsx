import { Color } from 'common/color';
import { SFC } from 'inferno';
import { Box } from './Box';
import { Stack } from './Stack';

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
      {/* Yes, this box is missing the "Section" class. This is very intentional, as the layout looks *ugly* with it.*/}
      <Box class="Section__title" style={props.titleStyle}>
        <Box class="Section__titleText" style={props.textStyle}>
          {props.title}
          {props.titleContents}
        </Box>
        {props.titleSubtext}
        <br style={{ 'clear': 'both' }} />
      </Box>
      <Box class="Section__rest">
        <Box class="Section__content">{props.children}</Box>
      </Box>
    </Box>
  );
};

export const DepartmentPane: SFC<{
  act;
  departments: object[];
  jobEntryBuilder: (job: object, department: object) => object;
  titleSubtextBuilder: (department: object) => object;
  entryWidth: string;
}> = (data) => {
  return (
    <Box wrap="wrap" style={{ 'columns': '20em' }}>
      {data.departments.map((department) => {
        return (
          <Box key={department['name']} minWidth={data.entryWidth}>
            <DepartmentEntry
              title={department['name']}
              style={{
                'background-color': department['color'],
                'margin-bottom': '1em',
                'break-inside': 'avoid-column',
              }}
              titleStyle={{
                'border-bottom-color': Color.fromHex(department['color'])
                  .darken(50)
                  .toString(),
                'min-height': '3.4rem',
              }}
              textStyle={{
                'color': Color.fromHex(department['color'])
                  .darken(80)
                  .toString(),
              }}
              titleSubtext={data.titleSubtextBuilder(department)}>
              <Stack vertical>
                {department['jobs'].map((job) =>
                  data.jobEntryBuilder(job, department)
                )}
              </Stack>
            </DepartmentEntry>
          </Box>
        );
      })}
    </Box>
  );
};

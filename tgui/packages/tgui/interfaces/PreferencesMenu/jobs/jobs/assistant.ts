import { Job } from "../base";
import { Assistant as DepartmentAssistant } from "../departments";

const Assistant: Job = {
  name: "Assistant",
  description: "Get your space legs, assist people, ask the HoP to \
    give you a job.",
  department: DepartmentAssistant,
};

export default Assistant;

import { Job } from "../base";
import { Assistant as DepartmentAssistant } from "../departments";

const Prisoner: Job = {
  name: "Prisoner",
  description: "Keep yourself occupied while in permabrig.",
  department: DepartmentAssistant,
};

export default Prisoner;

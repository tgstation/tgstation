import { Job } from "../base";
import { Medical } from "../departments";

const Paramedic: Job = {
  name: "Paramedic",
  description: "Run around the station looking for patients, respond to \
    emergencies, give patients a roller bed ride to medbay.",
  department: Medical,
};

export default Paramedic;

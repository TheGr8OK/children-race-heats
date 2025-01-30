import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["addButton", "studentFields", "studentField", "template"];
  static values = {
    counter: Number,
  };

  connect() {
    this.element.closest("form").addEventListener("submit", () => {
      this.cleanUpEmptyStudentFields();
    });

    this.updateCounterValue();
  }

  addStudent() {
    const lastStudentField = this.element.querySelector(
      "[data-race-memberships-target='studentField']:last-of-type"
    );

    const lastStudentSelect = lastStudentField.querySelector("select");
    const lastStudentFieldInput = lastStudentField.querySelector("input");
    if (lastStudentField) {
      if (lastStudentSelect.value === "") {
        lastStudentSelect.focus();
        return;
      } else if (lastStudentFieldInput.value === "") {
        lastStudentFieldInput.focus();
        return;
      }
    }

    const templateContent = this.templateTarget.content.cloneNode(true);
    this.studentFieldsTarget.appendChild(templateContent);
    this.setupNewFields();
    this.updateCounterValue();

    this.studentFieldsTarget.lastElementChild.scrollIntoView({
      behavior: "smooth",
      block: "end",
    });
  }

  setupNewFields() {
    const newSelect =
      this.studentFieldsTarget.lastElementChild.querySelector("select");
    const newInput =
      this.studentFieldsTarget.lastElementChild.querySelector("input");

    newSelect.name = `race_form[race_memberships][membership_${this.counterValue}][student_id]`;
    newSelect.id = `race_form_race_memberships_membership_${this.counterValue}_student_id`;
    newInput.name = `race_form[race_memberships][membership_${this.counterValue}][lane_number]`;
    newInput.id = `race_form_race_memberships_membership_${this.counterValue}_lane_number`;

    newSelect.focus();
  }

  updateCounterValue() {
    this.counterValue += 1;
  }

  cleanUpEmptyStudentFields() {
    this.studentFieldTargets.forEach((field) => {
      const select = field.querySelector("select");
      const input = field.querySelector("input");
      if (select.value === "" && input.value === "") {
        console.log("removing field");
        field.remove();
      }
    });
  }
}

import bulmaCalendar from "bulma-calendar";
import "bulma-calendar/dist/css/bulma-calendar.min.css";

const reattach = () => {
  const calendars = bulmaCalendar.attach(
    '#datePicker[type="date"]',
    calendarOptions
  );
  return calendars[0];
};

const calendarOptions = {
  type: "date",
  // color: 'primary',
  // isRange: false,
  // allowSameDayRange: true,
  lang: "uk",
  startDate: new Date(),
  // startDate: undefined,
  // endDate: undefined,
  // disabledDates: [],
  // disabledWeekDays: undefined,
  // highlightedDates: [],
  // weekStart: 0,
  dateFormat: "dd/MM/yyyy",
  // enableMonthSwitch: true,
  // enableYearSwitch: true,
  // displayYearsCount: 50,
};
export const CalendarItem = {
  beforeUpdate() {
    // const calendars = bulmaCalendar.attach('[type="date"]', calendarOptions);
  },
  updated() {
    const calendar = reattach();
    // TODO: cleanup
    calendar.on("select", (date) => {
      console.log(date.data.value());
      this.pushEvent("date-selected", { date: date.data.value() });
    });
    // const calendars = bulmaCalendar.attach('[type="date"]', calendarOptions);
  },
  reconnected() {
    // const calendars = bulmaCalendar.attach('[type="date"]', calendarOptions);
  },
  mounted() {
    // console.log("mounted");
    const self = this;
    document.querySelectorAll('[type="date"]').forEach((el) => {
      //   console.log(el);
    });
    const datePicker = document.getElementById("datePicker");
    datePicker.style.display = "none";
    // reattach();
    // console.log(calendars[0].value());
    // setTimeout(() => {
    //   //   datePicker.style.display = "block";
    // }, 5000);
    // (
    //   document.querySelectorAll('.modal-background, .modal-close, .modal-card-head .delete, .modal-card-foot .button')
    //   || []
    // ).forEach(($close) => {

    //   $close.addEventListener('click', () => {
    //     self.pushEvent("close-modal");
    //   });
    // })
  },
};

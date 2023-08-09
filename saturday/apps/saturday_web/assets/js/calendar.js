// import bulmaCalendar from "bulma-calendar";
// import "bulma-calendar/dist/css/bulma-calendar.min.css";

// const calendarOptions = {
// 	type: 'date',
// 	// color: 'primary',
// 	// isRange: false,
// 	// allowSameDayRange: true,
// 	lang: 'uk',
// 	startDate: new Date(),
// 	// startDate: undefined,
// 	// endDate: undefined,
// 	// disabledDates: [],
// 	// disabledWeekDays: undefined,
// 	// highlightedDates: [],
// 	// weekStart: 0,
// 	// dateFormat: 'MM/dd/yyyy',
// 	// enableMonthSwitch: true,
// 	// enableYearSwitch: true,
// 	// displayYearsCount: 50,
// }
// const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// const targetNode = document.getElementById("datePicker");

// // Options for the observer (which mutations to observe)
// const config = { attributes: true, childList: true, subtree: true };

// // Callback function to execute when mutations are observed
// const callback = (mutationList, observer) => {
// 	// for (const mutation of mutationList) {
// 	// 	console.log(mutationList)
// 	// 	if (mutation.type === "") {

// 	// 	}
// 	//   if (mutation.type === "childList") {
// 	//     console.log("A child node has been added or removed.");
// 	//   } else if (mutation.type === "attributes") {
// 	//     console.log(`The ${mutation.attributeName} attribute was modified.`);
// 	//   }
// 	// }
// };

// document.addEventListener('DOMContentLoaded', async () => {
// 	// 	var calendars = new bulmaCalendar('.bulmaCalendar', {
// 	// await sleep(200);
// 	// 		dateFormat: 'dd.MM.yyyy' // 01.01.2021
// 	// 	});
// 	// 	console.log(calendars)
// 	// Initialize all input of date type.

// 	let options = {
// 		root: document.querySelector("body"),
// 		// rootMargin: "0px",
// 		threshold: 1.0,
// 	};

// 	let observer2 = new IntersectionObserver((...args) => {
// 		console.log(args)
// 		const calendars = bulmaCalendar.attach('[type="date"]', calendarOptions);
// 		console.log('observer2');
// 		// observer2.disconnect();
// 	}, options);
// 	observer2.observe(document.querySelector("#datePicker"));

// 	const callback = () => {
// 		console.log('callback')
// 	}

// 	const observer = new MutationObserver(callback);
// 	if (targetNode) observer.observe(targetNode, config);

// 	// console.log(calendars);
// 	// Loop on each calendar initialized
// 	// calendars.forEach(calendar => {

// 	// 	console.log(calendar.date, calendar.isOpen());
// 	// 	setTimeout(() => {
// 	// 		console.log(calendar.date, calendar.isOpen());
// 	// 	}, 500)
// 	// 	// Add listener to select event
// 	// 	calendar.on("select:start", date => {
// 	// 		console.log(date);
// 	// 	})
// 	// 	calendar.on('select', date => {
// 	// 		console.log(date);
// 	// 	});
// 	// });
// });
// // import our components
import { BarChart } from "./barChart.js";

let bar1, bar2, bar3;

// global state
let state = {
  data: []
};

/* LOAD DATA */
d3.csv('data_to_visualize/01-prompt_LDA_3.csv', d3.autoType)
  .then(data => {
    
    console.log("data", data);
    state.data = data;

    init();
  });

function init() {

  bar1 = new BarChart(1);
  bar2 = new BarChart(2);
  bar3 = new BarChart(3);

  draw();
}

function draw() {
  bar1.draw(state.data)
  bar2.draw(state.data)
  bar3.draw(state.data)
}

function setGlobalState(nextState) {
  state = { ...state, ...nextState };

  console.log("STATE", state)
  draw();
}
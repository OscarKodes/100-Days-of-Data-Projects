/* CONSTANTS AND GLOBALS */
const width = window.innerWidth * .8;
const height = 600;
const margin = 100;

/* LOAD DATA */
d3.csv('data_to_visualize/01-prompt_LDA_3.csv', d3.autoType)
  .then(data => {

    const data1 = data.filter(obj => obj.topic === 1);

    console.log(data1);


    /* SCALES */
    const xScale = d3.scaleLinear()
      .domain([0, d3.max(data1, d => d.beta)])
      .range([0, width - margin * 2])
      .nice()

    const yScale = d3.scaleBand()
      .domain(data1.map(d => d.term))
      .range([0, height - margin])
      .paddingInner(.2)
      .paddingOuter(.1)

    // AXIS
    const xAxis = d3.axisBottom()
      .scale(xScale);

    const yAxis = d3.axisLeft()
      .scale(yScale);
    
    /* HTML ELEMENTS */
    
    // svg 
    const svg = d3.select("#container")
      .append("svg")
      .attr("width", width)
      .attr("height", height)

    // bars
    svg.selectAll(".bar")
      .data(data1)
      .join(
        enter => enter
          .append("rect")
          .attr("class", "dot")
          .attr("height", yScale.bandwidth())
          .attr("x", 0)
          .attr("y", d => yScale(d.term))
          .attr("transform", `translate(${margin}, 0)`)
          .attr("stroke", "grey")
          .attr("width", d => xScale(d.beta))
          .attr("fill", d3.schemeSet3[0])
      );

    // bar numbers
    svg.selectAll(".bar-nums")
      .data(data1)
      .join(
        enter => enter
          .append("text")
          .attr("class", "bar-nums")
          .attr("y", d => yScale(d.term) + yScale.bandwidth() / 2)
          .text(d => `${Math.round(d.beta * 1000) / 1000}`)
          .attr("opacity", 1)
          .attr("x", d => xScale(d.beta) + margin + 10)
      )
      

    // xAxis ticks
    svg.append("g")
      .attr("transform", `translate(${margin}, ${height - margin})`)
      .style("font-size", "0.8rem")
      .call(xAxis);

    // yAxis ticks
    svg.append("g")
      .attr("transform", `translate(${margin}, 0)`)
      .style("font-size", "0.8rem")
      .call(yAxis);

    // xAxis title
    svg.append("text")
      .attr("text-anchor", "end")
      .attr("x", (width / 2) + margin)
      .attr("y", height - margin * .5)
      .style("font-weight", "bold")
      .style("font-size", "1.1rem")
      .text("Beta");

    // yAxis title
    svg.append("text")
      .attr("y", margin / 8)
      .attr("x", -margin * 2.5)
      .attr("transform", "rotate(-90)")
      .style("font-weight", "bold")
      .style("font-size", "1.1rem")
      .text("Term");
  });
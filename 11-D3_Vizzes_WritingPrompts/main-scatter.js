// CONSTANTS ################################################
const margin = 50,
radius = 5;

const allGenres = ["Comedy", "Drama", "Adventure", "Thriller", "Horror", "Action", "Romance"];
const allColors = ["Yellow", "Red", "Green", "Purple", "Black", "Blue", "Pink"];

let width = 600;
let height = width;


// IMPORT IN DATA ############################################
d3.csv("data_to_visualize/03-prompts_sentiments3.csv", d3.autoType).then(data => {
  
  
    console.log(data);


    // SCALES =================================================
    const xScale = d3.scaleLinear()
        .domain(d3.extent(data, d => d["positive"]))
        .range([margin, width - margin]);

    const yScale = d3.scaleLinear()
        .domain(d3.extent(data, d => d["negative"]))
        .range([height - margin, margin]);


    // CREATE MAIN SVG ELEMENT ==================================
    const svg = d3.select("#scatter")
        .append("svg")
        .attr("height", height)
        .attr("width", width)
        .style("background-color", "lavender");

    // AXIS TICKS  ----------------------------------------------
    svg.append("g")
        .attr("transform", `translate(0,${height - margin})`)
        .call(d3.axisBottom(xScale));

    svg.append("g")
        .attr("transform", `translate(${margin},0)`)
        .call(d3.axisLeft(yScale));

    // AXIS LABELS ----------------------------------------------
    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("x", width / 2)
        .attr("y", height - 6)
        .style("font-weight", "bold")
        .style("font-size", "1.2rem")
        .text("Negative Sentiment");

    svg.append("text")
        .attr("text-anchor", "end")
        .attr("x", -height / 2 + margin * 2)
        .attr("y", 15)
        .style("font-weight", "bold")
        .style("font-size", "1.2rem")
        .attr("transform", "rotate(-90)")
        .text("Positive Sentiment");

    // TITLE ----------------------------------------------------
    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("x", width / 2)
        .attr("y", 30)
        .style("font-weight", "bold")
        .style("font-size", "1.2rem")
        .text("Writing Prompts Sentiments");


    // Draw SVG Scatterplot ==========================================
    const dots = svg.selectAll("circle.dot")
        .data(data, d => d.doc_id)
        .join(
            enter => enter
            .append("rect")
                .attr("class", "dot")
                .attr("width", 30)
                .attr("height", 30)
                .attr("transform", d => `translate(${xScale(d["negative"])},
                                        ${yScale(d["positive"]) - 30})`)
                .attr("fill-opacity", "0.05")
                .attr("fill", "black")
        );


    // Add sentiment 0 line --------------------------------------------
    svg.append("line")
        .attr("x1", xScale(0))
        .attr("y1", yScale(0))
        .attr("x2", xScale(8))
        .attr("y2", yScale(8))
        .attr("stroke-width", "2px")
        .attr("stroke", "#77DD77")
        .attr("opacity", 0.5)
});

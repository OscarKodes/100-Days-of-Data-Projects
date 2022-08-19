// CONSTANTS ################################################


// const viewWidth = window.innerWidth > 1080 ? 1080 : window.innerWidth;
const viewHeight = window.innerHeight > 1744 ? 
                  1744 : window.innerHeight < 1200 ?
                  1200 : window.innerHeight;
const isMobile = window.innerWidth < 1080;

// const width = viewWidth * 0.9;
const height = viewHeight * 0.5;
const width = height;

const margin = isMobile ? 85 : 60;
const marginLeft = 10;
const radius = 5;

// IMPORT IN DATA ############################################
d3.csv("data_to_visualize/03-prompts_sentiments3.csv", d3.autoType).then(data => {
  
  
    console.log(data);


    // SCALES =================================================
    const xScale = d3.scaleLinear()
        // .domain(d3.extent(data, d => d["negative"]))
        .domain([0, 10])
        .range([margin + marginLeft, width - margin]);

    const yScale = d3.scaleLinear()
        // .domain(d3.extent(data, d => d["positive"]))
        .domain([0, 10])
        .range([height - margin, margin]);


    // CREATE MAIN SVG ELEMENT ==================================
    const svg = d3.select("#scatter")
        .append("svg")
        .attr("height", height)
        .attr("width", width)
        // .style("background-color", "lavender");

    // AXIS TICKS  ----------------------------------------------

    //  X-ticks
    svg.append("g")
        .attr("transform", `translate(0,${height - margin})`)
        .style("font-size", "1.8rem")
        .call(d3.axisBottom(xScale));

    //  Y-ticks
    svg.append("g")
        .attr("transform", `translate(${margin + marginLeft},0)`)
        .style("font-size", "1.8rem")
        .call(d3.axisLeft(yScale));

    // AXIS Titles ----------------------------------------------

    // X-Axis Title
    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("x", width / 2)
        .attr("y", height - 6)
        .style("font-weight", "bold")
        .style("font-size", "2.5rem")
        .style("fill", "#444")
        .text("Negative Sentiment");

    // Y-axis Title
    svg.append("text")
        .attr("text-anchor", "end")
        .attr("x", -280)
        .attr("y", 40)
        .style("font-weight", "bold")
        .style("font-size", "2.5rem")
        .style("fill", "#444")
        .attr("transform", "rotate(-90)")
        .text("Positive Sentiment");

    // TITLE ----------------------------------------------------
    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("x", width / 2)
        .attr("y", 40)
        .style("font-weight", "bold")
        .style("font-size", "2.8rem")
        .style("fill", "#111")
        .text("Writing Prompts Sentiments");


    // Draw SVG Scatterplot ==========================================
    const dots = svg.selectAll("circle.dot")
        .data(data, d => d.doc_id)
        .join(
            enter => enter
            .append("rect")
                .attr("class", "dot")
                .attr("width", height / 14)
                .attr("height", height / 14)
                .attr("transform", d => `translate(${xScale(d["negative"])},
                                        ${yScale(d["positive"]) - (height / 14)})`)
                .attr("fill-opacity", "0.05")
                .attr("fill", "black")
        );


    // Add sentiment 0 line --------------------------------------------
    svg.append("line")
        .attr("x1", xScale(0) + marginLeft)
        .attr("y1", yScale(0))
        .attr("x2", xScale(10) + marginLeft)
        .attr("y2", yScale(10))
        .attr("stroke-width", "5px")
        .attr("stroke", "#77DD77")
        .attr("opacity", 0.5)
        .attr("transform", d => `translate(-10, 0)`)
});

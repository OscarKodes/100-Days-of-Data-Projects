class BarChart {

    constructor(barNum) {

      this.width = 630;
      this.height = 260;
      this.margin = 60;
      this.duration = 1000;
      this.barNum = barNum;

      this.svg = d3
        .select("#bar-" + this.barNum)
        .append("svg")
        .attr("width", this.width)
        .attr("height", this.height)
        .style("border-bottom", "1px solid #555")
        // .style("background-color", "olive")
        // .style("transform", "translate(2px, 0px)");
    }

    draw(data) {

        const filteredData = data.filter(d=> d.topic === this.barNum);

        console.log(filteredData);
    
    
        /* SCALES */
        const xScale = d3.scaleLinear()
          .domain([0, d3.max(filteredData, d => d.beta)])
          .range([20, this.width - this.margin * 2.5])
          .nice()
    
        const yScale = d3.scaleBand()
          .domain(filteredData.map(d => d.term))
          .range([this.margin, this.height - this.margin])
          .paddingInner(.2)
          .paddingOuter(.1)
    
        // AXIS
        const xAxis = d3.axisBottom()
          .scale(xScale);
    
        const yAxis = d3.axisLeft()
          .scale(yScale);
        
        /* HTML ELEMENTS */
    
        const colors = ["#E8ACBD",
                        "#AED7EB",
                        "#A9DBC7"]
    
        // bars
        this.svg.selectAll(".bar")
          .data(filteredData)
          .join(
            enter => enter
              .append("rect")
              .attr("class", "dot")
              .attr("height", yScale.bandwidth())
              .attr("x", 0)
              .attr("y", d => yScale(d.term))
              .attr("transform", `translate(${this.margin + 20}, 0)`)
              .attr("stroke", "grey")
              .attr("width", d => xScale(d.beta))
              .attr("fill", colors[this.barNum - 1])
          );
    
        // bar numbers
        this.svg.selectAll(".bar-nums")
          .data(filteredData)
          .join(
            enter => enter
              .append("text")
              .attr("class", "bar-nums")
              .attr("x", d => xScale(d.beta) + this.margin + 25)
              .attr("y", d => yScale(d.term) + yScale.bandwidth() - 2)
              .style("font-size", "0.75rem")
              .text(d => `${Math.round(d.beta * 1000) / 1000}`)
          )
          
    
        // xAxis ticks
        this.svg.append("g")
          .attr("transform", `translate(${this.margin}, 
                                    ${this.height - this.margin})`)
          .style("font-size", "0.6rem")
          .call(xAxis);
    
        // yAxis ticks
        this.svg.append("g")
          .attr("transform", `translate(${this.margin + 20}, 0)`)
          .style("font-size", "0.6rem")
          .call(yAxis);
    
        // xAxis title
        this.svg.append("text")
          .attr("text-anchor", "end")
          .attr("x", 320)
          .attr("y", 240)
          .style("font-weight", "bold")
          .style("font-size", "0.9rem")
          .text("Beta");
    
        // yAxis title
        this.svg.append("text")
          .attr("y", 20)
          .attr("x", -145)
          .attr("transform", "rotate(-90)")
          .style("font-weight", "bold")
          .style("font-size", "0.9rem")
          .text("Term");
        
        const barTitles = {
            1: "Cluster 1: Death & Immortality",
            2: "Cluster 2: Society & Work",
            3: "Cluster 3: Earth & Aliens"
        }

        // Vis Title
        this.svg.append("text")
            .attr("text-anchor", "middle")
            .attr("x", 310)
            .attr("y", 30)
            .style("font-weight", "bold")
            .style("font-size", "1.05rem")
            .text(barTitles[this.barNum]);
    }
  }
  
  export { BarChart };
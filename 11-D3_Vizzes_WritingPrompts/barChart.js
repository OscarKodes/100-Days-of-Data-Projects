class BarChart {

    constructor(barNum) {

      this.viewWidth = window.innerWidth > 1080 ? 1080 : window.innerWidth;
      this.viewHeight = window.innerHeight > 1744 ? 
                        1744 : window.innerHeight < 1200 ?
                        1200 : window.innerHeight;
      this.isMobile = window.innerWidth < 1080;

      this.width = this.viewWidth * 0.9;
      this.height = this.viewHeight * 0.4;
      this.margin = 100;
      this.marginLeft = 75;
      this.duration = 1000;
      this.barNum = barNum;

      this.svg = d3
        .select("#bar-" + this.barNum)
        .append("svg")
        .attr("width", this.width)
        .attr("height", this.height)
        .style("border-bottom", "1px solid #555")
        .style("padding", "2rem 0")
        // .style("background-color", "lavender")
        // .style("transform", "translate(2px, 0px)");
    }

    draw(data) {

        const filteredData = data.filter(d=> d.topic === this.barNum);

        console.log(filteredData);
    
    
        /* SCALES */
        const xScale = d3.scaleLinear()
          .domain([0, d3.max(filteredData, d => d.beta)])
          .range([this.marginLeft, this.width - this.margin * 1.8])
          .nice()
    
        const yScale = d3.scaleBand()
          .domain(filteredData.map(d => d.term))
          .range([this.margin, this.height - this.margin])
          .paddingInner(.2)
          .paddingOuter(.1)
    
        // AXIS
        const xAxis = d3.axisBottom()
          .scale(xScale)
          .ticks(4);
    
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
              .attr("transform", `translate(${this.margin + this.marginLeft}, 0)`)
              .attr("stroke", "grey")
              .attr("width", d => xScale(d.beta) - this.marginLeft)
              .attr("fill", colors[this.barNum - 1])
          );
    
        // bar numbers
        this.svg.selectAll(".bar-nums")
          .data(filteredData)
          .join(
            enter => enter
              .append("text")
              .attr("class", "bar-nums")
              .attr("x", d => xScale(d.beta) + this.margin + 10)
              .attr("y", d => yScale(d.term) + yScale.bandwidth() - (this.isMobile ? 15 : 11))
              .style("font-size", "1.8rem")
              .text(d => `${Math.round(d.beta * 1000) / 1000}`)
          )
          
    
        // xAxis ticks
        this.svg.append("g")
          .attr("transform", `translate(${this.margin}, 
                                    ${this.height - this.margin})`)
          .style("font-size", "1.7rem")
          .call(xAxis);
    
        // yAxis ticks
        this.svg.append("g")
          .attr("transform", `translate(${this.margin + this.marginLeft}, 0)`)
          .style("font-size", "1.8rem")
          .call(yAxis);
    
        // xAxis title
        this.svg.append("text")
          .attr("text-anchor", "end")
          .attr("x", this.isMobile ? 470 : 520)
          .attr("y", this.isMobile ? 680 : 430)
          .style("font-weight", "bold")
          .style("font-size", "2.5rem")
          .style("fill", "#444")
          .text("Beta");
    
        // yAxis title
        this.svg.append("text")
          .attr("y", this.isMobile ? 40 : 85)
          .attr("x", this.isMobile ? -400 : -280)
          .attr("transform", "rotate(-90)")
          .style("font-weight", "bold")
          .style("font-size", "2.5rem")
          .style("fill", "#444")
          .text("Term");
        
        const barTitles = {
            1: "Cluster 1: Death & Immortality",
            2: "Cluster 2: Society & Work",
            3: "Cluster 3: Earth & Aliens"
        }

        // Vis Title
        this.svg.append("text")
            .attr("text-anchor", "middle")
            .attr("x", this.isMobile ? 430 : 500)
            .attr("y", 50)
            .style("font-weight", "bold")
            .style("font-size", "2.8rem")
            .style("fill", "#111")
            .text(barTitles[this.barNum]);
    }
  }
  
  export { BarChart };
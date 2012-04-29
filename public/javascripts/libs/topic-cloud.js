
var TopicCloud = function(words, which, options) {
  this.words = words;
  this.which = which;
  
  this.options = {
    minWordSize: 7,
    maxWordSize: 16,
    width: 250,
    height: 150,
    font: "Baskerville"
  };

  if (options) {
    for (key in options) {
      this.options[key] = options[key];
    }
  }

  this.draw();
}

TopicCloud.prototype.draw = function() {
  var self  = this;
  var words = self.words;
  var fill  = d3.scale.category20b();

  var fontSize = d3.scale.log()
    .range([self.options.minWordSize, self.options.maxWordSize]);

  var layout = d3.layout.cloud()
    .size([self.options.width, self.options.height])
    .fontSize(function(d) { 
      size = fontSize(+d.size);
      return size;
    })
    .rotate(function(d) { 
      return Math.max(-90, Math.min(90, 0)); 
    })
    .on("end", run)
    .words(words)
    .start();

   function run(words) {
    d3.select("#topic"+self.which).append("svg")
      .attr("width", self.options.width - 20)
      .attr("height", self.options.height)
    .append("g")
      .attr("transform", "translate(" + self.options.width / 2 + "," + self.options.height / 2 + ")")
    .selectAll("text")
      .data(words)
    .enter().append("text")
      .style("font-family", self.options.font)
      .style("font-size", function(d) { return d.size + "px"; })
      .attr("text-anchor", "middle")
      .attr("transform", function(d) {
        console.log(d);
        return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
      })
      .text(function(d) { return d.text; });
  }
}

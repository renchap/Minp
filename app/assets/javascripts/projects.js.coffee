$( ->
  # From http://mbostock.github.io/d3/talk/20111018/tree.html
  # Initialize the display to show a few nodes.
  update = (source) ->
    duration = (if d3.event and d3.event.altKey then 5000 else 500)
    
    # Compute the new tree layout.
    nodes = tree.nodes(root).reverse()
    
    # Normalize for fixed-depth.
    nodes.forEach (d) ->
      d.y = d.depth * 120
  
    
    # Update the nodes…
    node = vis.selectAll("g.node").data(nodes, (d) ->
      d.id or (d.id = ++i)
    )
    
    # Enter any new nodes at the parent's previous position.
    nodeEnter = node.enter().append("svg:g").attr("class", "node").attr("transform", (d) ->
      "translate(" + source.y0 + "," + source.x0 + ")"
    ).on("click", (d) ->
      toggle d
      update d
    )
    nodeEnter.append("svg:circle").attr("r", 1e-6).style "fill", (d) ->
      (if d._children then "lightsteelblue" else "#fff")
  
    nodeEnter.append("svg:text").attr("x", (d) ->
      (if d.children or d._children then -10 else 10)
    ).attr("dy", ".35em").attr("text-anchor", (d) ->
      (if d.children or d._children then "end" else "start")
    ).text((d) ->
      d.name
    ).style "fill-opacity", 1e-6
    
    # Transition nodes to their new position.
    nodeUpdate = node.transition().duration(duration).attr("transform", (d) ->
      "translate(" + d.y + "," + d.x + ")"
    )
    nodeUpdate.select("circle").attr("r", 4.5).style "fill", (d) ->
      (if d._children then "lightsteelblue" else "#fff")
  
    nodeUpdate.select("text").style "fill-opacity", 1
    
    # Transition exiting nodes to the parent's new position.
    nodeExit = node.exit().transition().duration(duration).attr("transform", (d) ->
      "translate(" + source.y + "," + source.x + ")"
    ).remove()
    nodeExit.select("circle").attr "r", 1e-6
    nodeExit.select("text").style "fill-opacity", 1e-6
    
    # Update the links…
    link = vis.selectAll("path.link").data(tree.links(nodes), (d) ->
      d.target.id
    )
    
    # Enter any new links at the parent's previous position.
    link.enter().insert("svg:path", "g").attr("class", "link").attr("d", (d) ->
      o =
        x: source.x0
        y: source.y0
  
      diagonal
        source: o
        target: o
  
    ).transition().duration(duration).attr "d", diagonal
    
    # Transition links to their new position.
    link.transition().duration(duration).attr "d", diagonal
    
    # Transition exiting nodes to the parent's new position.
    link.exit().transition().duration(duration).attr("d", (d) ->
      o =
        x: source.x
        y: source.y
  
      diagonal
        source: o
        target: o
  
    ).remove()
    
    # Stash the old positions for transition.
    nodes.forEach (d) ->
      d.x0 = d.x
      d.y0 = d.y
  
  
  # Toggle children.
  toggle = (d) ->
    if d.children
      d._children = d.children
      d.children = null
    else
      d.children = d._children
      d._children = null
  m = [80, 20, 20, 20]
  w = $(window).width() - m[1] - m[3]
  h = $(window).height() - m[0] - m[2]
  i = 0
  root = undefined
  tree = d3.layout.tree().size([h, w])
  diagonal = d3.svg.diagonal().projection((d) ->
    [d.y, d.x]
  )

  outer = d3.select('.project-graph')
    .append("svg:svg")
    .attr("width", w)
    .attr("height", h)
    .attr("pointer-events", "all")

  rescale = ->
    console.log 'toto'
    vis.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
 
    #let's rescale/reposition rectangle that using for dragging
    scale = 1 / d3.event.scale;
    vis.selectAll('rect')
      .attr("transform", "translate(" + [-1 * (scale * d3.event.translate[0]), -1 * (scale * d3.event.translate[1])] + ")" + " scale(" + scale + ")");


  vis = outer.append("svg:g")
    .call(d3.behavior.zoom().on("zoom", rescale))
    .append('svg:g')
 
  d3.json $('.project-graph').data('source'), (json) ->
    toggleAll = (d) ->
      if d.children
        d.children.forEach toggleAll
        toggle d
    root = json
    root.x0 = h / 2
    root.y0 = 0
    update root
)
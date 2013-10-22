$( ->

  m = [60, 0, 30, 0]
  w = $(window).width() - m[1] - m[3]
  h = $(window).height() - m[0] - m[2]
  maxi = 0

  # From http://mbostock.github.io/d3/talk/20111018/tree.html
  update = (source) ->
    duration = (if d3.event and d3.event.altKey then 5000 else 500)
    
    # Compute the new tree layout.
    nodes = tree.nodes(root).reverse()
    
    # Normalize for fixed-depth.
    nodes.forEach (d) ->
      d.y = d.depth * 200 - 50
      $.extend(d,
        rightPoint : () -> d.y + d.rightOffset(),
        rightOffset: () -> d3.select("#task-" + d.taskId).select('text.label').node().getComputedTextLength() + 17
      )
  
    # Update the nodes…
    node = vis.selectAll("g.node").data(nodes, (d) ->
      d.id or d.id = ++maxi
    )
    
    # Enter any new nodes at the parent's previous position.
    nodeEnter = node.enter()
      .append("svg:g")
      .attr("class", "node")
      .style("visibility", (d) -> "hidden" if d.type == "project")
      .attr("id", (d) -> "task-" + d.taskId)
      .attr("transform", (d) ->
          if source.y0 == source.y
            y = source.rightPoint()
          else
            y = source.y0
          "translate(" + y + "," + source.x0 + ")"
        )
      .on("click", (d) ->
        toggle d
        update d
      ).on("mouseover", (d) ->
        d3.select(this).select(".add")
          .style("visibility", "visible")
      )
      .on("mouseout", (d) ->
        d3.select(this).select(".add")
          .style("visibility", "hidden")
      )

    nodeEnter
      .append("svg:circle")
      .attr("r", 1e-6)
      .style("fill", (d) ->
        if d._children then d.color else "#fff"
      )
      .style("stroke", (d) -> d.color)

    nodeEnter
      .append("svg:text")
      .attr("class", "label")
      .attr("x", 10)
      .attr("dy", ".35em")
      .attr("text-anchor", "start")
      .text( (d) -> d.name )
      .style("fill-opacity", 1)

    g = nodeEnter.append("g").attr("class", "add")
      .style("visibility", "hidden")
      .attr("transform", (d) ->
          "translate(" + d.rightOffset() + ",0)"
      )

    g.append("svg:circle")
      .attr("r", 4.5)
      .style("stroke", (d) -> d.color)

    g.append("svg:text")
      .text("+")
      .attr("text-anchor", "middle")
      .attr("x", 0.2)
      .attr("y", 4.5*0.85)

    g.on("click", (d) ->
      newNode( d, { name: "Click", color: d.color, taskId: maxi } )
    )

    # Transition nodes to their new position.
    nodeUpdate = node
      .transition()
      .duration(duration).attr("transform", (d) ->
        "translate(" + d.y + "," + d.x + ")"
      )

    nodeUpdate
      .select("circle")
      .attr("r", 4.5)
      .style("fill", (d) ->
        if d._children then d.color else "#fff"
      )
  
    nodeUpdate
      .select("text")
      .style("fill-opacity", 1)
    
    # Transition exiting nodes to the parent's new position.
    nodeExit = node.exit()
      .transition()
      .duration(duration)
      .attr("transform", (d) ->
        "translate(" + source.rightPoint() + "," + source.x + ")"
      )
      .remove()

    nodeExit.select("circle").attr "r", 1e-6
    nodeExit.select("text").style "fill-opacity", 1e-6
    
    # Update the links…
    link = vis.selectAll("path.link").data(tree.links(nodes), (d) ->
      d.target.id
    )
    
    # Enter any new links at the parent's previous position.
    link.enter()
      .insert("svg:path", "g")
      .attr("class", "link")
      .style("stroke", (d) -> d.target.color)
      .style("visibility", (d) -> "hidden" if d.source.type == "project")
      .attr("d", (d) ->
        o =
          x: source.x0
          y: source.rightPoint()

        diagonal
          source: o
          target: o
    ).transition().duration(duration).attr "d", newDiag
    
    # Transition links to their new position.
    link.transition().duration(duration).attr "d", newDiag
    
    # Transition exiting nodes to the parent's new position.
    link.exit().transition().duration(duration).attr("d", (d) ->
      o =
        x: source.x
        y: source.rightPoint()
  
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


  root = undefined

  tree = d3.layout.tree().size([h, w])

  diagonal = d3.svg.diagonal().projection((d) ->
    [d.y, d.x]
  )

  newDiag = (d) ->
    # Final link
    diagonal {
      source: {
        x: d.source.x,
        y: d.source.rightPoint()
      }
      target: d.target
    }

  newNode = (parent, node) ->
    node.id = ++maxi
    if parent.children?
      parent.children.push node
    else
      parent.children = [ node ]
    update parent
    toggle parent

  rescaleGraph = ->
    vis.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")

    #let's rescale/reposition rectangle that using for dragging
    scale = 1 / d3.event.scale;
    vis.selectAll('rect')
      .attr("transform", "translate(" + [-1 * (scale * d3.event.translate[0]), -1 * (scale * d3.event.translate[1])] + ")" + " scale(" + scale + ")");

  if $('.project-graph').size() > 0
    outer = d3.select('.project-graph')
      .append("svg:svg")
      .attr("width", w)
      .attr("height", h)
      .attr("pointer-events", "all")
      .call(
        d3.behavior.zoom()
        .scaleExtent([0.7, 2])
        .on("zoom", rescaleGraph)
      ).on("dblclick.zoom", null)

    vis = outer.append("svg:g")
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

  socket = new WebSocket "ws://#{window.location.host + $('.project-graph').data('ws-path')}"

  socket.onmessage = (event) ->
    if event.data.length
      task = JSON.parse(event.data)
      newNode(d3.select('#task-' + task.parent).datum(), task)
)
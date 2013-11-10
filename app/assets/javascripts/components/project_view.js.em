class Minp.ProjectViewComponent extends Ember.Component
  classNames: ['project-graph']
  attributeBindings: ['width', 'height']
  width: ~> $(window).width()
  height: ~> $(window).height() - 110
  root: undefined
  tree: undefined
  vis: undefined

  didInsertElement: ->
    t = this

    this.tree = d3.layout.tree().size([this.height, this.width])

    outer = d3.select(this.$()[0])
      .append("svg:svg")
      .attr("width", this.width)
      .attr("height", this.height)
      .attr("pointer-events", "all")
      .call(
        d3.behavior.zoom()
        .scaleExtent([0.7, 2])
        .on("zoom", ->
          t.vis.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")

          #let's rescale/reposition rectangle that using for dragging
          scale = 1 / d3.event.scale;
          t.vis.selectAll('rect')
            .attr("transform", "translate(" + [-1 * (scale * d3.event.translate[0]), -1 * (scale * d3.event.translate[1])] + ")" + " scale(" + scale + ")")
        )
      ).on("dblclick.zoom", null)

    this.vis = outer.append("svg:g")
      .append('svg:g')
    this.update(true)

  # From http://mbostock.github.io/d3/talk/20111018/tree.html
  +observer d3data
  update: (initial = false) ->
    t = this

    console.log t.d3data
    t.root = t.d3data
    source = t.root
    t.root.x0 = t.height / 2
    t.root.y0 = 0

    duration = (if d3.event and d3.event.altKey then 5000 else 500)
    duration = 0 if initial == true

    # Compute the new tree layout.
    nodes = this.tree.nodes(this.root).reverse()

    # Normalize for fixed-depth.
    nodes.forEach (d) ->
      d.y = d.depth * 200 - 50
      d.rightPoint = -> d.y + d.rightOffset()
      d.rightOffset = ->
        return 0 if d.type == "project"
        d3.select("#task-" + d.id).select('text.task-label').node().getComputedTextLength() + 17

    # Update the nodes…
    node = this.vis.selectAll("g.node")
      .data(nodes.filter((d) -> d.type == "task"), (d) ->
        "task-" + d.id
      )
  
    # Enter any new nodes at the parent's previous position.
    nodeEnter = node.enter()
      .append("svg:g")
      .attr("class", "node")
      .attr("id", (d) -> "task-" + d.id)
      .attr("transform", (d) ->
          if source.y0 == source.y
            y = source.rightPoint()
          else
            y = source.y0
          "translate(" + y + "," + source.x0 + ")"
      ).on("mouseover", (d) ->
        # Only display the add button if the node is not collapsed
        unless d._children?
          d3.select(this).select(".add")
            .style("visibility", "visible")
      ).on("mouseout", (d) ->
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
      .on("click", (d) ->
        t.toggle d
        t.update d
      )

    nodeEnter
      .append("svg:g")
      .attr("class", "text-container")
      .append("svg:text")
      .attr("class", "task-label")
      .attr("x", 10)
      .attr("dy", ".35em")
      .attr("text-anchor", "start")
      .text( (d) -> d.name )
      .style("fill-opacity", 1)
      .on("dblclick", (d) ->
        tRect = this.getBBox()

        text = d3.select(this)
        text.style("display", "none")
        container = d3.select(this.parentNode).insert("foreignObject")
          .attr("width", tRect.width*2)
          .attr("height", tRect.height*2)
          .attr("x", tRect.x)
          .attr("y", tRect.y)

        container
          .append("xhtml:input")
          .attr("type", "text")
          .attr("value", this.textContent)
          .on("blur", (d) ->
            #text.text(this.value)
            text.style("display", "block")
            console.log('task name change')
            container.remove()
          )
          .node().focus()
      )

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
      task = {
        parent_id: d.id,
        name: "Click to edit",
      }

      console.log('new task')
    )

    # Transition nodes to their new position.
    nodeUpdate = node
      .transition()
      .duration(duration).attr("transform", (d) ->
        "translate(" + d.y + "," + d.x + ")"
      )

    node
      .select('.task-label')
      .text(
        (d) -> d.name
      )

    node
      .select("circle")
      .attr("r", 4.5)
      .style("fill", (d) ->
        if d._children then d.color else "#fff"
      )
  
    node
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
    links = this.tree.links(nodes).filter (d) -> d.source.type == "task"

    link = this.vis.selectAll("path.link").data(links, (d) ->
      d.target.id
    )

    # Enter any new links at the parent's previous position.
    link.enter()
      .insert("svg:path", "g")
      .attr("class", "link")
      .style("stroke", (d) -> d.target.color)
      .attr("d", (d) ->
        o =
          x: source*.x0
          y: source.rightPoint()

        d3.svg.diagonal().projection((d) -> [d.y, d.x])
          source: o
          target: o
      )
      .transition().duration(duration).attr("d", this.newDiag)

    # Transition links to their new position.
    link.transition().duration(duration).attr "d", this.newDiag

    # Transition exiting nodes to the parent's new position.
    link.exit().transition().duration(duration).attr("d", (d) ->
      o =
        x: source.x
        y: source.rightPoint()

      d3.svg.diagonal().projection((d) -> [d.y, d.x])
        source: o
        target: o

    ).remove()

    # Stash the old positions for transition.
    nodes.forEach (d) ->
      d.x0 = d.x
      d.y0 = d.y

  # Toggle children.
  toggle: (d) ->
    if d.children
      d._children = d.children
      d.children = null
    else
      d.children = d._children
      d._children = null

  diagonal: -> d3.svg.diagonal().projection((d) -> [d.y, d.x])

  newDiag: (d) ->
    # Final link
    d3.svg.diagonal().projection((d) -> [d.y, d.x]) {
      source: {
        x: d.source.x,
        y: d.source.rightPoint()
      }
      target: d.target
    }

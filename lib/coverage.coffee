fs = require 'fs'
path = require 'path'

CoveragePanelView = require './coverage-panel-view'
CoverageStatusView = require './coverage-status-view'

module.exports =
  coveragePanelView: null
  coverageStatusView: null

  activate: (state) ->
    @coveragePanelView = new CoveragePanelView

    atom.packages.once "activated", =>
      if atom.workspaceView.statusBar
        @coverageStatusView = new CoverageStatusView(@coveragePanelView)
        atom.workspaceView.statusBar.appendLeft @coverageStatusView

    atom.workspaceView.command "coverage:toggle", => @coveragePanelView.toggle()
    atom.workspaceView.command "coverage:refresh", => @update()

    @update()

  update: ->
    coverageFile = path.resolve(atom.project.path, "coverage/coverage.json") if atom.project.path

    if coverageFile && fs.existsSync(coverageFile)
      fs.readFile coverageFile, "utf8", ((error, data) ->
        return if error

        data = JSON.parse(data)

        @updateView data.metrics, data.files
        @updateStatusBar data.metrics
      ).bind(this)
    else
      console.info "TODO: Coverage file not found"

  updateView: (project, files) ->
    @coveragePanelView.update project, files

  updateStatusBar: (project) ->
    @coverageStatusView?.update Number(project.covered_percent.toFixed(2))

  deactivate: ->
    @coveragePanelView?.destroy()
    @coverageStatusView?.destroy()

    @coveragePanelView = null
    @coverageStatusView = null

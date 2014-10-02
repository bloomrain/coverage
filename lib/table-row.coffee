fs = require 'fs-plus'
path = require 'path'

class TableRow extends HTMLElement
  initialize: (file) ->
    filePath = atom.project.relativize(file.filename)
    fileName = path.basename(file.filename)

    columns = []

    # title column
    colTitle = @createColumn()
    colTitleIcon = document.createElement("span")
    colTitleIcon.classList.add("icon", "icon-file-text")
    colTitleIcon.dataset.name = fileName
    colTitleIcon.textContent = filePath
    colTitleIcon.addEventListener "click", @openFile.bind(this, filePath)
    colTitle.appendChild(colTitleIcon)
    columns.push colTitle

    # progress column
    colProgress = @createColumn()
    progressBar = document.createElement("progress")
    progressBar.max = 100
    progressBar.value = file.covered_percent
    progressBar.classList.add @coverageColor(file.covered_percent)
    colProgress.appendChild(progressBar)
    columns.push colProgress

    # percentage column
    columns.push @createColumn("#{Number(file.covered_percent.toFixed(2))}%")

    # lines column
    columns.push @createColumn("#{file.covered_lines} / #{file.lines_of_code}")

    # strengh column
    columns.push @createColumn(Number(file.covered_strength.toFixed(2)))

    @appendChild(column) for column in columns

  createColumn: (content = null) ->
    col = document.createElement("td")
    col.innerHTML = content
    return col

  coverageColor: (coverage) ->
    switch
      when coverage >= 90 then "green"
      when coverage >= 80 then "orange"
      else "red"

  openFile: (filePath) ->
    atom.workspaceView.open(filePath, true) if fs.existsSync atom.project.resolve(filePath)

module.exports = document.registerElement('coverage-table-row', prototype: TableRow.prototype, extends: 'tr')

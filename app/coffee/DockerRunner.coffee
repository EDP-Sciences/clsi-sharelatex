spawn = require("child_process").spawn
logger = require "logger-sharelatex"
Settings = require "settings-sharelatex"


module.exports = DockerRunner =
  _docker: Settings.clsi?.docker?.binary or 'docker'
  _baseCommand: ['run', '--rm=true', '-t', '-v', '$COMPILE_DIR:/source', '--name=texlive-$PROJECT_ID']

  run: (project_id, command, directory, timeout, callback = (error) ->) ->
    logger.log project_id: project_id, command: command, directory: directory, "running docker command"

    docker_cmd = (arg.replace('$COMPILE_DIR', directory).replace('$PROJECT_ID', project_id) \
      for arg in DockerRunner._baseCommand)
    if command[0] != "latexmk"
      docker_cmd.push "--entrypoint=#{command[0]}"
    docker_cmd.push Settings.clsi?.docker?.image or "texlive"
    docker_cmd = docker_cmd.concat (arg.replace('$COMPILE_DIR', '/source') for arg in command.slice(1))

    proc = spawn DockerRunner._docker, docker_cmd, stdio: "inherit", cwd: directory
    timer = setTimeout () ->
      # Too late, don't call the callback when the process exits
      _callback = callback
      callback = ->
      logger.warn "timeout achieved, stopping docker instance"
      proc = spawn DockerRunner._docker, ['stop', "texlive-#{project_id}"]
      proc.on "close", ->
        _callback timedout: true
    , timeout
    proc.on "close", () ->
      clearTimeout timer
      callback()

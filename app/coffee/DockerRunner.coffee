spawn = require("child_process").spawn
exec  = require("child_process").exec
logger = require "logger-sharelatex"
Settings = require "settings-sharelatex"


module.exports = DockerRunner =
  _docker: 'docker'
  _baseCommand: ['run', '--rm=true', '-t', '-v', '$COMPILE_DIR:/source', '--name=texlive-$PROJECT_ID']

  run: (project_id, command, directory, timeout, callback = (error) ->) ->
    logger.log project_id: project_id, command: command, directory: directory, "running docker command"

    if command[0] != 'latexmk'
      throw 'Invalid command'

    docker_cmd = (arg.replace('$COMPILE_DIR', directory).replace('$PROJECT_ID', project_id) \
      for arg in DockerRunner._baseCommand)
    docker_cmd.push Settings.clsi?.docker?.image or "texlive"
    docker_cmd = docker_cmd.concat (arg.replace('$COMPILE_DIR', '/source') for arg in command.slice(1))

    proc = spawn DockerRunner._docker, docker_cmd, stdio: "inherit", cwd: directory
    timer = setTimeout timeout, () ->
      logger.warn "timeout achieved, stopping docker instance"
      exec 'docker', ['stop', "texlive-#{project_id}"]
      callback {timedout: true}
    proc.on "close", () ->
      clearTimeout timer
      callback()

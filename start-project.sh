#!/bin/bash

usage()
{
  echo "Usage: $0 [-h|?] [-p <project_name>]"
  exit 2
}

set_variable()
{
  local varname=$1
  shift
  if [ -z "${!varname}" ]; then
    eval "$varname=\"$@\""
  else
    echo "Error: $varname already set"
    usage
  fi
}

#########################
# Main Script starts here

unset project_name

base_folder="$HOME/Documents/personal/projects"
code_dir="app"

while getopts 'p:?h' c
do
  case $c in
    p) set_variable project_name $OPTARG;;
    h|?) usage ;;
  esac
done

[ -z "$project_name" ] && usage

if [ -n $project_name ]; then
  # Create directory structure
  fullpath="${base_folder}/${project_name}"
  mkdir -p ${fullpath}/${code_dir}
  # Create the folder structure
  mkdir -p ${fullpath}/${code_dir}/{templates,static}
  # Enter the directory
  cd $fullpath
  # Start it as git repo
  git init
  # Create base README.md
  echo -ne "# ${project_name}\n\n${project_name} created on $(date +%F)" > README.md
  # Create a base python script called app.py with hello world
  cat >${code_dir}/app.py<<EOF
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
  return "Hello World!"

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=9000, debug=True)
EOF
  # Create base requirements.txt file
  echo "flask" > ${code_dir}/requirements.txt
  # Create base Dockerfile
  cat >${code_dir}/Dockerfile<<EOF
FROM python:3.7-alpine
WORKDIR /app
COPY requirements.txt /app
RUN pip3 install -r requirements.txt
COPY . /app
ENTRYPOINT ["python3"]
CMD ["app.py"]
EOF
  # Create base docker-compose.yaml
  cat >docker-compose.yaml<<EOF
version: "3.7"
services:
  web:
    build: ${code_dir}
    ports:
      - 80:9000
    volumes:
      - ./${code_dir}:/app
EOF
fi
echo "Project ${project_name} created"
cat >${code_dir}/created.json<<EOF
{
    "project_name": "${project_name}",
    "directory": "${code_dir}"
    "created": "$(date)"
    "git-repo": "github.com/new"
}
EOF
cat ${code_dir}/created.json




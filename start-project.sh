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

base_folder="/mnt/storage/study/projects"
code_dir="app"

while getopts 'p:?h' c
do
  case $c in
    p) set_variable project_name $OPTARG;;
    h|?) usage ;;
  esac
done

[ -z "$project_name" ] && usage

# Base code for flask

# Create a base python script called app.py with hello world
app_code=$(cat <<-EOF
from flask import Flask, render_template, url_for
app = Flask(__name__)

posts = [
        {
            'author': 'Rafael de Paiva',
            'title': 'Blog Post 1',
            'content': 'First post content',
            'date_posted': 'April 1, 2020'
        },
        {
            'author': 'Tayse Sabrina',
            'title': 'Blog Post 2',
            'content': 'Second post content',
            'date_posted': 'October 2, 2020'
        }
]

@app.route('/')
@app.route('/home')
def home():
  return render_template('home.html', posts=posts, title="${project_name}")

@app.route('/about')
def about():
    return render_template('about.html', title="About")

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=9000, debug=True)
EOF
)
template_layout=$(cat <<-EOF
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/css/bootstrap.min.css" integrity="sha384-TX8t27EcRE3e/ihU7zmQxVncDAy5uIKz4rEkgIXeMed4M0jlfIDPvg6uqKI2xXr2" crossorigin="anonymous">
    <link rel="stylesheet" type="text/css" href="{{ url_for('static', filename='main.css') }}">

    {% if title %}
        <title>${project_name} - {{ title }}</title>
    {% else %}
        <title>${project_name}</title>
    {% endif %}
  </head>
  <body>
      <header class="site-header">
        <nav class="navbar navbar-expand-md navbar-dark bg-steel fixed-top">
          <div class="container">
            <a class="navbar-brand mr-4" href="/">${project_name}</a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarToggle" aria-controls="navbarToggle" aria-expanded="false" aria-label="Toggle navigation">
              <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarToggle">
              <div class="navbar-nav mr-auto">
                <a class="nav-item nav-link" href="{{ url_for('home') }}">Home</a>
                <a class="nav-item nav-link" href="{{ url_for('about') }}">About</a>
              </div>
              <!-- Navbar Right Side -->
              <div class="navbar-nav">
                <a class="nav-item nav-link" href="/login">Login</a>
                <a class="nav-item nav-link" href="/register">Register</a>
              </div>
            </div>
          </div>
        </nav>
      </header>
      <div class="container">
        {% block content %}{% endblock %}
      </div>

    <!-- Optional JavaScript; choose one of the two! -->

    <!-- Option 1: jQuery and Bootstrap Bundle (includes Popper) -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ho+j7jyWK8fNQe+A12Hb8AhRq26LrZ/JpcUGGOn+Y7RsweNrtN/tE3MoK7ZeZDyx" crossorigin="anonymous"></script>

    <!-- Option 2: jQuery, Popper.js, and Bootstrap JS
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js" integrity="sha384-9/reFTGAW83EW2RDu2S0VKaIzap3H66lZH81PoYlFhbGU+6BZp6G7niu735Sk7lN" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.min.js" integrity="sha384-w1Q4orYjBQndcko6MimVbzY0tgp4pWB4lZ7lr30WKz0vr/aWKhXdBNmNb5D92v7s" crossorigin="anonymous"></script>
    -->
  </body>
</html>
EOF
)

template_home=$(cat <<-EOF
{% extends "layout.html" %}
{% block content %}
    {% for post in posts %}
        <article class="media content-section">
          <div class="media-body">
            <div class="article-metadata">
              <a class="mr-2" href="#">{{ post.author }}</a>
              <small class="text-muted">{{ post.date_posted }}</small>
            </div>
            <h2><a class="article-title" href="#">{{ post.title }}</a></h2>
            <p class="article-content">{{ post.content }}</p>
          </div>
        </article>
    {% endfor %}
{% endblock content %}
EOF
)

template_about=$(cat <<-EOF
{% extends "layout.html" %}
{% block content %}
    <h1>About Page</h1>
{% endblock content %}
EOF
)
static_main=$(cat <<-EOF
body {
  background: #fafafa;
  color: #333333;
  margin-top: 5rem;
}

h1, h2, h3, h4, h5, h6 {
  color: #444444;
}

.bg-steel {
  background-color: #5f788a;
}

.site-header .navbar-nav .nav-link {
  color: #cbd5db;
}

.site-header .navbar-nav .nav-link:hover {
  color: #ffffff;
}

.site-header .navbar-nav .nav-link.active {
  font-weight: 500;
}

.content-section {
  background: #ffffff;
  padding: 10px 20px;
  border: 1px solid #dddddd;
  border-radius: 3px;
  margin-bottom: 20px;
}

.article-title {
  color: #444444;
}

a.article-title:hover {
  color: #428bca;
  text-decoration: none;
}

.article-content {
  white-space: pre-line;
}

.article-img {
  height: 65px;
  width: 65px;
  margin-right: 16px;
}

.article-metadata {
  padding-bottom: 1px;
  margin-bottom: 4px;
  border-bottom: 1px solid #e3e3e3
}

.article-metadata a:hover {
  color: #333;
  text-decoration: none;
}

.article-svg {
  width: 25px;
  height: 25px;
  vertical-align: middle;
}

.account-img {
  height: 125px;
  width: 125px;
  margin-right: 20px;
  margin-bottom: 16px;
}

.account-heading {
  font-size: 2.5rem;
}
EOF
)

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
  # Create base requirements.txt file
  echo "flask" > ${code_dir}/requirements.txt
  # Adding base code
  echo "${app_code}" > ${code_dir}/app.py
  echo "${template_layout}" > ${code_dir}/templates/layout.html
  echo "${template_home}" > ${code_dir}/templates/home.html
  echo "${template_about}" > ${code_dir}/templates/about.html
  echo "${static_main}" > ${code_dir}/static/main.css
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
    "directory": "${code_dir}",
    "created": "$(date)",
    "git-repo": "github.com/new"
}
EOF
cat ${code_dir}/created.json




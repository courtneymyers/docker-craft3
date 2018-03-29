# Dockerized LAMP stack for local Craft 3 development

## Setup

1. Build the Craft 3 image locally from the Dockerfile:    
`docker build -t craft:3 .`    
Optionally pull the MariaDB image from Docker Hub as well (not required, as it’ll get pulled in step 3, if you don't already have it locally):    
`docker pull mariadb:10.3`)

2. Set environment variables for the database, and Craft in the following files:    
  - `env/.craft.env`    
  - `env/.mysql.env`    

  **NOTE:** `CRAFT_PASSWORD` must be at least 6 digits long.

3. Start the Craft 3 and MariaDB containers in detached mode:    
`docker run --name craft-db --env-file ./env/.mysql.env -d mariadb:10.3`    
`docker run --name craft-cms --env-file ./env/.craft.env --link craft-db:db -p 8000:80 -d craft:3`

4. Access the app in a web browser at `http://localhost:8000/admin`

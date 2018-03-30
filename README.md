# Dockerized LAMP stack for local Craft 3 development

## Setup

1. Build the Craft 3 image locally from the Dockerfile:    
`docker build -t craft:3 .`    
Optionally pull the MariaDB image from Docker Hub as well (not required, as it’ll get pulled in step 3, if you don't already have it locally):    
`docker pull mariadb:10.3`)

2. Set environment variables for the database, and Craft in the following files:    
  - `env/.craft.env` (`CRAFT_PASSWORD` must be at least 6 digits long)    
  - `env/.mysql.env`    

3. Run setup script:    
`sh setup.sh`

4. When done with local development, stop each container individually:    
`docker container stop craft-db`
`docker container stop craft-cms`

And to resume a later point:
`docker container start craft-db`
`docker container start craft-cms`

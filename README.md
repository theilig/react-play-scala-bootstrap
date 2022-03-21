# Mostly functional bootstrap for using React with Scala Play Framework backend.

This is mostly for personal use, as I find myself cloning whatever my last project was and then
pulling out project specific stuff and cauterizing the wounds.  I've considered creating a mini-package
for some of this code, but for now it's a good starting point.

Use at your own risk, I'm happy to take any PRs for fixing bugs or upgrades that make sense.

## What this provides
React frontend, scala play backend. Authentication with JWT tokens stored in browser.
(no passwords, user needs to confirm via e-mail whenever token expires or using new browser)
Simple database schema with evolution is included, but needs to be wired to an actual database.
SSL setup using certs from letsencrypt.org, email is sent using Sendgrid, database interactions are done with Slick.

Currently, the security around tokens is only so-so, I'm storing the email confirmation tokens unencrypted in the 
database which is admittedly not very secure. It wouldn't be hard to add some salt and pepper and encrypt those before storing.

## Current versions of everything
* Play framework 2.8.13
* Slick 5.0.0
* App built with create-react-app...
* React 17.0.2
* react-router 6.2.2
* react-script 5.0.0

## Usage
If you want to use this:
1. Clone the repo and copy the files to a new repo
2. Do a grep -ri for 'rpsbs', and replace it everywhere with something appropriate to your app.
3. Do the same for full expansions (i.e. search for React and replace React Play Scala Bootstrap instances)

## Configuration
* Add any necessary allowed hosts to application.conf
* Set the appropriate JWT issuer in app/services/Jwt.scala
* Set the from address in app/services/Mailer.scala
* Fix the <your server> link in app/services/Mailer.scala
* If desired, alter how long the JWT token is valid in application.conf
* Replace images (favicon.ico, logo*.svg, logo*.png)
* Change names of app in public/manifest.json
* In services/nginx.conf insert your server name (i.e. coolthing.example.com). Might be done automatically with letsencrypt's nginx setup

Other settings that need to be provided via environment variables
* SENDGRID_API_KEY - self-explanatory
* TOKEN_SECRET - secret for encoding JWT tokens
* APPLICATION_SECRET - Play built in secret for generating sessions, not sure how much it's used in this current app
* DATABASE_URL - jdbc URL for where to connect to the database (i.e. jdbc:mysql://some.database-location.org/rpsbs)
* DATABASE_USER - username to use to connect to database
* DATABASE_SECRET - password to use to connect to database

## Deployment
Right now I use Google Container Registry to host containers and run my apps in GCP. There are some simple scripts
that make this a auto-manual deployment.  In theory, I could wire up kube, but haven't taken that on yet.

services/compose/build.sh and update_version.p are simple scripts that do the following
1. Bump the version
2. Build new docker images for the app and nginx
3. Tag the images with the new version, and push them to GCR.

To use these you will need to specify your own GCR location in build.sh, and update the regex in update_version.pl
with the name of your application.

There is also a docker-compose.yml which can be updated with the current version and run on your server. 

As things are currently written, copying the new docker-compose.yml and running docker compose server-side has
to be done manually.

Docker compose expects an env file to exist on the server with the various configuration secrets, which is obviously not
bulletproof security either.

## Dependencies
npm
sbt
build.sh uses perl to bump the version

### Update the UI
React moves quickly, so I don't know how easy it will be for me to keep this updated with the latest and greatest,
if you want to re-build the UI from scratch:
1. In your repo remove the ui directory
2. from your top level repo directory run npx create-react-app ui
3. change name in ui/public/index.html
4. update ui/manifest.json
5. in ui directory npm install 
    * ncp rimraf -D
    * axios
    * react-router-dom
    * styled-components
6. in ui/package.json change build stage to call ./frontend-build

### Dealing with Slick
Most people either love it or hate it, I'm in between, but it gets the job done for me. Bootstrapping slick can be a
bit tricky, I usually run the app the first time and run the 1.sql evolution.  Then I run a separate app which calls
slick.codegen.SourceCodeGenerator to generate new code bindings, and dump those back into app.models.schema.

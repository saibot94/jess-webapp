# Jess Web Application

This app uses the Jess rule engine to create automatic recommendations for users, based on what they already bought.

There are 2 main Jess files in the `src/main/webapp` folder:

* app.clp - contains all the business logic rules and the definition of the different product / recommendation templates
* facts.clp - use this file to load additional facts in your application.

## Running the app

The app uses Gradle as a package manager and build engine. First, you need to setup the jess library, as it's an external JAR.

Installation steps:

1. In the `libs` folder, add the `jess.jar` file from `./deps/Jess71p2/lib/` (once extracted).
2. Run `./gradlew build`
3. Run `./gradlew appRun` to run it locally in an in-process Gretty servlet container.

In order to package everything and deploy it as a WAR to tomcat, for example, run:

```
./gradlew war
```

Then, take the file from `build/libs/jess-webapp.war` and put it in your webapp folder for the servlet engine.

## Development

In order to change implementation details from the web application, everything can be found under `src/main/webapp` for the jsp and clp files.

I strongly suggest using IntelliJ for developing the code in this project. The `idea` plugin is already provided by gradle. To setup your local development files, run:

```
./gradlew idea
```

## Disclaimer

This hasn't been tested on Windows, please let me know if there's any issue with it.

## License

 MIT
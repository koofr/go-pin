# go-pin
[![Build Status](https://travis-ci.org/koofr/go-pin.svg?branch=master)](https://travis-ci.org/koofr/go-pin)

`go-pin` is a tool for pinning dependencies to specific versions. It is tailored to work with Go language but can be used for other purposes.

When fetching dependencies with `go get` you are unable to specify exact version, you will just end up with the default. Main idea of this tool is to create a file which will specify exact version for each dependency and then commit that file to your project. This allows repeatable builds since you can now reset dependencies to specific versions.

## Workflow
`go-pin` works in the directory specified by the `$GOPATH` environment variable as used by Go. It finds all versioned subdirectoried and pins their versions.

### Regular build
If this is the first build or you got an error about missing dependencies then reset dependencies to frozen versions

    cat versions | go-pin reset

This assumes you have version information stored in file `versions`, you can use whatever you like.

### Maintenance
You will occasionally want to upgrade your dependencies. This is a two part process: update and freeze. 

You may use `update` command or perform updates manually if you wish to use specific branch or tag or if you only wish to do a partial update or just run `go get`.

    go-pin update

After ensuring your application works fine with updated dependencies you can now freeze them. 

    go-pin freeze > versions

This assumes you want to store version information in file `versions`, you can use whatever you like. Freeze will store repository type, exact revision and target directory.

### Automation 
If you are using some kind of build system like Make you can simplify your process by requiring reset before every build. This way if somebody else updates dependencies, everything will automatically update on your machine. This is especially nice if you run builds on a build server.

## Supported VCS

Currently supporting same VCS as `go import`: git, mercurial, bazaar and subversion.

## Get it
See the [releases tab on Github](https://github.com/koofr/go-pin/releases).
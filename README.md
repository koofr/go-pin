# go-pin

`go-pin` is a tool for pinning dependencies to specific versions. It is tailored to work with Go language but can be used for other purposes.

When fetching dependencies with `go get` you are unable to specify exact version, you will just end up with the default. Main idea of this tool is to create a file which will specify exact version for each dependency and then commit that file to your project. This allows repeatable builds since you can now reset dependencies to specific versions.

## Workflow

### Regular build
If this is the first build or you got an error about missing dependencies then fetch them.

    go get # or whatever you use

Then reset dependencies to frozen versions

    cat versions | go-pin reset

This assumes you have version information stored in file `versions`, you can use whatever you like.

### Maintenance
You will occasionally want to upgrade your dependencies. This is a two part process: update and freeze. 

You may use `update` command or perform updates manually if you wish to use specific branch or tag or if you only wish to do a partial update.

    go-pin update

After ensuring your application works fine with updated dependencies you can now freeze them.

    go-pin freeze > versions

This assumes you want to store version information in file `versions`, you can use whatever you like. Freeze will store repository type, exact revision and target directory.

**NOTE** `go-pin` works in current subtree. It will also try to update and freeze you application's `.git.` dir if run at project run. Usually you will want to run this in some other directory e.g. `.../src`.

## Supported VCS

Currently supporting same VCS as `go import`: git, mercurial, bazaar and subversion.


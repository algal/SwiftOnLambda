# Swift On Lambda

## What's here

This repo contains an example of two things: using Swift to define an Amazon Lambda function, and in particular using it to define an Amazon Lambda function which implements a simple "Hello world" Alexa Custom Skill. 

Amazon Lambda only officially supports NodeJS, Java, and Python but it also supports including arbitrary Linux executables. So the trick to using Swift on Lambda is just to compile your Swift function to a Linux executable and then build a Lambda function which runs a shim in a supported language that transparently wraps that executable. (There's actually a mature version of this for the Go language, the [Sparta](http://gosparta.io) project.) To do all this, this repo uses docker to help with building the Linux executable and grabbing needed libraries, and it uses terraform to help with deploying to Lambda.

Right now, by default, the repo will deploy a simple Lambda function that just performs an echo command, returning as output whatever was the input. If you want to define your own Lambda function, have a look at `main.swift` and just change the argument from `echo` to a function of your choice.

This repo also contains code to define a simple "Hello from Swift" Alexa Custom Skill. (Why use Lambda for this? Because although you can host an Alexa Custom Skill on an ordinary web server, the HTTPS authentication requirements are quite messy, and you get those for free with Lambda.) If you want to experiment with this, then go to `main.swift` and use  `greetResponse` instead of `echo`. You will also need to manually configure the skill's intent schema and sample utterances on the Alexa developer website, since Amazon does not provide an API for automated deployment yet. You can find a sample intent schema and sample utterances in the `Resources/` directory.

The best place to look for a clear explanation of developing for Alexa, by the way, is the Big Nerd Ranch videos and sample code that Amazon commissioned.

## How to build, provision, and run a Lambda function

Prerequisites:

- if you want, update `main.swift` so it calls your own function which takes a (JSON) `String` to a (JSON) `String`. (By default, it will just echo.)

- install docker and start the docker daemon. 

  This is used to compile for Linux and grab Linux libraries

- install terraform

  This is used to drive AWS.

- install AWS credentials in ~/.aws/credentials or in environmental variables, for terraform to use

- modify `terraform.tfvars` so that `s3_bucket` is a unique name you own, such as "com.yourdomainnamehere.swiftlambda"

- build with `make build`

- provision with `make provision`

### Provisioning

Swift Lambda uses terraform to provision your lambda function. You can install terrafrom either using brew or get the official package from here: [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html).

The terraform plan configures the following:

- the Lambda function itself (a set of configurations on AWS)

- an S3 bucket, holding the deployment package defining the lambda function's contents (this is just a zip file)

- an IAM role, defining permissions which your Lamba function has while executing

- an API gateway configuration, so AWS presents an HTTPS interface to the function, in case you want that (tho it is not needed for Alexa)

The  `/terraform/terraform.tf` contains the default configuerations such as the lambda function name and the S3 bucket name.

To provision your lambda, ensure you have your AWS credentials either in the ~/.aws/credentials file or you have the environment variables set.

Run:
```
make provision
```

#### what this Makefile does

An Amazon Lambda function is defined by AWS configuration and by a _deployment package_. The Makefile builds that package.

The package must use one of the supported languages, Java, NodeJS, or Python. We use JS and that JS file is contained in `shim/`.

A package may also contain a native binary executable, and this is where we drop in our compiled Swift code.

One catch is that the binary must be compiled on an appropriate Linux distribution. The Makefile's `build_swift` target uses docker to do this. In case you are new to the exciting world of docker, here's a breakdown of key points in part of the build process:

The first command is roughly like this:

```sh
$ docker run                               # create a container and run it
         --rm                              # rm the container when it exits
         --volume "$(shell pwd)/src:/src"  # bind the local directory src/ to in-the-container  /src 
         --workdir /src                    # set /src as the working directory in the container
         ibmcom/kitura-ubuntu              # use IBM's Kitura docker image to define the container
         swift build -v                    # in the container, run only the command "swift build -v"
```

In other words, this command runs a virtualized ubuntu containing IBM's Swift Kitura web framework, and uses the copy of the swift compiler within that container to compile the Swift package located in the container's /src directory. Because the container's /src is mapped to the host's src/, compiling this package in the container _also places the build outputs in the host's src/ directory_. 

The next docker commands look like this (with command line arguments in short form):

```sh
$ docker run --rm -v "$(shell pwd)/src:/src" -w /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /root/swift-3.0-RELEASE-ubuntu14.04/usr/lib/swift/linux/*.so /src/libs'
$ docker run --rm -v "$(shell pwd)/src:/src" -w /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libicudata.so.52 /src/libs'
$ ...

```

These essentially copy files from inside the IBM Kitura Swift docker container into the container's /src directory, which is bound to the host's file system. In other words, we are essentially just extracting useful Linux static libraries from inside the container.

Finally, the run command is a bit different:

```sh
$ docker run --interactive                 # let allow stdin/out into the container
             --tty                         # "allocate a pseudo-TTY"
             --rm                          # rm the container when it exits
             --volume "$(shell pwd):/src"  # map our src/ to its /src
             --workdir /src                # set its workdir as its /src
             ubuntu                        # build container from the image "ubuntu"
             /bin/bash -c 'LD_LIBRARY_PATH=/src/src/libs /src/src/.build/debug/src' # set env var and run executable src
```

This runs a container based on the plain `ubuntu` image, mapping to the host src/ directory with the extracted static libraries, and then runs a single shell command in the container which sets an environmental variable pointing the linker to those libraries and executes the executable `src`.

It's worth emphasizing that while some of these docker command build a container from the same image, none of these commands operate on the same container, since the container is removed after the command exits. The only reason we are accumulating a directory of the outputs we need is because every container's /src directory is mapped to our host's src/ directory, and that directory's contents persist across the different containers' lifetimes like the host itself.

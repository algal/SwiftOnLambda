## How to build, provision, and run

Prerequisites:

- install docker and start the docker daemon. 

  This is used to compile for Linux and grab Linux libraries)

- install terraform

  This is used to drive AWS.

- install AWS credentials in ~/.aws/credentials or in the environment, for terraform to use

- modify `terraform.tfvars` so that `s3_bucket` is a unique name, such as "com.yourdomainnamehere.swiftlambda"

- build with `make build`

- provision with `make provision`


## Provisioning

Swift Lambda uses terraform to provision your lambda function. You can install terrafrom either using brew or get the official package from here: [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html).

The terraform plan configures the following:

- the Lambda function itself (a set of configurations on AWS)

- an S3 bucket, holding the deployment package defining the lambda function's contents (this is just a zip file)

- an IAM role, defining permissions your Lamba function has while executing

- an API gateway configuration, so AWS presents an HTTPS interface to the function

The  `/terraform/terraform.tf` contains the default configuerations such as the lambda function name and the S3 bucket name.

To provision your lambda, ensure you have your AWS credentials either in the ~/.aws/credentials file or you have the environment variables set.


Run:
```
make provision
```


## FYI, what this Makefile does

An Amazon Lambda function is defined by a _package_. The Makefile builds that package.

A "package" must use one of the supported languages (Java, NodeJS, or Python). Our uses JS, and the JS file is contained in `shim/`.

A package may also contain a native binary executable, and this is where we drop in our compiled Swift code.

The only catch is that the binary must be compiled on an appropriate Linux distribution. The Makefile's `build_swift` target uses docker to do this. In case you are new to the exciting world of docker, here's a breakdown of key points in part of the build process:

First is roughly like this:

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


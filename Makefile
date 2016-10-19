
# this variable must be aligned with lambdazip in terraform.tfvars
BUILDDIR = build

# this variable must be aligned with lambdazip in terraform.tfvars
LAMBDA_DEPLOYMENT_PACKAGE_NAME = lambda_deployment_package.zip

build: build_lambda_package
	echo "Everything built"

clean: clean_lambda_package clean_swift
	echo "Everything cleaned"

build_lambda_package: build_swift
	echo "Assembling the Lambda function deployment package"
	mkdir -p $(BUILDDIR)/native
	cp shim/index.js $(BUILDDIR)/
	cp swiftcommand/.build/release/swiftcommand $(BUILDDIR)/native
	cp -r swiftcommand/LinuxLibraries $(BUILDDIR)/native
	cd $(BUILDDIR) && zip -r $(LAMBDA_DEPLOYMENT_PACKAGE_NAME) * 

clean_lambda_package:
	echo "Cleaning deployment package"
	rm -r $(BUILDDIR) $(LAMBDA_DEPLOYMENT_PACKAGE_NAME) || true

build_swift:
	echo "Building swiftcommand Linux executable"
	docker run \
               --rm \
               --volume "$(shell pwd)/swiftcommand:/src" \
               --workdir /src \
               ibmcom/kitura-ubuntu \
               swift build -c release -v
	echo "Copying executable's Linux dependencies from Kitura-Swift"
	mkdir -p swiftcommand/LinuxLibraries
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /root/swift-3.0-RELEASE-ubuntu14.04/usr/lib/swift/linux/*.so /usr/lib/x86_64-linux-gnu/libicudata.so.52 /usr/lib/x86_64-linux-gnu/libicui18n.so.52 /usr/lib/x86_64-linux-gnu/libicuuc.so.52 /usr/lib/x86_64-linux-gnu/libbsd.so /usr/lib/x86_64-linux-gnu/libxml2.so.2 /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.1 /usr/lib/x86_64-linux-gnu/libcurl.so.4 /usr/lib/x86_64-linux-gnu/libidn.so.11 /usr/lib/x86_64-linux-gnu/librtmp.so.0 /lib/x86_64-linux-gnu/libssl.so.1.0.0 /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 /lib/x86_64-linux-gnu/libbsd.so.0 /usr/lib/x86_64-linux-gnu/libgnutls.so.26 /lib/x86_64-linux-gnu/libgcrypt.so.11 /usr/lib/x86_64-linux-gnu/libkrb5.so.3 /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 /usr/lib/x86_64-linux-gnu/libkrb5support.so.0 /usr/lib/x86_64-linux-gnu/libsasl2.so.2 /usr/lib/x86_64-linux-gnu/libgssapi.so.3 /usr/lib/x86_64-linux-gnu/libtasn1.so.6 /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 /lib/x86_64-linux-gnu/libkeyutils.so.1 /usr/lib/x86_64-linux-gnu/libheimntlm.so.0 /usr/lib/x86_64-linux-gnu/libkrb5.so.26 /src/LinuxLibraries'
        # needed for Swift's stdlib
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /root/swift-3.0-RELEASE-ubuntu14.04/usr/lib/swift/linux/libFoundation.so /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /root/swift-3.0-RELEASE-ubuntu14.04/usr/lib/swift/linux/libdispatch.so /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /root/swift-3.0-RELEASE-ubuntu14.04/usr/lib/swift/linux/libswiftCore.so /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /root/swift-3.0-RELEASE-ubuntu14.04/usr/lib/swift/linux/libswiftGlibc.so /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libicudata.so.52 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libicui18n.so.52 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libicuuc.so.52 /src/LinuxLibraries'
        # needed for Foundation (excluding ones that empirically are not needed and/or cause a seg fault)
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libbsd.so.0 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libc.so.6 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libcom_err.so.2 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libcrypt.so.1 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libdl.so.2 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libgcc_s.so.1 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libgcrypt.so.11 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libgpg-error.so.0 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libkeyutils.so.1 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/liblzma.so.5 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libm.so.6 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libpthread.so.0 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libresolv.so.2 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/librt.so.1 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libssl.so.1.0.0 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libutil.so.1 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /lib/x86_64-linux-gnu/libz.so.1 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libasn1.so.8 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libcurl.so.4 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libffi.so.6 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libgnutls.so.26 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libgssapi.so.3 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libhcrypto.so.4 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libheimbase.so.1 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libheimntlm.so.0 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libhx509.so.5 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libidn.so.11 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libkrb5.so.26 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libkrb5.so.3 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libkrb5support.so.0 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libroken.so.18 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/librtmp.so.0 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libsasl2.so.2 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 /src/LinuxLibraries'
#	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libtasn1.so.6 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libwind.so.0 /src/LinuxLibraries'
	docker run --rm --volume "$(shell pwd)/swiftcommand:/src" --workdir /src ibmcom/kitura-ubuntu /bin/bash -c 'cp /usr/lib/x86_64-linux-gnu/libxml2.so.2 /src/LinuxLibraries'

clean_swift:
	echo "Cleaning Swift build products"
	docker run \
               --rm \
               --volume "$(shell pwd)/swiftcommand:/src" \
               --workdir /src \
               ibmcom/kitura-ubuntu \
               swift build --clean
	echo "Cleaning Swift Linux dependencies"
	rm swiftcommand/LinuxLibraries/* || true

run:
	echo "Running executable on Linux"
	docker run -it --rm -v "$(shell pwd)/swiftcommand:/src" -w /src ubuntu /bin/bash -c 'LD_LIBRARY_PATH=/src/LinuxLibraries /src/.build/release/swiftcommand'

provision:
	cd terraform && terraform apply

destroy:
	cd terraform && terraform destroy

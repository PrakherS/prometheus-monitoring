export HELM_VERSION ?= 3.2.1

export AF_REPO ?= https://artifactory.oci.oraclecorp.com:443

#
# Make system configuration.
#
export BLD_VERSION ?= 0

export VERSION ?= $(BLD_VERSION)

MAKEFLAGS += --warn-undefined-variables

SHELL := bash

.SHELLFLAGS := -o errexit -o pipefail -o nounset -c
.SHELLFLAGS := -o errexit -o pipefail -o nounset -o xtrace -c

all: clean package-helm-charts

package-helm-charts:
	{ \
		rm -rf linux-amd64; \
		curl -sSL "${AF_REPO}/generic-blobs/shepherd/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar -xzvf -; \
		cp ./linux-amd64/helm ./helm && chmod 755 ./helm; \
		./helm package "helm-chart/${CHART_NAME}" --version "${VERSION}" -d './charts'; \
	}

local-ocibuild:
	# Install pre-requisites for local ocibuild.
	{ \
		if ! [ -e venv/bin/activate ]; then \
			rm -rf venv; \
			python3 -m venv venv; \
			printf '[global]\nindex-url=https://artifactory.oci.oraclecorp.com/api/pypi/global-release-pypi/simple\n' > venv/pip.conf; \
			source venv/bin/activate; \
			pip install --upgrade pip; \
			pip install --upgrade ocibuild; \
		fi; \
		\
		source venv/bin/activate; \
		ocibuild --override-bld-number=0; \
	}

clean:
	rm -rf build input_ocibuild* output_ocibuild*

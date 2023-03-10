FROM python:3.10.8-alpine3.16 AS builder

ARG BUILD_DEPS="\
    docker \
    gcc \
    libc-dev \
    libffi-dev \
    make \
    musl-dev \
    openssh-client \
    openssl-dev \
    "

RUN apk add --update --no-cache ${BUILD_DEPS}

COPY Pipfile* ./
RUN pip install pipenv && \
    pipenv install --deploy --system

FROM python:3.10.8-alpine3.16 AS runtime

LABEL "maintainer"="Pedigree Technologies <https://pedigreetechnologies.com>"
LABEL "repository"="https://github.com/pedigreetechnologies/github-action-molecule"
LABEL "com.github.actions.name"="molecule"
LABEL "com.github.actions.description"="Run Ansible Molecule"
LABEL "com.github.actions.icon"="upload"
LABEL "com.github.actions.color"="green"

COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/
COPY --from=builder /usr/local/bin/ansi2html \
                    /usr/local/bin/ansible* \
                    /usr/local/bin/cookiecutter \
                    /usr/local/bin/coverage \
                    /usr/local/bin/flake8 \
                    /usr/local/bin/molecule \
                    /usr/local/bin/pre-commit* \
                    /usr/local/bin/pytest \
                    /usr/local/bin/yamllint \
                    /usr/local/bin/

ARG PACKAGES="\
    docker \
    git \
    openssh-client \
    podman \
    rsync \
    tini \
    "

RUN apk add --update --no-cache ${PACKAGES} && \
    rm -rf /root/.cache

ENTRYPOINT ["/sbin/tini", "--"]
CMD cd ${INPUT_MOLECULE_WORKING_DIR}; molecule ${INPUT_MOLECULE_OPTIONS} ${INPUT_MOLECULE_COMMAND} ${INPUT_MOLECULE_ARGS}

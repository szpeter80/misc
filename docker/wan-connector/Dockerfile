### Dockerfile notes 


FROM docker.io/library/alpine:3.15

# OCI Annotations from https://github.com/opencontainers/image-spec/blob/master/annotations.md

LABEL \
org.opencontainers.image.url="TBD"  \
org.opencontainers.image.title="Wan connector"          \
org.opencontainers.image.description="Don't forget to mount persistent storage to DATA_DIR, otherwise you will loose data! In order to prevent it, the container refuses to start if it suspects that DATA_DIR is not provided with external persistent storage."


# ARG is gone after build
# ENV will be in the image

ENV TZ="Europe/Brussels"
ENV DATA_DIR="/mnt/wan-connector"
ENV INSTALL_DIR="/root/scripts"



ARG RUNTIME_PKGS=" \
            tzdata \
            tini \
            bash \
            nano \
            openssh-client \
            openvpn \
            "

ARG BUILD_PKGS=" \
             \
            "

# Build and cleanup needs to stay in the same RUN
# otherwise cleanup will run in a separate layer and wont reduce the image size
RUN set -eux && \
    apk update &&\
    apk add \
        --no-cache \
        --clean-protected \
        ${RUNTIME_PKGS} && \
    echo "Docker install build dependencies" && \
    apk add \
        --no-cache \
        --clean-protected \
        ${BUILD_PKGS} && \
    mkdir -p "${INSTALL_DIR}" && \
    mkdir -p "${DATA_DIR}" && \
    touch "${DATA_DIR}/NO_PERMANENT_STORAGE" && \
    echo "Docker build RUN success" && \
    apk del \
            --no-cache \
            --clean-protected \
        ${BUILD_PKGS} && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache && \
    echo "Docker cleanup RUN success"

COPY start-connection.sh "${INSTALL_DIR}/start-connection.sh"
COPY start-netcat.sh     "${INSTALL_DIR}/start-netcat.sh"

COPY docker-entrypoint.sh /docker-entrypoint.sh


VOLUME [ "${DATA_DIR}" ]

# CMD can be overridden in "docker run", ENTRYPOINT can't be

# Also if you specify both, in normal format it wont work, 
# in array format CMD definition will become argument after ENTRYPOINT
ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]


    
 

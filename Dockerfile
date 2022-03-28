ARG SOURCE_IMAGE="alpine"
ARG SOURCE_TAG="3.14"

FROM ${SOURCE_IMAGE}:${SOURCE_TAG}
#USER root

ARG PROXY
ARG MVN_VERSION="3.6.3"
ARG MVN_BASE_URL="https://mirror.dkm.cz/apache/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz"
ARG GOPASS_VERSION="1.12.5"

RUN apk update \
    && apk --no-cache add wget gnupg curl nodejs docker yarn npm python3 py3-pip git git-crypt bash openssh-client libc6-compat rsync openldap-clients make jq postgresql-client redis openssl \
    && wget -q https://github.com/gopasspw/gopass/releases/download/v$GOPASS_VERSION/gopass-$GOPASS_VERSION-linux-amd64.tar.gz -O - | tar xz gopass -C /usr/local/bin/ \
    && curl -s https://dl.min.io/client/mc/release/linux-amd64/mc \
        --create-dirs \
        -o /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc \
    && ln -s /usr/local/bin/gopass /usr/local/bin/pass \
    && addgroup -S builder && adduser -S builder -G builder \
    && apk --no-cache add --virtual=build gcc libffi-dev musl-dev openssl-dev python3-dev cargo \
    && pip --no-cache-dir install -U pip \
    && pip --no-cache-dir install ansible \
    && pip --no-cache-dir install j2cli \
    && pip --no-cache-dir install yq \
    && apk del --purge build \
    && apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    && mkdir -p /usr/share/maven /usr/share/maven/ref \
    && curl -fsSL -o /tmp/apache-maven.tar.gz ${MVN_BASE_URL} \
    && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
    && rm -f /tmp/apache-maven.tar.gz \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn 

USER builder

WORKDIR /
CMD ["bash"]

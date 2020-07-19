FROM amazonlinux:2

RUN yum -y update       && \
    yum -y install         \
        git                \
        openssh            \
        wget               \
        tar                \
        curl               \
    yum clean all       && \
    rm -rf /var/cache/yum

#Framework version
ENV VERSION_HUGO=0.74.2

# UTF-8 Environment
ENV LANGUAGE en_US:en
ENV LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install Extended Hugo
RUN wget https://github.com/gohugoio/hugo/releases/download/v${VERSION_HUGO}/hugo_extended_${VERSION_HUGO}_Linux-64bit.tar.gz && \
    tar -xf hugo_extended_${VERSION_HUGO}_Linux-64bit.tar.gz hugo -C / && \
    mv /hugo /usr/bin/hugo && \
    rm -rf hugo_extended_${VERSION_HUGO}_Linux-64bit.tar.gz

ENTRYPOINT ["bash", "-c"]

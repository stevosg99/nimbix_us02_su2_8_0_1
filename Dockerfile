
FROM rockylinux:9
ENV LANG C.UTF-8
LABEL maintainer="Stephen Graham" \
      license="GNU LGPL 2.1"

#RUN dnf update && dnf install -y epel-release dnf-plugins-core epel-release
#RUN dnf config-manager --set-enabled powertools
#RUN dnf install -y git gcc gcc-c++ swig

#RUN dnf remove -y mpich

# Copy from nimbix/image-common
RUN curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/jarvice-desktop/master/install-nimbix.sh \
        | bash

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

# Change working directory
WORKDIR /usr/local

# Create a directory to compile SU2
RUN mkdir -p /usr/local/SU2

# Add all source files to the newly created directory
ADD --chown=root:root ./ /usr/local/SU2

# Ensure full access
RUN sudo chmod -R 0777 /usr/local/SU2

# Save Nimbix AppDef
COPY ./NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate
COPY ./NAE/SU2logo.png /etc/NAE/SU2logo.png
COPY ./NAE/screenshot.png /etc/NAE/screenshot.png

# Call init.sh to compile and install SU2, verify all nodes are active, and begin solving
CMD ["/usr/local/SU2/init/init.sh"]

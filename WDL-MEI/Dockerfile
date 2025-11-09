FROM ubuntu:20.04

LABEL maintainer="RVel ray.velissaris@nhs.net"

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
      libnss-sss \
      openjdk-8-jre \
      unzip \
      perl \
      wget \
      curl \
      --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /opt/bin /MELT

# Add MELT v2.2 tar.gz
ADD MELTv2.2.2.tar.gz /MELT/

# Add bowtie2
ADD bowtie2-2.3.4-linux-x86_64.zip /tmp/
RUN unzip -d /opt/ /tmp/bowtie2-2.3.4-linux-x86_64.zip

# Make MELT executable
RUN chmod -R +x /MELT

# Add tools to PATH (keep old order to match old image)
ENV PATH="/MELT/MELTv2.2.2:/opt/bowtie2-2.3.4-linux-x86_64:/opt/samtools/bin:/opt/bcftools/bin:/opt/vcftools/bin:/opt/bedtools/bin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Set working directory
WORKDIR /MELT/

# Default interactive shell
CMD ["/bin/bash"]

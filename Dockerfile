FROM ubuntu:20.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update 
RUN apt-get install -y python3 python3-venv git --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN mkdir /work 
RUN git clone https://github.com/miyurudassanayake/sni-injector.git /work/sni-injector 
WORKDIR /work/sni-injector
RUN python3 -m venv .venv 

FROM ubuntu:20.04 AS beta
USER root
ENV DEBIAN_FRONTEND=noninteractive  
ARG BUILD_VERSION=1.0.0
LABEL version="${BUILD_VERSION}"
RUN mkdir /work 
COPY --from=build /work/sni-injector /work/sni-injector
WORKDIR /work/
RUN chown -R $USER:$USER /work/sni-injector/.venv 
RUN chmod -R 755 /work/sni-injector/.venv 
RUN apt update 
RUN apt-get install -y python3 python3-pip openssh-client ncat --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN bash -c "source /work/sni-injector/.venv/bin/activate"
RUN pip install -r /work/sni-injector/requirements.txt 
COPY run.sh .
COPY config.sh .
RUN chmod +x run.sh config.sh 
EXPOSE 1080
ENTRYPOINT ["/usr/bin/bash","/work/run.sh"]


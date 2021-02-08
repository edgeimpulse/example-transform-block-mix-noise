FROM ubuntu:18.04

WORKDIR /app

RUN apt update && apt install -y sox python3 python3-distutils curl ffmpeg libsox-fmt-mp3

# Install youtube-dl
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py
RUN pip3 install youtube-dl

# Grab a traffic noise video
RUN youtube-dl https://www.youtube.com/watch?v=cUpox5jGdRQ --extract-audio && \
    mv *.m4a traffic.m4a

# Take the first 30 minutes and turn into mp3
RUN ffmpeg -i traffic.m4a -ss 00:00:00 -to 00:30:00 -c:v copy -c:a libmp3lame -q:a 4 traffic.mp3 && \
    rm traffic.m4a

# Create 3sec. segments from the 30 minutes of audio
RUN mkdir -p segments && \
    ffmpeg -i traffic.mp3 -f segment -segment_time 3 -c copy segments/traffic_%04d.mp3 && \
    rm traffic.mp3

# Copy the convert script
COPY convert.sh ./

ENTRYPOINT [ "/bin/bash", "convert.sh" ]

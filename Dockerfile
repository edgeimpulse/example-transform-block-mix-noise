FROM python:3.7
WORKDIR /app

RUN apt update && apt install -y sox curl ffmpeg libsox-fmt-mp3 

# Install yt-dlp

RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+rx /usr/local/bin/yt-dlp  # Make executable
# Grab a traffic noise video in mp3 format
RUN yt-dlp https://www.youtube.com/watch?v=cUpox5jGdRQ --extract-audio --audio-format mp3 && \
    mv *.mp3 traffic.mp3 

# Create 3sec. segments from the audio
RUN mkdir -p segments && \
    ffmpeg -i traffic.mp3 -f segment -segment_time 3 -c copy segments/traffic_%04d.mp3 && \
    rm traffic.mp3

# Copy the convert script
COPY convert.sh ./

ENTRYPOINT [ "/bin/bash", "convert.sh" ]

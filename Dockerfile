# Using a compact OS
FROM centos:latest

MAINTAINER langrenchuan <https://github.com/langrenchuan>

COPY ./ /usr/games

EXPOSE 80

CMD python /usr/games/snake.py


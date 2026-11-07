FROM perl:5.43.9

WORKDIR /app
COPY cpanfile /app

RUN cpanm --with-develop --installdeps --notest .
VOLUME /app/local

CMD cp -r /app /work && cd /work && minil build && minil test

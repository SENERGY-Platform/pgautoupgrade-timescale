FROM timescale/timescaledb-ha:pg18-ts2.25-all AS pg18
FROM pgautoupgrade/pgautoupgrade:18-debian AS pgautoupgrade

# Copy in PostGIS libs / bins
RUN --mount=type=bind,from=pg18,source=/etc/alternatives,target=/mnt/pg18_etc_alternatives \
    cp -rn /mnt/pg18_etc_alternatives/postgresql-18-* /etc/alternatives/ || true

# Copy extensions and binaries for postgresql
COPY --from=pg18 /usr/lib/postgresql /usr/lib/postgresql
COPY --from=pg18 /usr/share/postgresql /usr/share/postgresql
COPY --from=pg18 /etc/alternatives/postgresql-* /etc/alternatives/

# Copy timescaledb libs from 17 to 18: some missing in 18
RUN cp /usr/lib/postgresql/17/lib/timescaledb-2.22* /usr/lib/postgresql/18/lib
RUN cp /usr/lib/postgresql/17/lib/timescaledb-tsl-2.22* /usr/lib/postgresql/18/lib
RUN cp /usr/lib/postgresql/17/lib/timescaledb_toolkit-1.21* /usr/lib/postgresql/18/lib

ENV \
    PGTARGET=18 \
    PGDATA=/var/lib/postgresql/data
WORKDIR /var/lib/postgresql
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["postgres"]

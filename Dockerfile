FROM timescale/timescaledb-ha:pg13 AS pg13
FROM timescale/timescaledb-ha:pg14 AS pg14
FROM timescale/timescaledb-ha:pg15 AS pg15
FROM timescale/timescaledb-ha:pg16 AS pg16
FROM timescale/timescaledb-ha:pg17 AS pg17
FROM pgautoupgrade/pgautoupgrade:17-debian AS pgautoupgrade

# Copy in PostGIS libs / bins
RUN --mount=type=bind,from=pg17,source=/usr/lib,target=/mnt/pg17_lib \
    cp -rn /mnt/pg17_lib/* /usr/lib/

RUN --mount=type=bind,from=pg17,source=/etc/alternatives,target=/mnt/pg17_etc_alternatives \
    cp -rn /mnt/pg17_etc_alternatives/postgresql-17-* /etc/alternatives/ || true

# Copy extensions and binaries for postgresql 17
COPY --from=pg17 /usr/lib/postgresql/17 /usr/lib/postgresql/17
COPY --from=pg17 /usr/share/postgresql/17 /usr/share/postgresql/17
COPY --from=pg17 /etc/alternatives/postgresql-17* /etc/alternatives/
# Copy all extensions and binaries for postgresql 16
COPY --from=pg16 /usr/lib/postgresql/16 /usr/lib/postgresql/16
COPY --from=pg16 /usr/share/postgresql/16 /usr/share/postgresql/16
COPY --from=pg16 /etc/alternatives/postgresql-16* /etc/alternatives/
# Copy all extensions and binaries for postgresql 15
COPY --from=pg15 /usr/lib/postgresql/15 /usr/lib/postgresql/15
COPY --from=pg15 /usr/share/postgresql/15 /usr/share/postgresql/15
COPY --from=pg15 /etc/alternatives/postgresql-15* /etc/alternatives/
# Copy all extensions and binaries for postgresql 14
COPY --from=pg14 /usr/lib/postgresql/14 /usr/lib/postgresql/14
COPY --from=pg14 /usr/share/postgresql/14 /usr/share/postgresql/14
COPY --from=pg14 /etc/alternatives/postgresql-14* /etc/alternatives/
# Copy all extensions and binaries for postgresql 13
COPY --from=pg13 /usr/lib/postgresql/13 /usr/lib/postgresql/13
COPY --from=pg13 /usr/share/postgresql/13 /usr/share/postgresql/13
COPY --from=pg13 /etc/alternatives/postgresql-13* /etc/alternatives/

# Create symlinks for each version (except latest)
RUN rm -rf /usr/local-pg16 /usr/local-pg15 /usr/local-pg14 /usr/local-pg13 /usr/local-pg17 \
    && ln -s /usr/lib/postgresql/16 /usr/local-pg16 \
    && ln -s /usr/lib/postgresql/15 /usr/local-pg15 \
    && ln -s /usr/lib/postgresql/14 /usr/local-pg14 \
    && ln -s /usr/lib/postgresql/13 /usr/local-pg13

ENV \
    PGTARGET=17 \
    PGDATA=/var/lib/postgresql/data
WORKDIR /var/lib/postgresql
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["postgres"]
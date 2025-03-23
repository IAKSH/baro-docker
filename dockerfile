FROM cm2network/steamcmd
RUN /home/steam/steamcmd/steamcmd.sh +force_install_dir ./barotrauma +login anonymous +app_update 1026340 validate +quit
WORKDIR /home/steam/steamcmd/barotrauma
RUN curl -fsSL https://github.com/evilfactory/LuaCsForBarotrauma/releases/download/latest/luacsforbarotrauma_patch_linux_server.tar.gz -o luacsforbarotrauma_patch_linux_server.tar.gz && tar -zxvf luacsforbarotrauma_patch_linux_server.tar.gz && rm luacsforbarotrauma_patch_linux_server.tar.gz
CMD ["./DedicatedServer"]

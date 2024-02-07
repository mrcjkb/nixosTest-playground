{
  nixosTest,
  curl,
}:
nixosTest {
  name = "client/server test";
  nodes = {
    server = {...}: {
      services.nginx = {
        enable = true;
        virtualHosts = {
          "tiko.ch" = {
            root = ./webroot;
            listen = [
              {
                addr = "0.0.0.0";
                port = 8080;
              }
            ];
          };
        };
      };
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [8080];
      };
    };
    client = {...}: {
      environment.systemPackages = [
        curl
      ];
    };
  };
  testScript =
    /*
    python
    */
    ''
      server.start()
      client.start()
      server.wait_for_unit("multi-user.target")
      client.wait_for_unit("multi-user.target")
      client.succeed("curl server:8080 > index.html")
      client.succeed("diff index.html ${./webroot/index.html}")
    '';
}

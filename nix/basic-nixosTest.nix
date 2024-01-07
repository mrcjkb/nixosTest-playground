{nixosTest}:
nixosTest {
  name = "basic-nixosTest";
  nodes.machine = {
    services.zookeeper = {
      enable = true;
      port = 2182;
    };
  };
  testScript =
    /*
    python
    */
    ''
      machine.start()
      machine.wait_for_unit("multi-user.target")
      machine.wait_for_open_port(2182)
      machine.succeed("curl localhost:2182")
    '';
}

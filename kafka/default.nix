{
  nixosTest,
  kcat,
  apacheKafka,
}:
nixosTest {
  name = "kafka-kcat-test";
  nodes = {
    zookeeper = {...}: {
      services.zookeeper = {
        enable = true;
      };
      networking.firewall.allowedTCPPorts = [2181];
    };
    kafka = {...}: {
      services.apache-kafka = {
        package = apacheKafka;
        enable = true;
        settings = {
          "broker.id" = 0;
          "listeners" = ["PLAINTEXT://:9092"];
          "advertised.listeners" = ["PLAINTEXT://:9092"];
          "log.dirs" = ["/var/log/kafka"];
          "offsets.topic.replication.factor" = 1;
          "zookeeper.session.timeout.ms" = 600000;
          "zookeeper.connect" = ["zookeeper:2181"];
        };
      };
      environment.systemPackages = [
        # For creating topics
        apacheKafka
      ];
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          9092
        ];
      };
    };
    publisher = {...}: {
      environment.systemPackages = [
        kcat
      ];
    };
    subscriber = {...}: {
      environment.systemPackages = [
        kcat
      ];
    };
  };
  testScript =
    /*
    python
    */
    ''
      start_all()

      zookeeper.wait_for_unit("default.target")
      zookeeper.wait_for_unit("zookeeper.service")
      zookeeper.wait_for_open_port(2181)

      kafka.wait_for_unit("default.target")
      kafka.wait_for_unit("apache-kafka.service")
      kafka.wait_for_open_port(9092)

      kafka.wait_until_succeeds(
          "kafka-topics.sh --create "
          + "--bootstrap-server localhost:9092 --partitions 1 "
          + "--replication-factor 1 --topic testtopic"
      )

      publisher.succeed("echo 'Hello codefreeze!' | kcat -b kafka:9092 -t testtopic")
      assert "Hello codefreeze!" in subscriber.succeed("kcat -C -b kafka:9092 -c 1 -t testtopic")
    '';
}

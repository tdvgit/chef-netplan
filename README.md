# chef-netplan
Chef cookbook for configuring the Netplan network manager

## Usage

```
netplan_configure "ens3" do
  addresses ["192.168.0.1", "192.168.0.2", "192.168.0.3"]
end
```

This will (using the defaults) create the file `/etc/netplan/60-static-ips.yaml` and configure the static ips you provided.

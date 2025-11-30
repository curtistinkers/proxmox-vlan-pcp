# Proxmox SDN VLAN QoS

Changes made to `/etc/network/interfaces.d/sdn` are overwritten after applying
new updates to the SDN so adding `post-up` commands to those VNets get erased
when making any changes.

This package provides systemd service templates and an additional helper
script to set VLAN ingress and egress Quality of Service (QoS) priority
code points on Proxmox Software Defined Networks (SDN) after updates.

**Note**: _This only works on regular VLANs_

## 802.1p VLAN QoS priority code points

You need a basic understanding of VLAN QoS priority code points to get started.

| PCP value |  Priority   | Acronym | Traffic types |
| --------- | ----------- | :-----: | ---------------------------------- |
| `1`       | 0 (lowest)  | `BK`    | Background                         |
| `0`       | 1 (default) | `BE`    | Best Effort                        |
| `2`       | 2           | `EE`    | Excellent Effort                   |
| `3`       | 3           | `CA`    | Critical Applications              |
| `4`       | 4           | `VI`    | Video, < 100 ms latency and jitter |
| `5`       | 5           | `VO`    | Voice, < 10 ms latency and jitter  |
| `6`       | 6           | `IC`    | Internetwork Control               |
| `7`       | 7           | `NC`    | Network Control                    |

## Helper script

Allows you to easily change the QoS policy using the acronym or priority code
point value as well as check the current QoS settings on an interface. It's
useful for `post-up` commands on manually defined interfaces.

### Get current QoS policy

To get the current QoS policy on an interface:

```sh
set-vlan-qos --interface ${IFACE} --get
```

If `${IFACE}` has a QoS policy for _Critical Applications_ it will return:

```sh
VLAN QoS priority for ${IFACE}:

        Ingress QoS map: { 0:1 2:2 3:3 4:4 5:5 6:6 7:7 } 
        Egress QoS map:  { 0:3 1:3 2:3 3:3 4:3 5:3 6:3 7:3 } 
```

### Set QoS policy

To set a QoS policy on an interface:

```sh
set-vlan-qos --interface ${IFACE} --pcp ${PCP}
```

Where `${PCP}` is either a priority code point value or a corresponding acronym.

#### Helper script examples

To set `vmbr0.42` QoS policy to _Critical Applications_:

```sh
set-vlan-qos -i vmbr0.42 -p CA
```

The output of which would be:

```sh
Setting vmbr0.42 interface egress QoS priority to Critical Applications
```

##### `/etc/nework/interfaces` post-up example

```sh
auto vmbr0.42
iface vmbr0.42 inet6 static
        address 2001:db8:dead:beef::1/64
        post-up set-vlan-qos --interface vmbr0.42 -p CA
```

## Systemd templates

Enable the systemd services templates as follows:

```sh
systemctl enable --now sdn-vlan-qos-${ACRONYM}@${IFACE}
```

### Systemd template examples

For example, if you want to set VLAN `42` on `vmbr0` to *Critical Application*:

```sh
systemctl enable --now sdn-vlan-qos-ca@vmbr0.42
```

Similarly, if you want to set VLAN `666` on `vmbr1` to *Voice*:

```sh
systemctl enable --now sdn-vlan-qos-vo@vmbr0.666
```
